import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/inputview.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/configs/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> _getData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('profil');
}

class TanggalAcuan extends StatefulWidget {
  const TanggalAcuan({super.key});

  @override
  State<TanggalAcuan> createState() => _TanggalAcuanState();
}

class _TanggalAcuanState extends State<TanggalAcuan> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Map<String, dynamic> data = {};

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    Timer(const Duration(seconds: 1), () {
      getData();
    });
    super.initState();
  }

  void getData() {
    _getData().then((value) {
      // print(value);
      if (value != null) {
        Map<String, dynamic> profil = jsonDecode(value) as Map<String, dynamic>;

        setState(() {
          data = profil['tanggal_acuan'];
        });
      }
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: () async {
        EasyLoading.show(
            status: 'Loading...', maskType: EasyLoadingMaskType.black);
        Timer(const Duration(seconds: 1), () {
          getData();
        });
      },
      child: NavHeader(
          showBottomNavigationBar: false,
          showDrawer: true,
          scaffoldKey: scaffoldKey,
          title: Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(builder: (context) {
                  return IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: Icon(Icons.menu, color: Color(0xff888888)),
                  );
                }),
                Expanded(
                  child: Text(
                    'TANGGAL ACUAN',
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
                IconButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (_) => false);
                  },
                  icon: Icon(Icons.home_filled, color: Color(0xff53b6e2)),
                ),
              ],
            ),
          ),
          children: [
            Stack(children: [
              Container(
                width: 1.sw,
                // height: 1.sh - ScreenUtil().statusBarHeight,
                padding:
                    EdgeInsets.symmetric(vertical: 20.sp, horizontal: 10.sp),
                margin: EdgeInsets.only(top: 40.sp),
                // color: Color(0xffcccccc),
                child: Column(
                  children: [
                    Card(
                      color: Constants.primaryBlue,
                      child: ListTile(
                          leading: Icon(Icons.file_open,
                              color: Colors.white, size: 18.sp),
                          title: Text('DATA KONTRAK',
                              style: TextStyle(
                                  fontFamily: 'GrenadineMVB',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          // tileColor: Colors.cyan,
                          minTileHeight: 20),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.sp, vertical: 8.sp),
                      child: Column(
                        children: [
                          InputView(
                              label: 'TANGGAL BERGABUNG :',
                              value: data['tanggal_bergabung'] ?? '-'),
                          InputView(
                              label: 'TANGGAL MASA PERCOBAAN :',
                              value: data['tanggal_masa_percobaan'] ?? '-'),
                          InputView(
                              label: 'TGL. PENGANGKATAN KARYAWAN TETAP :',
                              value:
                                  data['tanggal_pengangkatan_karyawan_tetap'] ??
                                      '-'),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'SK PENGANGKATAN',
                                    value: data['no_sk_pengangkatan'] ?? '-'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.image),
                              ),
                            ],
                          ),
                          InputView(
                              label: 'TGL. PENGANGKATAN KARYAWAN KARPIM :',
                              value:
                                  data['tanggal_pengangkatan_karpim'] ?? '-'),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'SK PENGANGKATAN KARPIM :',
                                    value: data['no_sk_karpim'] ?? '-'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.image),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Card(
                      color: Constants.primaryBlue,
                      child: ListTile(
                          leading: Icon(Icons.calendar_month,
                              color: Colors.white, size: 18.sp),
                          title: Text('DATA TANGGAL',
                              style: TextStyle(
                                  fontFamily: 'GrenadineMVB',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          // tileColor: Colors.cyan,
                          minTileHeight: 20),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.sp, vertical: 8.sp),
                      child: Column(
                        children: [
                          InputView(
                              label: 'TANGGAL MBT :',
                              value: data['tanggal_mbt'] ?? '-'),
                          InputView(
                              label: 'TANGGAL PENSIUN :',
                              value: data['tanggal_pensiun'] ?? '-'),
                          InputView(
                              label: 'TANGGAL ACUAN CUTI TAHUNAN :',
                              value: data['tanggal_acuan_cuti_tahunan'] ?? '-'),
                          InputView(
                              label: 'TANGGAL ACUAN CUTI PANJANG :',
                              value: data['tanggal_acuan_cuti_panjang'] ?? '-'),
                          InputView(
                              label: 'TANGGAL ACUAN PERHITUNGAN MASA KERJA :',
                              value: data['tanggal_acuan_masa_kerja'] ?? '-'),
                          InputView(
                              label: 'TANGGAL ACUAN JUBILIUM :',
                              value: data['tanggal_acuan_jubilium'] ?? '-'),
                          InputView(
                              label: 'TANGGAL ACUAN SHT :',
                              value: data['tanggal_acuan_sht'] ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ]),
    );
  }
}
