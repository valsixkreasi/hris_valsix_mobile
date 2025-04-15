import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/inputview.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/models/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Identitas extends StatefulWidget {
  const Identitas({super.key});

  @override
  State<Identitas> createState() => _IdentitasState();
}

class _IdentitasState extends State<Identitas> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ApiModel model = ApiModel(ApiUrl.profil.view);

  Map<String, dynamic> data = {};

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    model.postJson().then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profil', jsonEncode(value));
      setState(() {
        data = value['identitas'];
      });

      EasyLoading.dismiss();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: () async {
        EasyLoading.show(
            status: 'Loading', maskType: EasyLoadingMaskType.black);
        model.postJson().then((value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('profil', jsonEncode(value));
          setState(() {
            data = value['identitas'];
          });
          EasyLoading.dismiss();
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
                    'PROFIL PEGAWAI',
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
              Material(
                child: Container(
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
                            title: Text('PROFIL',
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
                                  flex: 5,
                                  child: InputView(
                                      label: 'NIK SAP :',
                                      value: data['ni_sap'] ?? '-'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'LAMA :',
                                      value: data['nik_lama'] ?? '-'),
                                ),
                              ],
                            ),
                            InputView(
                                label: 'NAMA PEGAWAI :',
                                value: data['nama'] ?? '-'),
                            Row(
                              spacing: 10.sp,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'TEMPAT',
                                      value: data['tempat_lahir'] ?? '-'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'TGL. LAHIR :',
                                      value: data['tanggal_lahir'] ?? '-'),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10.sp,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'JENIS KELAMIN :',
                                      value: data['jenis_kelamin'] ?? '-'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'STATUS NIKAH :',
                                      value: data['status_nikah'] ?? '-'),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10.sp,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'AGAMA :',
                                      value: data['agama'] ?? '-'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'SUKU :',
                                      value: data['suku'] ?? '-'),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10.sp,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'GOL. DARAH :',
                                      value: data['golongan_darah'] ?? '-'),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: InputView(
                                      label: 'STATUS :',
                                      value: data['status'] ?? '-'),
                                ),
                              ],
                            ),
                            InputView(
                                label: 'PENUGASAN KE :',
                                value: data['penugasan_ke'] ?? '-'),
                          ],
                        ),
                      ),
                      Card(
                        color: Constants.primaryBlue,
                        child: ListTile(
                            leading: Icon(Icons.location_on_outlined,
                                color: Colors.white, size: 18.sp),
                            title: Text('PENUGASAN',
                                style: TextStyle(
                                    fontFamily: 'GrenadineMVB',
                                    fontSize: 12.sp,
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
                                label: 'PERSONNEL AREA :',
                                value: data['regional'] ?? '-'),
                            InputView(
                                label: 'PERSONNEL AREA (HRIS) :',
                                value: data['regional_hris'] ?? '-'),
                            InputView(
                                label: 'PERSONNEL SUB AREA :',
                                value: data['area'] ?? '-'),
                            InputView(
                                label: 'PERSONNEL SUB AREA (HRIS) :',
                                value: data['area_hris'] ?? '-'),
                            InputView(
                                label: 'ORGANIZATIONAL UNIT :',
                                value: data['struktur_organ'] ?? '-'),
                          ],
                        ),
                      ),
                      Card(
                        color: Constants.primaryBlue,
                        child: ListTile(
                            leading: Icon(Icons.work_outlined,
                                color: Colors.white, size: 18.sp),
                            title: Text('POSITION / JOB',
                                style: TextStyle(
                                    fontFamily: 'GrenadineMVB',
                                    fontSize: 12.sp,
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
                                label: 'EMPLOYEE GROUP :',
                                value: data['employee_group'] ?? '-'),
                            InputView(
                                label: 'EMPLOYEE SUB GROUP :',
                                value: data['employee_subgroup'] ?? '-'),
                            InputView(
                                label: 'GRADE :', value: data['grade'] ?? '-'),
                            InputView(
                                label: 'GOL. PHDP :',
                                value: data['golongan_phdp'] ?? '-'),
                            InputView(
                                label: 'WORK CONTRACT :',
                                value: data['work_contract'] ?? '-'),
                            InputView(
                                label: 'POSITION :',
                                value: data['position'] ?? '-'),
                            InputView(
                                label: 'JOB GROUP :',
                                value: data['job_group'] ?? '-'),
                            InputView(
                                label: 'JOB FUNCTION :',
                                value: data['job_function'] ?? '-'),
                            InputView(
                                label: 'KOMODITI :',
                                value: data['komoditi'] ?? '-'),
                            InputView(
                                label: 'KSO / NON KSO :',
                                value: data['status_kso'] ?? '-'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ]),
    );
  }
}
