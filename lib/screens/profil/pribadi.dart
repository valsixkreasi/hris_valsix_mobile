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

class Pribadi extends StatefulWidget {
  const Pribadi({super.key});

  @override
  State<Pribadi> createState() => _PribadiState();
}

class _PribadiState extends State<Pribadi> {
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
      if (value != null) {
        Map<String, dynamic> profil = jsonDecode(value) as Map<String, dynamic>;
        setState(() {
          data = profil['pribadi'];
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
                    'DATA PRIBADI',
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
                          leading: Icon(Icons.person,
                              color: Colors.white, size: 18.sp),
                          title: Text('DATA PRIBADI',
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
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'NO. KTP :',
                                    value: data['no_ktp'] ?? '-'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.image),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'NO. KARTU KELUARGA :',
                                    value: data['no_kartu_keluarga'] ?? '-'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.image),
                              ),
                            ],
                          ),
                          InputView(
                              label: 'ALAMAT SESUAI KTP :',
                              value: data['alamat_ktp'] ?? '-'),
                          InputView(
                              label: 'ALAMAT DOMISILI :',
                              value: data['alamat_domisili'] ?? '-'),
                          InputView(
                              label: 'EMAIL :', value: data['email'] ?? '-'),
                          InputView(
                              label: 'TELEPON :',
                              value: data['telepon'] ?? '-'),
                        ],
                      ),
                    ),
                    Card(
                      color: Constants.primaryBlue,
                      child: ListTile(
                          leading: Icon(Icons.balance,
                              color: Colors.white, size: 18.sp),
                          title: Text('DATA PAJAK',
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
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'NO. NPWP :',
                                    value: data['npwp'] ?? '-'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.image),
                              ),
                            ],
                          ),
                          InputView(
                              label: 'PTKP :', value: data['ptkp'] ?? '-'),
                        ],
                      ),
                    ),
                    Card(
                      color: Constants.primaryBlue,
                      child: ListTile(
                          leading: Icon(Icons.local_hospital,
                              color: Colors.white, size: 18.sp),
                          title: Text('DATA ASURANSI',
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
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'BPJS KETENAGAKERJAAN :',
                                    value: data['bpjs_tenagakerja'] ?? '-'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.image),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'BPJS KESEHATAN :',
                                    value: data['bpjs_kesehatan'] ?? '-'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.image),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'DAPENBUN :',
                                    value: data['no_dapenbun'] ?? '-'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.image),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 9,
                                child: InputView(
                                    label: 'DPLK :',
                                    value: data['no_dplk'] ?? '-'),
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
                          leading: Icon(Icons.wallet,
                              color: Colors.white, size: 18.sp),
                          title: Text('DATA PENGGAJIAN',
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
                              label: 'PAYROLL AREA :',
                              value: data['payroll_area'] ?? '-'),
                          InputView(
                              label: 'BANK :', value: data['bank'] ?? '-'),
                          InputView(
                              label: 'NO. REKENING :',
                              value: data['no_rekening'] ?? '-'),
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
