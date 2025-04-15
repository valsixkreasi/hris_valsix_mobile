import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/buttonicon.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/components/infopegawaihome.dart';
import 'package:hris/components/mainmenuhome.dart';
import 'package:hris/components/infocuti.dart';
import 'package:hris/components/overlaymenu.dart';
import 'package:hris/components/rflutter_alert/rflutter_alert.dart';
import 'package:hris/components/rflutter_alert/src/alert.dart';
import 'package:hris/components/rflutter_alert/src/constants.dart';
import 'package:hris/components/rflutter_alert/src/dialog_button.dart';
import 'package:hris/components/textinput.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/models/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String password = '';
  String passwordUlang = '';

  Future<void> ubahPasswordbak(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubah Password'),
          content: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                right: -40,
                top: -70,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close),
                  ),
                ),
              ),
              Form(
                // key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextInput(
                        label: 'Password Baru :',
                        initialValue: '',
                        onchanged: (p0) {
                          setState(() {
                            // nama = p0!;
                          });
                        },
                        // required: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextInput(
                        label: 'Ulangi Password :',
                        initialValue: '',
                        onchanged: (p0) {
                          setState(() {
                            // nama = p0!;
                          });
                        },
                        // required: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        child: const Text('Submit'),
                        onPressed: () {
                          // if (_formKey.currentState!.validate()) {
                          //   _formKey.currentState!.save();
                          // }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> ubahPassword() async {
    Alert(
      context: context,
      type: AlertType.none,
      title: "Ubah Password",
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextInput(
              label: 'Password Baru :',
              initialValue: password,
              required: true,
              obscureText: true,
              onchanged: (p0) {
                setState(() {
                  password = p0!;
                });
              },
            ),
            SizedBox(height: 20.sp),
            TextInput(
              label: 'Ulangi Password :',
              initialValue: passwordUlang,
              required: true,
              obscureText: true,
              onchanged: (p0) {
                setState(() {
                  passwordUlang = p0!;
                });
              },
            ),
          ],
        ),
      ),
      buttons: [
        DialogButton(
          child: Text(
            'Submit',
            style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontFamily: 'GrenadineMVB',
                fontWeight: FontWeight.w800),
          ),
          onPressed: () {
            Navigator.pop(context);
            Future.delayed(const Duration(milliseconds: 100), () {
              if (_formKey.currentState!.validate()) {
                submitUbah();
              }
            });
          },
          width: 120,
          color: Constants.primaryBlue,
        ),
        DialogButton(
          child: Text(
            'Batal',
            style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontFamily: 'GrenadineMVB',
                fontWeight: FontWeight.w800),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
          color: Constants.primaryYellow,
        ),
      ],
    ).show();
  }

  Future<void> submitUbah() async {
    Map<String, String> body = {
      'password': password,
    };

    var response = await Constants.postJson('ubah-password', body);
    Map<String, dynamic> responseJson = {};
    try {
      responseJson = jsonDecode(response) as Map<String, dynamic>;
    } on FormatException {
      EasyLoading.showToast(
        'Network error!',
        duration: const Duration(seconds: 1),
      );
    }

    print(responseJson);

    if (responseJson['status'] == 'success') {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 2),
      );
      setState(() {
        password = '';
        passwordUlang = '';
      });
    } else {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 1),
      );
      ubahPassword();
    }
  }

  void logout(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    });
  }

  void download(String url, String fileName) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      final baseStorage1 =
          await getExternalStorageDirectories(type: StorageDirectory.downloads);
      final Directory? downloadsDir = await getDownloadsDirectory();
      print('baseStorage => ${baseStorage}');
      print('baseStorage1 => ${baseStorage1}');
      print('downloadsDir => ${downloadsDir}');

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        fileName: fileName,
        headers: {}, // optional: header send with url (auth token etc)
        // savedDir: baseStorage!.path,
        savedDir: downloadsDir!.path,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    }
  }

  void downloadFile(String url, String name) async {
    final File? file = await FileDownloader.downloadFile(
        url: url,
        name: name,
        notificationType: NotificationType.all,
        onProgress: (String? fileName, double progress) {
          print('FILE fileName HAS PROGRESS $progress');
        },
        onDownloadCompleted: (String path) {
          print('FILE DOWNLOADED TO PATH: $path');
        },
        onDownloadError: (String error) {
          print('DOWNLOAD ERROR: $error');
        });

    print('FILE: ${file?.path}');
  }

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HomeModel homeData = context.watch<HomeModel>();
    Map<String, dynamic> data = homeData.data;
    Map<String, dynamic> profil = {};
    Map<String, dynamic> presensi = {};
    List<dynamic> peraturan = [];
    String cetak_cv = '';

    if (data.isNotEmpty) {
      if (data.containsKey('profil')) {
        profil = data['profil'];
        // print(profil);
      }
      if (data.containsKey('presensi')) {
        presensi = data['presensi'];
      }
      if (data.containsKey('peraturan')) {
        peraturan = data['peraturan'];
      }

      cetak_cv = data['cetak_cv'];

      EasyLoading.dismiss();
    }

    List<Map<String, dynamic>> menu = [
      {
        'title': 'Pengajuan Cuti',
        'icon': 'assets/images/icons8-working_with_papers.png',
        'route': ''
      },
      {
        'title': 'Data Presensi',
        'icon': 'assets/images/icons8-fingerprint.png',
        'route': ''
      },
      {
        'title': 'Aturan Perusahaan',
        'icon': 'assets/images/icons8-open_book.png',
        'route': ''
      },
      {
        'title': 'Kalendar Perusahaan',
        'icon': 'assets/images/icons8-tear-off_calendar.png',
        'route': ''
      },
      {
        'title': 'Slip Gaji',
        'icon': 'assets/images/icons8-bill.png',
        'route': ''
      },
      {
        'title': 'Reimburse',
        'icon': 'assets/images/icons8-refund.png',
        'route': ''
      },
    ];

    List<dynamic> notifikasi = [
      {
        'title': 'Permohonan cuti tahunan nomor 22/PJBS/111/2025',
        'tanggal': '1 Maret 2025',
        'status': 'Menuggu persetujuan Manager',
      },
    ];

    List<dynamic> jadwalTraining = [
      {
        'title': 'Menguasai Pengetahuan Tentang Wisata Agro ',
        'penyelenggara': 'Kemnaker RI',
        'tanggal': '16 Januari 2025',
        'jam': '08:00',
        'lokasi': 'Gedung Vokasi Kemnaker',
      },
      {
        'title': 'Menguasai Pengetahuan ',
        'penyelenggara': 'Kemnaker RI',
        'tanggal': '16 Januari 2025',
        'jam': '08:00',
        'lokasi': 'Gedung Vokasi Kemnaker',
      },
      {
        'title': 'Menguasai Pengetahuan Tentang Wisata Agro ',
        'penyelenggara': 'Kemnaker RI',
        'tanggal': '16 Januari 2025',
        'jam': '08:00',
        'lokasi': 'Gedung Vokasi Kemnaker',
      },
    ];

    return RefreshIndicator(
        onRefresh: () async {
          homeData.fetch().then((value) {
            EasyLoading.show(
                status: 'Loading...', maskType: EasyLoadingMaskType.black);
          });
        },
        child: NavHeader(
          scaffoldKey: scaffoldKey,
          showDrawer: false,
          title: Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 6.sp),
                  child: Image.asset(
                    'assets/images/logo_ptpn1.png',
                    width: 40.sp,
                    height: 40.sp,
                  ),
                ),
                SizedBox(
                  // margin: EdgeInsets.only(right: 10.sp),
                  // color: Colors.amber,
                  width: 0.68.sw,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'HRIS  ',
                        // textAlign: TextAlign.start,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'GrenadineMVB',
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Application',
                        style: TextStyle(
                          fontFamily: 'GrenadineMVB',
                          fontSize: 11.sp,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(
                //   width: 0.1.sw,
                //   // padding: EdgeInsets.all(6.sp),
                //   // color: Colors.grey,
                //   child: Container(
                //     width: 30.sp,
                //     height: 30.sp,
                //     padding: EdgeInsets.all(10.sp),
                //     // color: Colors.green,
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Color(0xffececec),
                //     ),
                //     child: Image.asset(
                //       'assets/images/icons8-menu.png',
                //       // width: 10.sp,
                //       // height: 10.sp,
                //       color: Colors.black,
                //     ),
                //   ),
                // ),
                Expanded(
                  child: Container(
                    // color: Colors.amber,
                    alignment: Alignment.centerRight,
                    child: OverlayMenu(
                      icons: const [
                        Icon(Icons.logout),
                        Icon(Icons.lock),
                      ],
                      texts: const [
                        Text('Logout'),
                        Text('Ubah Password'),
                      ],
                      borderRadius: BorderRadius.circular(6.sp),
                      backgroundColor: Color(0xffececec),
                      iconColor: Colors.black,
                      onChange: (index) {
                        if (index == 0) {
                          logout(context);
                        } else if (index == 1) {
                          ubahPassword();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            // AREA INFORMASI PROFIL
            Container(
              width: 1.sw,
              height: 0.63.sh,
              padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
              child: Stack(
                children: [
                  // AREA BG MAIN MENU
                  Positioned(
                    top: 0.42.sh,
                    // width: 0.92.sw,
                    // height: 0.22.sh,
                    child: Container(
                      width: 0.92.sw,
                      height: 0.19.sh,
                      // color: Color(0xffcccccc),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/bg-main-menu.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: null,
                    ),
                  ),
                  // AREA MAIN MENU
                  Positioned(
                    top: 0.44.sh,
                    child: Container(
                      width: 0.92.sw,
                      // color: Colors.grey,
                      padding: EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 6.sp,
                        runSpacing: 6.sp,
                        children: [
                          ...List.generate(menu.length, (index) {
                            Map<String, dynamic> menuItem = menu[index];
                            String icon = menuItem['icon'];
                            String title = menuItem['title'];
                            String route = menuItem['route'];
                            return Button(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                if (route == '') {
                                  EasyLoading.showToast(
                                    'Modul dalam pengembangan.',
                                    duration: const Duration(seconds: 1),
                                  );
                                } else {
                                  Navigator.pushNamed(context, route);
                                }
                              },
                              child: MainMenuHome(
                                iconPath: icon,
                                title: title,
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ),
                  // AREA INFORMASI PEGAWAI
                  Container(
                    margin: EdgeInsets.only(top: 0.1.sh),
                    // alignment: Alignment.topLeft,
                    height: 0.34.sh,
                    // color: Color(0xff24cc43),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      // color: Color(0xff24cc43),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xff24cc43),
                          Color(0xff1eb93b),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 10.sp),
                              width: 0.15.sw,
                              child: Image.asset(
                                'assets/images/foto.png',
                                height: 37.sp,
                                width: 37.sp,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              // color: Color(0xff888888),
                              // height: 0.12.sh,
                              width: 0.75.sw,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat datang',
                                    style: TextStyle(
                                      fontFamily: 'GrenadineMVB',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    profil['pegawai'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'GrenadineMVB',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    profil['nrp'],
                                    style: TextStyle(
                                      fontFamily: 'GrenadineMVB',
                                      fontWeight: FontWeight.normal,
                                      fontSize: 10.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    profil['jabatan'],
                                    style: TextStyle(
                                      fontFamily: 'GrenadineMVB',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10.sp,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1.sw,
                          height: 0.06.sh,
                          padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
                          // color: Color(0xff1fb239),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff20b73c), Color(0xff189c30)],
                          )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profil['regional'] + ' - ' + profil['area'],
                                style: TextStyle(
                                  fontFamily: 'GrenadineMVB',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.sp,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                profil['struktur_organ'],
                                style: TextStyle(
                                  fontFamily: 'GrenadineMVB',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 9.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InfoPegawaiHome(
                              iconPath: 'assets/images/icons8-profile.png',
                              title: 'Status',
                              desc: profil['status_pegawai'],
                            ),
                            InfoPegawaiHome(
                              iconPath: 'assets/images/icons8-meeting_time.png',
                              title: 'Kelompok',
                              desc: profil['kelompok_shift'],
                            ),
                            Expanded(
                              child: Container(
                                height: 40.sp,
                                alignment: Alignment.bottomRight,
                                padding:
                                    const EdgeInsets.only(right: 10, bottom: 3),
                                // color: Colors.white,
                                child: UnconstrainedBox(
                                  child: ButtonIcon(
                                    labelColor: Colors.white,
                                    bgColor: Color(0xff53b6e2),
                                    icon: Icon(Icons.person,
                                        color: Colors.white, size: 16),
                                    label: Text(
                                      'Profil Saya',
                                      style: TextStyle(
                                          fontFamily: 'GrenadineMVB',
                                          fontSize: 10),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/identitas');
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            InfoPegawaiHome(
                              iconPath: 'assets/images/icons8-management.png',
                              title: 'Employee Group',
                              desc: profil['kelompok_pegawai'],
                            ),
                            Expanded(
                              child: Container(
                                height: 40.sp,
                                alignment: Alignment.topRight,
                                padding:
                                    const EdgeInsets.only(right: 10, top: 3),
                                // color: Colors.white,
                                child: UnconstrainedBox(
                                  child: ButtonIcon(
                                    labelColor: Colors.white,
                                    bgColor: Color(0xfffdbd5e),
                                    icon: Icon(Icons.print,
                                        color: Colors.white, size: 16),
                                    label: Text(
                                      'Cetak CV',
                                      style: TextStyle(
                                          fontFamily: 'GrenadineMVB',
                                          fontSize: 10),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/viewpdf',
                                          arguments: {
                                            'url': cetak_cv,
                                            'title': 'Cetak CV',
                                          });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // AREA INFO JAM DATANG - PULANG
            Container(
              height: 0.1.sh,
              width: 0.92.sw,
              padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
              // color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 0.4.sw,
                    padding: EdgeInsets.only(
                      top: 8.sp,
                      right: 10.sp,
                    ),
                    // color: Colors.amber,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg-jadwal-masuk.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Jadwal masuk hari ini :',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Datang : ${presensi['jadwal_masuk']}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Pulang : ${presensi['jadwal_pulang']}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 0.21.sw,
                    padding: EdgeInsets.only(top: 8.sp),
                    // color: Colors.green,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg-datang.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/icons8-walking.png',
                          width: 21.sp,
                          height: 21.sp,
                        ),
                        Text(
                          'Datang',
                          style: TextStyle(
                            // fontFamily: 'GrenadineMVB',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          presensi['absensi_masuk'],
                          style: TextStyle(
                            fontFamily: 'GrenadineMVB',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 0.21.sw,
                    padding: EdgeInsets.only(top: 8.sp),
                    // color: Colors.blue,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg-pulang.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/icons8-walking.png',
                          width: 21.sp,
                          height: 21.sp,
                          color: Color(0xfffdbd5e),
                        ),
                        Text(
                          'Pulang',
                          style: TextStyle(
                            // fontFamily: 'GrenadineMVB',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          presensi['absensi_pulang'],
                          style: TextStyle(
                            fontFamily: 'GrenadineMVB',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // AREA INFO CUTI
            Container(
              width: 0.91.sw,
              // height: 0.1.sh,
              padding: EdgeInsets.only(
                  left: 15.sp, right: 15.sp, top: 15.sp, bottom: 15.sp),
              // color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoCuti(
                    iconPath: 'assets/images/icons8-holiday.png',
                    title: 'Cuti Tahunan ${presensi['cuti_tahun']}',
                    ambil: presensi['cuti_tahunan_total'],
                    sisa: presensi['cuti_tahunan_sisa'],
                  ),
                  InfoCuti(
                    iconPath: 'assets/images/icons8-kitesurfing.png',
                    title: 'Cuti Panjang ${presensi['cuti_tahun']}',
                    ambil: presensi['cuti_panjang_total'],
                    sisa: presensi['cuti_panjang_sisa'],
                  ),
                ],
              ),
            ),
            // AREA NOTIFIKASI
            Container(
              // height: 0.6.sh,
              width: 1.sw,
              padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
              // color: Color(0xffcccccc),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6.sp),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: Color(0xffcccccc),
                          width: 0.7,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifikasi : ',
                          style: TextStyle(
                            fontFamily: 'GrenadineMVB',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Lihat semua >',
                          style: TextStyle(
                            fontFamily: 'GrenadineMVB',
                            fontSize: 9.sp,
                            color: Color(0xffff5055),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xffff5055),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    // color: Colors.white,
                    width: 1.sw,
                    padding: EdgeInsets.all(10.sp),
                    margin: EdgeInsets.only(top: 10.sp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.sp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ...List.generate(notifikasi.length, (index) {
                          Map<String, dynamic> itemNotifikasi =
                              notifikasi[index];
                          String tanggal = itemNotifikasi['tanggal'];
                          String title = itemNotifikasi['title'];
                          String status = itemNotifikasi['status'];
                          return Container(
                            padding: EdgeInsets.only(top: 8.sp, bottom: 8.sp),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xffcccccc),
                                  width: 0.7.sp,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  // color: Color(0xffffffff),
                                  padding: EdgeInsets.all(8.sp),
                                  decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: Colors.grey.withOpacity(0.1),
                                      shape: BoxShape.circle),
                                  child: Image.asset(
                                    'assets/images/icons8-alarm.png',
                                    width: 18.sp,
                                    height: 18.sp,
                                  ),
                                ),
                                Container(
                                  width: 0.76.sw,
                                  // color: Color(0xffcccccc),
                                  padding: EdgeInsets.only(left: 10.sp),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tanggal,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontFamily: 'GrenadineMVB',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '[ $status ]',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        })
                      ],
                    ),
                  )
                ],
              ),
            ),
            // AREA Peraturan
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.sp),
              margin: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
              child: Container(
                width: 1.sw,
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.sp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 0.91.sw,
                      padding: EdgeInsets.symmetric(vertical: 8.sp),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xffcccccc),
                            width: 0.7.sp,
                          ),
                        ),
                      ),
                      child: Text(
                        'Peraturan & Download Dokumen : ',
                        style: TextStyle(
                          fontFamily: 'GrenadineMVB',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...List.generate(peraturan.length, (index) {
                      Map<String, dynamic> itemPeraturan = peraturan[index];
                      String namaPeraturan = itemPeraturan['nama'];
                      String nomorPeraturan = itemPeraturan['kode'];
                      String tanggalPeraturan = itemPeraturan['tanggal'];
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 8.sp),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xffcccccc),
                              width: 0.7.sp,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 0.7.sw,
                              // color: Color(0xff888888),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    namaPeraturan,
                                    style: TextStyle(
                                      fontFamily: 'GrenadineMVB',
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'No. SK : $nomorPeraturan',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Color(0xff888888),
                                        ),
                                      ),
                                      Text(
                                        'Tanggal : $tanggalPeraturan',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Color(0xff888888),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Button(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                // download(itemPeraturan['dokumen'],
                                //     '${itemPeraturan['nama']}.pdf');
                                downloadFile(itemPeraturan['dokumen'],
                                    '${itemPeraturan['nama']}.pdf');
                              },
                              child: Container(
                                width: 30.sp,
                                height: 30.sp,
                                padding: EdgeInsets.all(10.sp),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // ignore: deprecated_member_use
                                  color: Color(0xffcccccc).withOpacity(0.2),
                                ),
                                child: Image.asset(
                                  'assets/images/icons8-download.png',
                                  width: 10.sp,
                                  height: 10.sp,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    Container(
                      width: 0.91.sw,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(top: 10.sp),
                      child: UnconstrainedBox(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 6.sp,
                              bottom: 6.sp,
                              left: 10.sp,
                              right: 10.sp),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xffcccccc),
                                width: 0.7.sp,
                              ),
                              borderRadius: BorderRadius.circular(20.sp)),
                          child: Text(
                            'Lihat semua dokumen',
                            style: TextStyle(
                              fontFamily: 'GrenadineMVB',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // AREA JADWAL TRAINING
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.sp),
              margin: EdgeInsets.only(bottom: 10.sp),
              child: Container(
                width: 1.sw,
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.sp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 0.91.sw,
                      padding: EdgeInsets.symmetric(vertical: 8.sp),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xffcccccc),
                            width: 0.7.sp,
                          ),
                        ),
                      ),
                      child: Text(
                        'Jadwal Training & Sertifikasi : ',
                        style: TextStyle(
                          fontFamily: 'GrenadineMVB',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(top: 10.sp),
                      child: Row(
                        children: [
                          ...List.generate(jadwalTraining.length, (index) {
                            Map<String, dynamic> itemJadwal =
                                jadwalTraining[index];
                            return Container(
                              width: 0.5.sw,
                              height: 100.sp,
                              padding: EdgeInsets.all(10.sp),
                              margin: EdgeInsets.only(right: 10.sp),
                              decoration: BoxDecoration(
                                // color: Color(0xfff2f2f2),
                                border: Border.all(
                                    color: Color(0xffcccccc), width: 0.7.sp),
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 35.sp,
                                    child: Text(
                                      itemJadwal['title'],
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'GrenadineMVB',
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 6.sp),
                                        child: Image.asset(
                                          'assets/images/icons8-neighbor.png',
                                          width: 8.sp,
                                          height: 8.sp,
                                        ),
                                      ),
                                      Text(
                                        'Penyelenggara : ' +
                                            itemJadwal['penyelenggara'],
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 6.sp),
                                        child: Image.asset(
                                          'assets/images/icons8-tear-off_calendar.png',
                                          width: 8.sp,
                                          height: 8.sp,
                                        ),
                                      ),
                                      Text(
                                        itemJadwal['tanggal'],
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 6.sp),
                                        child: Image.asset(
                                          'assets/images/icons8-location.png',
                                          width: 8.sp,
                                          height: 8.sp,
                                        ),
                                      ),
                                      Text(
                                        itemJadwal['lokasi'],
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                    Container(
                      width: 0.91.sw,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(top: 10.sp),
                      child: UnconstrainedBox(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 6.sp,
                              bottom: 6.sp,
                              left: 10.sp,
                              right: 10.sp),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xffcccccc),
                                width: 0.7.sp,
                              ),
                              borderRadius: BorderRadius.circular(20.sp)),
                          child: Text(
                            'Lihat jadwal training',
                            style: TextStyle(
                              fontFamily: 'GrenadineMVB',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
