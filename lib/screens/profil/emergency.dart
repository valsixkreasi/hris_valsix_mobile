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

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  State<Emergency> createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
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
        List<Map<String, dynamic>> arrData = List.from(profil['emergency']);

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
                    'EMERGENCY CONTACT',
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
                                          dataItem['nama'] ?? '-',
                                          style: TextStyle(
                                              fontFamily: 'GrenadineMVB',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.sp),
                                        ),
                                        // Text(
                                        //   '${dataItem['tanggal'] ?? '-'}',
                                        //   style: TextStyle(
                                        //     fontFamily: 'GrenadineMVB',
                                        //     fontWeight: FontWeight.normal,
                                        //     fontSize: 10.sp,
                                        //   ),
                                        // ),
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
                                            label: 'Hubungan :',
                                            value: dataItem['hubungan'] ?? '-'),
                                        InputView(
                                            label: 'Telepon :',
                                            value: dataItem['telepon'] ?? '-'),
                                        InputView(
                                            label: 'Alamat :',
                                            value:
                                                '${dataItem['alamat'] ?? '-'}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        ],
                      )
                    : SizedBox(
                        height: 0.6.sh,
                        child: Center(child: Text('Tidak ada data.'))),
              ),
            ]),
          ]),
    );
  }
}
