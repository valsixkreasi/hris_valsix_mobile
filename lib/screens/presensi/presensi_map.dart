import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:hris/components/buttonicon.dart';
import 'package:hris/components/imageurl.dart';
import 'package:hris/components/rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Penting untuk lokalisasi
import 'package:latlong2/latlong.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/models/api.dart';
import 'package:radio_group_v2/radio_group_v2.dart';

class PresensiMap extends StatefulWidget {
  const PresensiMap({super.key});

  @override
  State<PresensiMap> createState() => _PresensiMapState();
}

class _PresensiMapState extends State<PresensiMap>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 500), // Durasi transisi
    curve: Curves.easeInOut, // Jenis kurva animasi
  );
  final Map<String, RadioGroupController> radioGroupControllers = {};
  final Map<String, GlobalKey<RadioGroupState>> radioKeys = {};

  bool isLoadLokasi = true;
  final List<Marker> _markers = [];
  final List<CircleMarker> _circles = [];
  LatLng? currentLatLng;
  final List<LatLng> dataLatLng = [];
  String latitude = "";
  String longitude = "";
  // double latitudeDev = -7.3208202411194955;
  // double longitudeDev = 112.76273070269497;
  String currentTimeZone = "";
  String alamat = "";
  List<Map<String, dynamic>> dataLokasi = [];
  String reqLokasiKerjaId = "";
  Map<String, dynamic> logHariIni = {};
  final List<Map<String, dynamic>> jenisAbsen = [];
  final List<Map<String, dynamic>> jenisMood = [];
  String abseninout = "";
  Timer? _timer;
  String pesanJarakLokasi = "-";
  bool bisaAbsen = false;
  bool lokasiBebas = false;
  String jamMasuk = '--:--';
  String jamPulang = '--:--';
  String _currentDate = "";
  String _currentTime = "";
  String selectedJenisAbsen = "";
  String selectedJenisAbsenAghris = "";
  String selectedSubJenisAbsen = "";
  String selectedSubJenisAbsenAghris = "";
  String selectedMood = "";

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    super.initState();
    _getUserLocation();
    _getCurentDate();
    _updateWaktu();
    // Set timer untuk memperbarui setiap 1 detik
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateWaktu());
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    _timer?.cancel(); // Pastikan timer dihentikan saat widget dihapus
    super.dispose();
  }

  void _getCurentDate() async {
    // Inisialisasi format lokal Indonesia
    await initializeDateFormatting('id_ID', null);
    DateTime now = DateTime.now();
    setState(() {
      _currentDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    });
  }

  void _updateWaktu() {
    setState(() {
      // Format manual atau gunakan paket 'intl'
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Constants.getCurrentPosition();
      print(position);
      setState(() {
        currentLatLng = LatLng(position.latitude, position.longitude);
        latitude = '${position.latitude}';
        longitude = '${position.longitude}';
        // currentLatLng = LatLng(latitudeDev, longitudeDev);
        // latitude = '$latitudeDev';
        // longitude = '$longitudeDev';
        dataLatLng.add(LatLng(position.latitude, position.longitude));
        _markers.add(
          Marker(
            point: LatLng(position.latitude, position.longitude),
            // point: LatLng(latitudeDev, longitudeDev),
            width: 40,
            height: 40,
            child: const Icon(Icons.location_pin, color: Colors.green),
          ),
        );
      });
      getTimeZone();
      getAddress(position);
      getDataLokasi();
      getJenisAbsensi();
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showToast(
        'Lokasi tidak ditemukan.',
        duration: const Duration(seconds: 1),
      );
      debugPrint(e.toString());
    }
  }

  Future<void> getTimeZone() async {
    final String timezone = await FlutterTimezone.getLocalTimezone();
    setState(() {
      currentTimeZone = timezone;
    });
  }

  void getAddress(Position position) async {
    // Ubah Koordinat Menjadi Alamat (Reverse Geocoding)
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    // Ambil Detail Alamat
    Placemark place = placemarks[0];
    setState(() {
      alamat =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
    });
  }

  void getDataLokasi() async {
    ApiModel model = ApiModel('lokasi_kerja_json');
    model.get().then((value) async {
      List<dynamic> lokasi = value['result'];
      List<Map<String, dynamic>> arrLokasi =
          lokasi.map((e) => e as Map<String, dynamic>).toList();
      // mapping point lokasi agar semua lokasi bisa terlihat pada map
      List<LatLng> points = lokasi.map((item) {
        double lat = double.parse(item['latitude']);
        double lng = double.parse(item['longitude']);
        return LatLng(lat, lng);
      }).toList();
      // mapping pin titik lokasi
      List<Marker> arrMarker = lokasi.map((item) {
        return Marker(
          point: LatLng(
              double.parse(item['latitude']), double.parse(item['longitude'])),
          width: 40,
          height: 40,
          child: const Icon(Icons.location_pin, color: Colors.red),
        );
      }).toList();
      // mapping lingkaran pada titik lokasi
      List<CircleMarker> arrCircle = lokasi.map((item) {
        return CircleMarker(
          point: LatLng(double.parse(item['latitude']),
              double.parse(item['longitude'])), // Titik pusat lingkaran
          radius: double.parse(
              item['radius']), // Radius dalam satuan (lihat useRadiusInMeter)
          useRadiusInMeter: true, // Radius dihitung dalam meter
          color: Colors.blue.withOpacity(0.3), // Warna isi lingkaran
          borderColor: Colors.blue, // Warna garis tepi
          borderStrokeWidth: 1, // Ketebalan garis tepi
        );
      }).toList();
      Map<String, dynamic> hariini = value['log_hari_ini'] ?? {};
      setState(() {
        dataLokasi = arrLokasi; // simpan data lokasi kerja yg asli
        dataLatLng.addAll(
            points); // data point lokasi agar semua lokasi bisa terlihat pada map
        _markers.addAll(arrMarker); // data untuk menandai lokasi dengan pin
        _circles
            .addAll(arrCircle); // data untuk menandai lokasi dengan lingkaran
        logHariIni = hariini;
        jamMasuk = value['jam_masuk'];
        jamPulang = value['jam_pulang'];
        isLoadLokasi = false;
      });
      cekLokasiUser(lokasi);

      // TIDAK DIGINAKAN lagi, tampilan awal map lagnsung zoom ke lokasi user
      /*
      // Tunggu map siap sebelum fit camera
      if (!isLoadLokasi) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fitAllMarkers(dataLatLng!);
        });
      }
      */
      EasyLoading.dismiss();
    });
  }

  // UNTUK tampilan awal map, agar bisa melihat semua lokasi kerja.
  void fitAllMarkers(List<LatLng> points) {
    _animatedMapController.animatedFitCamera(
      cameraFit: CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(
            50.0), // Berikan jarak agar marker tidak mepet ke tepi layar
      ),
      duration: const Duration(milliseconds: 800), // Durasi transisi
      curve: Curves.easeInOut,
    );
    // _mapController.fitCamera(
    //   CameraFit.bounds(
    //     bounds: LatLngBounds.fromPoints(points),
    //     padding: const EdgeInsets.all(50),
    //   ),
    // );
  }

  void fitToUserLocation() {
    _animatedMapController.animateTo(
      dest: currentLatLng,
      zoom: 18.0, // Level zoom yang diinginkan
      rotation: 0.0, // Opsional: reset rotasi jika perlu
    );
    // _mapController.move(currentLatLng!, 18);
  }

  void cekLokasiUser(List<dynamic> dataLokasi) {
    bool inRadius = false;
    for (var lokasi in dataLokasi) {
      double targetLat = double.parse(lokasi['latitude']);
      double targetLng = double.parse(lokasi['longitude']);
      double radiusMax = double.parse(lokasi['radius']);
      double userLatitude = double.parse(latitude);
      double userLongitude = double.parse(longitude);

      // Menghitung jarak antara user dan lokasi target (hasil dalam Meter)
      double jarakMeter = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        targetLat,
        targetLng,
      );

      // jika mode debug maka di bypass didalam radius & bisa melakukan absen
      // if (kDebugMode) {
      //   inRadius = true;
      //   setState(() {
      //     reqLokasiKerjaId = lokasi['lokasi_kerja_id'];
      //   });
      // }

      if (jarakMeter <= radiusMax) {
        inRadius = true;
        setState(() {
          reqLokasiKerjaId = lokasi['lokasi_kerja_id'];
        });
        print("Anda berada di dalam radius: ${lokasi['nama_lokasi']}");
      } else {
        print(
            "Anda berada di luar radius ${lokasi['nama_lokasi']}. Jarak: ${jarakMeter.toStringAsFixed(2)} meter");
      }
    }
    if (dataLokasi.length > 0) {
      setState(() {
        bisaAbsen = inRadius ? true : false;
        pesanJarakLokasi = inRadius
            ? 'Anda berada didalam radius lokasi kerja.'
            : 'Anda berada diluar radius lokasi kerja.';
      });
    } else {
      setState(() {
        bisaAbsen = false;
        pesanJarakLokasi = 'Tidak ada lokasi kerja';
      });
    }
  }

  void getJenisAbsensi() async {
    ApiModel model = ApiModel('absensi_recognition_json');
    model.get().then((value) async {
      List<dynamic> arrJenisAbsen = value['jenis_absen'];
      List<Map<String, dynamic>> arrJenis =
          arrJenisAbsen.map((e) => e as Map<String, dynamic>).toList();
      // Melakukan looping pada array data untuk membuat controller RadioGroupController.
      for (var item in arrJenis) {
        String id = item['kode'].replaceAll(" ", "");
        // hanya yg mempunyai data saja yg di Inisialisasi
        if (item['sub_jenis'].length > 0) {
          // Inisialisasi controller untuk sub jenis absensi
          radioGroupControllers[id] = RadioGroupController();
          // Inisialisasi Key unik untuk sub jenis absensi
          radioKeys[id] = GlobalKey<RadioGroupState>();
        }
      }
      List<dynamic> arrJenisMood = value['jenis_mood'];
      List<Map<String, dynamic>> arrMood =
          arrJenisMood.map((e) => e as Map<String, dynamic>).toList();
      setState(() {
        jenisAbsen.addAll(arrJenis);
        jenisMood.addAll(arrMood);
        abseninout = value['absen_inout'] ?? '';
      });
      EasyLoading.dismiss();
    });
  }

  Future<void> kirimAbsensi(BuildContext context) async {
    EasyLoading.show(status: 'Prosess Absensi...');
    Map<String, String> body = {
      'reqJam': DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
      'reqLongitude': latitude,
      'reqLatitude': longitude,
      'reqLokasiKerjaId': reqLokasiKerjaId,
      'reqAlat': 'MAPS',
      'reqInterval': '0',
      'reqPlatform': Platform.isAndroid ? 'ANDROID' : 'IOS',
      'reqGmt': '${DateTime.now().timeZoneOffset.inHours}',
      'reqTimeZone': currentTimeZone,
      'reqJenisAbsen': '$selectedJenisAbsen',
      'reqSubJenisAbsen': '$selectedSubJenisAbsen', // jika OUT dibuat kosong
      'reqAlamat': alamat,
      'reqMood': selectedMood,
      'reqModeAbsen': abseninout
    };
    // print(body);
    // return;
    var response = await Constants.postData(
      'absensi_recognition_json',
      body,
    );
    Map<String, dynamic> responseJson =
        jsonDecode(response) as Map<String, dynamic>;
    print(responseJson);
    if (responseJson['status'] == 'success') {
      kirimAbsensiAGHRIS(); // lanjut kirim absensi ke AGHRIS
      getDataLokasi(); // utk refresh log hari ini
      EasyLoading.dismiss();
      EasyLoading.showToast(
        '${responseJson['message']} HARMONIS',
        duration: const Duration(seconds: 1),
      );
      Navigator.pop(context);
    } else {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 1),
      );
    }
  }

  void kirimAbsensiAGHRIS() async {
    String nik = Constants.session['data']['nrp'];
    String nikBaru = "";
    if (nik.isNotEmpty && nik[0] == '0') {
      nikBaru = nik.substring(1);
    } else {
      nikBaru = nik;
    }
    ApiModel model =
        ApiModel('${Constants.baseUrlAGHRIS}pb-03-5-2-check-in-v2?');
    if (abseninout == 'IN') {
      model.setParam({
        'user-access': Constants.userAccessAGHRIS,
        'key': Constants.keyAGHRIS,
        'nik-sap-target': nikBaru,
        'jenis-absen': selectedJenisAbsenAghris,
        'shift': selectedSubJenisAbsenAghris,
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'check-in-time': DateFormat('HH:mm').format(DateTime.now()),
        'checkin-long': longitude,
        'checkin-lat': latitude,
        'user': nikBaru,
        'mood': selectedMood,
      });
    } else {
      model = ApiModel('${Constants.baseUrlAGHRIS}pb-03-5-2-check-out-v2?');
      model.setParam({
        'user-access': Constants.userAccessAGHRIS,
        'key': Constants.keyAGHRIS,
        'nik-sap-target': nikBaru,
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'check-out-time': DateFormat('HH:mm').format(DateTime.now()),
        'checkout-long': longitude,
        'checkout-lat': latitude,
        'user': nikBaru,
        'mood': selectedMood,
      });
    }
    model.getByUrl().then((value) async {
      print(value);
      List<dynamic> response = value['data'];
      if (response[0]['hasil'] == '2') {
        popUpAlert('Gagal absen pada AGHRIS, ${response[0]['pesan']}');
      }
    });
  }

  void popUpAlert(String pesan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Info."),
          content: Text(pesan),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Menutup dialog
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void popUpJenisAbsen(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Pastikan variabel pilihan berada di luar builder StatefulBuilder
        // jika ingin nilainya tetap tersimpan selama dialog terbuka.
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Pilih Mood & Jenis Absen"),
              titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              content: Container(
                width: 0.9.sw,
                child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Agar dialog tidak memenuhi layar
                    children: [
                      Divider(height: 1.0),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 4.sp,
                        runSpacing: 4.sp,
                        children: [
                          ...jenisMood.map((item) {
                            String label = '';
                            if (item['kode'] != '') {
                              label = item['kode'][0].toUpperCase() +
                                  item['kode'].substring(1).toLowerCase();
                            }
                            return ButtonMood(
                              onPress: () {
                                setDialogState(() {
                                  selectedMood = item['kode'];
                                });
                              },
                              selected:
                                  item['kode'] == selectedMood ? true : false,
                              iconMood: item['link_icon'],
                              label: label,
                            );
                          })
                        ],
                      ),
                      SizedBox(height: 10),
                      abseninout == 'IN'
                          ? Column(
                              children: [
                                ...jenisAbsen.map((item) {
                                  final String controllerKode =
                                      item['kode'].replaceAll(" ", "");
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Divider(height: 1.0),
                                      // bungkus dengan Theme utk menyesuaikan jarak / padding
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          listTileTheme:
                                              const ListTileThemeData(
                                            horizontalTitleGap:
                                                4.0, // Sesuaikan jarak di sini
                                            minVerticalPadding: 2.0,
                                          ),
                                        ),
                                        child: RadioListTile<String>(
                                          contentPadding: EdgeInsets.zero,
                                          visualDensity: VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                          activeColor: Constants.primaryGreen,
                                          title: Text(item['kode']!),
                                          value: item['kode']!,
                                          groupValue: selectedJenisAbsen,
                                          onChanged: (String? value) {
                                            // Gunakan setDialogState untuk memperbarui UI di dalam dialog
                                            setDialogState(() {
                                              selectedJenisAbsen = value!;
                                              selectedJenisAbsenAghris =
                                                  item['kode_aghris'];
                                              selectedSubJenisAbsen =
                                                  item['sub_jenis'].length > 0
                                                      ? item['sub_jenis'][0]
                                                      : "";
                                              radioGroupControllers
                                                  .forEach((key, controller) {
                                                // Jika ID tidak sama dengan yang diklik, reset controller-nya
                                                if (key != controllerKode) {
                                                  // Pastikan controller masih memiliki widget yang menempel
                                                  controller.value =
                                                      null; // membuat sub jenis yg lainnya unselect
                                                }
                                              });
                                              lokasiBebas =
                                                  item['status_lokasi_bebas'] ==
                                                          'Y'
                                                      ? true
                                                      : false;
                                            });
                                            if (item['sub_jenis'].length > 0) {
                                              // Memilih item pertama pada sub jenis
                                              radioGroupControllers[
                                                      controllerKode]!
                                                  .selectAt(0);
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 32),
                                        child: item['sub_jenis'].length > 0
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: RadioGroup(
                                                  key:
                                                      radioKeys[controllerKode],
                                                  controller:
                                                      radioGroupControllers[
                                                          controllerKode],
                                                  values: item[
                                                      'sub_jenis'], // data array jenis
                                                  // indexOfDefault = default selected, -1 artinya tidak ada yg terpilih.
                                                  indexOfDefault: -1,
                                                  orientation:
                                                      RadioGroupOrientation
                                                          .horizontal,
                                                  decoration:
                                                      RadioGroupDecoration(
                                                          horizontalAlignment:
                                                              WrapAlignment
                                                                  .spaceBetween),
                                                  // labelBuilder = label radio button
                                                  labelBuilder: (value) =>
                                                      Text(value),
                                                  // Logika pembeda di sini
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      // Jalankan pembersihan grup lain SEGERA SETELAH frame saat ini selesai
                                                      Future.microtask(() {
                                                        setDialogState(() {
                                                          selectedJenisAbsen =
                                                              item['kode'];
                                                          selectedJenisAbsenAghris =
                                                              item[
                                                                  'kode_aghris'];
                                                          selectedSubJenisAbsen =
                                                              value;
                                                          selectedSubJenisAbsenAghris =
                                                              '${radioGroupControllers[controllerKode]!.selectedIndex}';
                                                          radioGroupControllers
                                                              .forEach((key,
                                                                  controller) {
                                                            // Jika ID tidak sama dengan yang diklik, reset controller-nya
                                                            if (key !=
                                                                controllerKode) {
                                                              // Pastikan controller masih memiliki widget yang menempel
                                                              controller.value =
                                                                  null; // membuat sub jenis yg lainnya unselect
                                                            }
                                                          });
                                                          lokasiBebas =
                                                              item['status_lokasi_bebas'] ==
                                                                      'Y'
                                                                  ? true
                                                                  : false;
                                                        });
                                                      });
                                                    }
                                                    // print(
                                                    //     "Kategori: ${item['kode']}, Sub Pilih: $value");
                                                  },
                                                ),
                                              )
                                            : SizedBox(),
                                      ),
                                    ],
                                  );
                                }).toList()
                              ],
                            )
                          : SizedBox(),
                      Divider(height: 1.0),
                    ]),
              ),
              actions: [
                ButtonIcon(
                  labelColor: Colors.white,
                  bgColor: lokasiBebas || bisaAbsen
                      ? Constants.primaryBlue
                      : Colors.grey,
                  icon: Icon(Icons.send, color: Colors.white, size: 16),
                  label: Text(
                    'KIRIM',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    if (selectedMood == "") {
                      EasyLoading.showToast(
                        'Harap pilih Mood hari ini.',
                        duration: const Duration(seconds: 1),
                      );
                    } else if (selectedJenisAbsen == "") {
                      EasyLoading.showToast(
                        'Harap pilih Jenis absensi dahulu.',
                        duration: const Duration(seconds: 1),
                      );
                    } else {
                      if (lokasiBebas || bisaAbsen) {
                        kirimAbsensi(context);
                        // kirimAbsensiAGHRIS();
                      } else {
                        EasyLoading.showToast(
                          '$selectedJenisAbsen haru berada dalam radius lokasi kerja.',
                          duration: const Duration(seconds: 2),
                        );
                      }
                    }
                  },
                ),
              ],
              actionsAlignment: MainAxisAlignment.center,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavHeader(
        showBottomNavigationBar: false,
        showDrawer: false,
        scaffoldKey: scaffoldKey,
        title: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xff888888),
                ),
              ),
              Expanded(
                child: Text(
                  'Presensi',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GrenadineMVB',
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(
              //     Icons.filter_alt,
              //     color: Color(0xff53b6e2),
              //   ),
              // ),
              SizedBox(width: 40.sp),
            ],
          ),
        ),
        children: [
          Column(
            children: [
              Container(
                height: 0.46.sh,
                color: Colors.grey[300],
                padding: EdgeInsets.only(top: 50),
                child: currentLatLng == null
                    ? Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          FlutterMap(
                            // mapController: _mapController,
                            mapController: _animatedMapController.mapController,
                            options: MapOptions(
                              initialCenter: currentLatLng!,
                              initialZoom: 18,
                              onTap: (tapPosition, point) {
                                debugPrint('Tap di: $point');
                              },
                            ),
                            children: [
                              // Tile OpenStreetMap
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.flutter_map_demo',
                              ),

                              // Marker layer
                              CircleLayer(circles: _circles),
                              MarkerLayer(markers: _markers)
                            ],
                          ),
                          Positioned(
                            bottom: 50,
                            right: 6,
                            child: IconButton(
                              onPressed: () {
                                fitAllMarkers(dataLatLng!);
                              },
                              icon: Icon(Icons.location_on),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[50],
                                side:
                                    BorderSide(color: Colors.black26, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 6,
                            child: IconButton(
                              onPressed: () {
                                fitToUserLocation();
                              },
                              icon: Icon(Icons.my_location),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                side:
                                    BorderSide(color: Colors.black26, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
                width: double.infinity,
                color: bisaAbsen
                    ? Constants.primaryGreen.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    pesanJarakLokasi,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Container(
                      width: 0.7.sw,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Constants.primaryGreen.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_currentDate, ',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '$_currentTime',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: 13.sp, horizontal: 20.sp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.grey.withOpacity(0.3), // Warna bayangan
                            spreadRadius: 2, // Seberapa luas bayangan menyebar
                            blurRadius: 7, // Seberapa kabur/halus bayangan
                            offset: Offset(0, 3), // Posisi bayangan (x, y)
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 0.29.sw,
                                height: 0.09.sh,
                                // color: Colors.green,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/bg-datang.png'),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: BorderRadius.circular(15.sp),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Datang',
                                      style: TextStyle(
                                        fontFamily: 'GrenadineMVB',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      jamMasuk,
                                      style: TextStyle(
                                        fontFamily: 'GrenadineMVB',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Jam Kerja',
                                    style: TextStyle(
                                        fontFamily: 'GrenadineMVB',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 5),
                                  Icon(
                                    Icons.access_time,
                                    color: Constants.primaryYellow,
                                    size: 30.sp,
                                  ),
                                ],
                              ),
                              Container(
                                width: 0.29.sw,
                                height: 0.09.sh,
                                // color: Colors.blue,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/bg-pulang.png'),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: BorderRadius.circular(15.sp),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Pulang',
                                      style: TextStyle(
                                        fontFamily: 'GrenadineMVB',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      jamPulang,
                                      style: TextStyle(
                                        fontFamily: 'GrenadineMVB',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ButtonIcon(
                    labelColor: Colors.white,
                    bgColor: Constants.primaryYellow,
                    icon: Icon(Icons.login, color: Colors.white, size: 16),
                    label: Text(
                      'Check In',
                      style: TextStyle(
                          fontFamily: 'GrenadineMVB',
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      setState(() {
                        abseninout = 'IN';
                      });
                      popUpJenisAbsen(context);
                    },
                  ),
                  ButtonIcon(
                    labelColor: Colors.white,
                    bgColor: Constants.reject,
                    icon: Icon(Icons.logout, color: Colors.white, size: 16),
                    label: Text(
                      'Check Out',
                      style: TextStyle(
                          fontFamily: 'GrenadineMVB',
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (logHariIni.isEmpty) {
                        EasyLoading.showToast(
                          'Harap Check In terlebih dahulu.',
                          duration: const Duration(seconds: 1),
                        );
                      } else {
                        setState(() {
                          // untuk checkout jenis absen diambilkan dari data checkin sebelumnya
                          selectedJenisAbsen = logHariIni['auth_masuk'];
                          bisaAbsen = true;
                          abseninout = 'OUT';
                        });
                        popUpJenisAbsen(context);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              /*
              Center(
                child: Button(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    // bisaAbsen ? popUpJenisAbsen(context) : null;
                    popUpJenisAbsen(context);
                  },
                  child: Container(
                    width: 100.sp,
                    height: 40.sp,
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.sp),
                      // color: bisaAbsen ? Constants.primaryGreen : Colors.grey,
                      color: Constants.primaryGreen,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Warna bayangan
                          spreadRadius: 2, // Seberapa luas bayangan menyebar
                          blurRadius: 4, // Seberapa kabur/halus bayangan
                          offset: Offset(0, 3), // Posisi bayangan (x, y)
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ABSEN',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              */
              InfoLogAbsen(
                datang: logHariIni['jam_masuk'] ?? '--:--',
                pulang: logHariIni['jam_pulang'] ?? '--:--',
                jenisDatang: logHariIni['auth_masuk'] ?? '-',
                jenisPulang: logHariIni['auth_pulang'] ?? '-',
                moodDatang: logHariIni['mood_masuk'] ?? '-',
                moodPulang: logHariIni['mood_pulang'] ?? '-',
              )
            ],
          )
        ]);
  }
}

class ButtonMood extends StatelessWidget {
  final Function onPress;
  final bool selected;
  final String iconMood;
  final String label;

  const ButtonMood({
    required this.onPress,
    required this.selected,
    required this.iconMood,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPress(),
      child: Container(
        width: 0.16.sw,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
            color: selected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? Colors.blue : Colors.grey)),
        child: Column(
          children: [
            ImageUrl(url: iconMood, width: 45, height: 45),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class InfoLogAbsen extends StatelessWidget {
  final String datang;
  final String pulang;
  final String jenisDatang;
  final String jenisPulang;
  final String moodDatang;
  final String moodPulang;

  const InfoLogAbsen({
    super.key,
    required this.datang,
    required this.pulang,
    required this.jenisDatang,
    required this.jenisPulang,
    required this.moodDatang,
    required this.moodPulang,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 15.sp),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Constants.primaryYellow.withOpacity(0.2),
                border: Border(
                    top: BorderSide(color: Colors.grey),
                    bottom: BorderSide(color: Colors.grey))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    'Absensi',
                    style:
                        TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    'Jam',
                    style:
                        TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    'Jenis',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    'Mood',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    'Datang',
                    style:
                        TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    datang == '' ? '--:--' : datang,
                    style: TextStyle(fontSize: 10.sp),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    jenisDatang == '' ? '-' : jenisDatang,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: moodDatang == '-'
                      ? Text('-', textAlign: TextAlign.center)
                      : Image.network(
                          '${Constants.baseWebUrl}uploads/jenis_mood/${moodDatang}.png',
                          width: 20,
                          height: 20),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    'Pulang',
                    style:
                        TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    pulang == '' ? '--:--' : pulang,
                    style: TextStyle(fontSize: 10.sp),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: Text(
                    jenisPulang == '' ? '-' : jenisPulang,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
                SizedBox(
                  width: 0.2.sw,
                  child: moodPulang == '-'
                      ? Text('-', textAlign: TextAlign.center)
                      : Image.network(
                          '${Constants.baseWebUrl}uploads/jenis_mood/${moodPulang}.png',
                          width: 20,
                          height: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
