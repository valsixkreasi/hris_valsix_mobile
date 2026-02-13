import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/inputview.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/components/statusview.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/models/api.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class PresensiLogDetil extends StatefulWidget {
  final Object? arguments;
  const PresensiLogDetil({super.key, this.arguments});

  @override
  State<PresensiLogDetil> createState() => _PresensiLogDetilState();
}

class _PresensiLogDetilState extends State<PresensiLogDetil> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // List<Map<String, dynamic>> data = [];
  List<dynamic> data = [];
  String periode = "";
  String periodeText = "";
  String pegawaiId = "";
  String mode = "";

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    var arg = widget.arguments as Map<String, dynamic>?;
    if (arg != null) {
      print(arg);
      ubahFormatPeriode(arg['id']);
      getData(arg['id'], arg['pegawaiId']);
      setState(() {
        periode = arg['id'];
        pegawaiId = arg['pegawaiId'];
        mode = arg['mode'];
      });
    }
    ;
    super.initState();
  }

  void ubahFormatPeriode(String prd) {
    // 1. Pecah string (02 = bulan, 2026 = tahun)
    String monthStr = prd.substring(0, 2); // "02"
    String yearStr = prd.substring(2); // "2026"
    // 2. Buat objek DateTime (gunakan hari ke-1 agar aman)
    DateTime date = DateTime(int.parse(yearStr), int.parse(monthStr));
    // 3. Inisialisasi lokalisasi Indonesia (penting!)
    initializeDateFormatting('id_ID', null);
    // 4. Format menjadi "MMMM yyyy" (Februari 2026)
    String formattedDate = DateFormat('MMMM yyyy', 'id_ID').format(date);
    // print(formattedDate); // Output: Februari 2026
    setState(() {
      periodeText = formattedDate;
    });
  }

  void getData(String id, String pegawaiId) async {
    ApiModel model = ApiModel('log_presensi_detil_json?');
    model.setParam({
      'reqPeriode': id,
    });
    if (mode == 'bawahan') {
      model = ApiModel('log_presensi_atasan_detil_json?');
      model.setParam({
        'reqPeriode': id,
        'reqPegawaiId': pegawaiId,
      });
    }
    model.get().then((value) async {
      setState(() {
        data = value['result'];
      });
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
          getData(periode, pegawaiId);
        });
      },
      child: NavHeader(
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
                    'Log Presensi $periodeText',
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
            Stack(children: [
              Container(
                width: 1.sw,
                // height: 1.sh - ScreenUtil().statusBarHeight,
                padding:
                    EdgeInsets.symmetric(vertical: 15.sp, horizontal: 10.sp),
                margin: EdgeInsets.only(top: 40.sp),
                // color: Color(0xffcccccc),
                child: data.length > 0
                    ? Column(
                        children: [
                          ...List.generate(data.length, (index) {
                            Map<String, dynamic> dataItem = data[index];
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(color: Colors.grey))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 0.06.sw,
                                    child: Text(
                                      dataItem['hari'],
                                      style: TextStyle(fontSize: 10.sp),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 0.2.sw,
                                    child: Text(
                                      dataItem['nama_hari'],
                                      style: TextStyle(fontSize: 10.sp),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 0.06.sw,
                                    child: dataItem['mood_masuk'] == null
                                        ? Text('-', textAlign: TextAlign.center)
                                        : Image.network(
                                            '${Constants.baseWebUrl}uploads/jenis_mood/${dataItem['mood_masuk']}.png',
                                            width: 20,
                                            height: 20),
                                  ),
                                  SizedBox(
                                    width: 0.06.sw,
                                    child: Text(
                                      'In',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(fontSize: 10.sp),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 0.14.sw,
                                    child: Text(
                                      dataItem['jam_masuk'] ?? '--:--',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 12.sp,
                                    color: Colors.grey,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  SizedBox(
                                    width: 0.14.sw,
                                    child: Text(
                                      dataItem['jam_pulang'] ?? '--:--',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 0.06.sw,
                                    child: Text(
                                      'Out',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 10.sp),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 0.06.sw,
                                    child: dataItem['mood_pulang'] == null
                                        ? Text('-', textAlign: TextAlign.center)
                                        : Image.network(
                                            '${Constants.baseWebUrl}uploads/jenis_mood/${dataItem['mood_pulang']}.png',
                                            width: 20,
                                            height: 20),
                                  ),
                                ],
                              ),
                            );
                          })
                        ],
                      )
                    : Center(heightFactor: 20, child: Text('Tidak ada data.')),
              ),
            ]),
          ]),
    );
  }
}
