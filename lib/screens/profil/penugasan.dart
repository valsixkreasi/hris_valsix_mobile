import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/inputview.dart';
import 'package:hris/components/navheader.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> _getData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('profil');
}

class Penugasan extends StatefulWidget {
  const Penugasan({super.key});

  @override
  State<Penugasan> createState() => _PenugasanState();
}

class _PenugasanState extends State<Penugasan> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Map<String, dynamic>> data = [];

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
        List<Map<String, dynamic>> arrData = List.from(profil['penugasan']);

        setState(() {
          data = arrData;
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
                    'RIWAYAT PENUGASAN',
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
                child: data.length > 0
                    ? Column(
                        children: [
                          ...List.generate(data.length, (index) {
                            Map<String, dynamic> dataItem = data[index];
                            return Card(
                              elevation: 4.0,
                              // color: Constants.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: Color(0xffcccccc),
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xffcccccc),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dataItem['jabatan'] ?? '-',
                                          style: TextStyle(
                                              fontFamily: 'GrenadineMVB',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.sp),
                                        ),
                                        Text(
                                          '${dataItem['tmt_jabatan'] ?? '-'} s/d ${dataItem['tmt_berakhir'] ?? '-'}',
                                          style: TextStyle(
                                            fontFamily: 'GrenadineMVB',
                                            fontWeight: FontWeight.normal,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 5.sp,
                                        ),
                                        InputView(
                                            label: 'Penugasan :',
                                            value:
                                                dataItem['jenis_penugasan'] ??
                                                    '-'),
                                        InputView(
                                            label: 'Perusahaan :',
                                            value:
                                                dataItem['perusahaan'] ?? '-'),
                                        InputView(
                                            label: 'Area :',
                                            value: dataItem['area'] ?? '-'),
                                        InputView(
                                            label: 'Divisi/Bagian :',
                                            value: dataItem['bagian'] ?? '-'),
                                        InputView(
                                            label: 'No. Surat :',
                                            value: dataItem['no_sk'] ?? '-'),
                                        InputView(
                                            label: 'Tanggal Surat :',
                                            value:
                                                dataItem['tanggal_sk'] ?? '-'),
                                        InputView(
                                            label: 'Dokumen :', value: '-'),
                                      ],
                                    ),
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
