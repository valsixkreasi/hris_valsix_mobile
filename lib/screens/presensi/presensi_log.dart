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

class PresensiLog extends StatefulWidget {
  const PresensiLog({super.key});

  @override
  State<PresensiLog> createState() => _PresensiLogState();
}

class _PresensiLogState extends State<PresensiLog> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // List<Map<String, dynamic>> data = [];
  List<dynamic> data = [];

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);

    getData();
    super.initState();
  }

  void getData() async {
    ApiModel model = ApiModel('log_presensi_json');
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
          getData();
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
                    'Log Presensi',
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
          floatingActionButton: SizedBox(
            height: 40,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/presensi_log_bawahan');
              },
              icon: Icon(Icons.document_scanner, color: Colors.white, size: 20),
              label: Text(
                'Log Bawahan',
                style: TextStyle(color: Colors.white, fontSize: 11.sp),
              ),
              extendedPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              backgroundColor: Constants.primaryBlue,
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
                            return Button(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/presensi_log_detil',
                                  arguments: {
                                    'id': dataItem['periode'],
                                    'pegawaiId': '',
                                    'mode': '',
                                  },
                                );
                              },
                              padding: const EdgeInsets.all(0),
                              child: Card(
                                elevation: 2.0,
                                // color: Constants.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: Color(0xffcccccc),
                                    width: 0.5,
                                  ),
                                ),
                                color: Color(0xffffffff),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 14),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dataItem['periode_desc'] ?? '-',
                                        style: TextStyle(
                                            fontFamily: 'GrenadineMVB',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Hadir : ${dataItem['jumlah_hadir']} hari',
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.green),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 12.sp,
                                            color: Colors.grey,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10),
                                          ),
                                          Text(
                                            'Absen : ${dataItem['jumlah_absen']} hari',
                                            style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.red),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: 0.1.sh)
                        ],
                      )
                    : Center(heightFactor: 20, child: Text('Tidak ada data.')),
              ),
            ]),
          ]),
    );
  }
}
