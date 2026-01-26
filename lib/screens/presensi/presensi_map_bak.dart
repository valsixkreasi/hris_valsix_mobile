import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:hris/components/buttonicon.dart';
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

class _PresensiMapState extends State<PresensiMap> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  final Map<String, RadioGroupController> radioGroupControllers = {};
  final Map<String, GlobalKey<RadioGroupState>> radioKeys = {};

  bool isLoadLokasi = true;
  final List<Marker> _markers = [];
  final List<CircleMarker> _circles = [];
  LatLng? currentLatLng;
  List<LatLng>? dataLatLng;
  String latitude = "";
  String longitude = "";
  double latitudeDev = -7.3207402411194955;
  double longitudeDev = 112.76273070269497;
  String currentTimeZone = "";
  String alamat = "";
  List<Map<String, dynamic>> dataLokasi = [];
  final List<Map<String, dynamic>> jenisAbsen = [];
  Timer? _timer;
  String pesanJarakLokasi = "-";
  bool bisaAbsen = false;
  String jamMasuk = '--:--';
  String jamPulang = '--:--';
  String _currentDate = "";
  String _currentTime = "";
  String selectedJenisAbsen = "";
  String selectedSubJenisAbsen = "";

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
        // currentLatLng = LatLng(position.latitude, position.longitude);
        // latitude = '${position.latitude}';
        // longitude = '${position.longitude}';
        currentLatLng = LatLng(latitudeDev, longitudeDev);
        latitude = '$latitudeDev';
        longitude = '$longitudeDev';
        _markers.add(
          Marker(
            // point: LatLng(position.latitude, position.longitude),
            point: LatLng(latitudeDev, longitudeDev),
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
          radius: 20, // Radius dalam satuan (lihat useRadiusInMeter)
          useRadiusInMeter: true, // Radius dihitung dalam meter
          color: Colors.blue.withOpacity(0.3), // Warna isi lingkaran
          borderColor: Colors.blue, // Warna garis tepi
          borderStrokeWidth: 1, // Ketebalan garis tepi
        );
      }).toList();
      setState(() {
        dataLokasi = arrLokasi; // simpan data lokasi kerja yg asli
        dataLatLng =
            points; // data point lokasi agar semua lokasi bisa terlihat pada map
        _markers.addAll(arrMarker); // data untuk menandai lokasi dengan pin
        _circles
            .addAll(arrCircle); // data untuk menandai lokasi dengan lingkaran
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
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(50),
      ),
    );
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
      if (kDebugMode) inRadius = true;

      if (jarakMeter <= radiusMax) {
        inRadius = true;
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
      List<dynamic> arrData = value['jenis_absen'];
      List<Map<String, dynamic>> arrJenis =
          arrData.map((e) => e as Map<String, dynamic>).toList();
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
      setState(() {
        jenisAbsen.addAll(arrJenis);
      });
      EasyLoading.dismiss();
    });
  }

  Future<void> kirimAbsensi(BuildContext context) async {
    if (selectedJenisAbsen == "") {
      return EasyLoading.showToast(
        'Harap pilih jenis absensi dahulu.',
        duration: const Duration(seconds: 1),
      );
    }
    EasyLoading.show(status: 'Prosess Absensi...');
    Map<String, String> body = {
      'reqJam': DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
      'reqLongitude': latitude,
      'reqLatitude': longitude,
      'reqLokasiKerjaId': 'CAB-HA00',
      'reqAlat': 'MAPS',
      'reqInterval': '0',
      'reqPlatform': Platform.isAndroid ? 'ANDROID' : 'IOS',
      'reqGmt': '${DateTime.now().timeZoneOffset.inHours}',
      'reqTimeZone': currentTimeZone,
      'reqJenisAbsen': '$selectedJenisAbsen',
      'reqSubJenisAbsen': '$selectedSubJenisAbsen',
      'reqAlamat': alamat
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
      EasyLoading.dismiss();
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 2),
      );
      Navigator.pop(context);
    } else {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 1),
      );
    }
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
              title: const Text("Pilih Jenis Absen"),
              titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              content: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Agar dialog tidak memenuhi layar
                  children: [
                    ...jenisAbsen.map((item) {
                      final String controllerKode =
                          item['kode'].replaceAll(" ", "");
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Divider(height: 1.0),
                          // bungkus dengan Theme utk menyesuaikan jarak / padding
                          Theme(
                            data: Theme.of(context).copyWith(
                              listTileTheme: const ListTileThemeData(
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
                                });
                                if (item['sub_jenis'].length > 0) {
                                  // Memilih item pertama pada sub jenis
                                  radioGroupControllers[controllerKode]!
                                      .selectAt(0);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: item['sub_jenis'].length > 0
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: RadioGroup(
                                      key: radioKeys[controllerKode],
                                      controller:
                                          radioGroupControllers[controllerKode],
                                      values:
                                          item['sub_jenis'], // data array jenis
                                      // indexOfDefault = default selected, -1 artinya tidak ada yg terpilih.
                                      indexOfDefault: -1,
                                      orientation:
                                          RadioGroupOrientation.horizontal,
                                      decoration: RadioGroupDecoration(
                                          horizontalAlignment:
                                              WrapAlignment.spaceBetween),
                                      // labelBuilder = label radio button
                                      labelBuilder: (value) => Text(value),
                                      // Logika pembeda di sini
                                      onChanged: (value) {
                                        if (value != null) {
                                          // Jalankan pembersihan grup lain SEGERA SETELAH frame saat ini selesai
                                          Future.microtask(() {
                                            setDialogState(() {
                                              selectedJenisAbsen = item['kode'];
                                              selectedSubJenisAbsen = value;
                                              radioGroupControllers
                                                  .forEach((key, controller) {
                                                // Jika ID tidak sama dengan yang diklik, reset controller-nya
                                                if (key != controllerKode) {
                                                  // Pastikan controller masih memiliki widget yang menempel
                                                  controller.value =
                                                      null; // membuat sub jenis yg lainnya unselect
                                                }
                                              });
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
                    }).toList(),
                    Divider(height: 1.0),
                  ]),
              actions: [
                ButtonIcon(
                  labelColor: Colors.white,
                  bgColor: Constants.primaryBlue,
                  icon: Icon(Icons.send, color: Colors.white, size: 16),
                  label: Text(
                    'KIRIM',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    kirimAbsensi(context);
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
                height: 0.5.sh,
                color: Colors.grey[300],
                // padding:
                //     EdgeInsets.only(left: 15, top: 70, right: 15, bottom: 15),
                child: currentLatLng == null
                    ? Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: _mapController,
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
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Constants.primaryGreen.withOpacity(0.3),
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
                ),
              ),
              SizedBox(height: 10.sp),
              Center(
                child: Button(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    bisaAbsen ? popUpJenisAbsen(context) : null;
                  },
                  child: Container(
                    width: 100.sp,
                    height: 40.sp,
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.sp),
                      color: bisaAbsen ? Constants.primaryGreen : Colors.grey,
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
              Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 10.sp, horizontal: 20.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // Warna bayangan
                        spreadRadius: 2, // Seberapa luas bayangan menyebar
                        blurRadius: 7, // Seberapa kabur/halus bayangan
                        offset: Offset(0, 3), // Posisi bayangan (x, y)
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Jam Kerja',
                        style: TextStyle(
                            fontFamily: 'GrenadineMVB',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 0.29.sw,
                            height: 0.1.sh,
                            // color: Colors.green,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/bg-datang.png'),
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
                          Icon(
                            Icons.access_time,
                            color: Constants.primaryYellow,
                            size: 30.sp,
                          ),
                          Container(
                            width: 0.29.sw,
                            height: 0.1.sh,
                            // color: Colors.blue,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/bg-pulang.png'),
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
              )
            ],
          )
        ]);
  }
}
