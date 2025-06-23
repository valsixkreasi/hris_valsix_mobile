import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/models/api.dart';

class Notifikasi extends StatefulWidget {
  const Notifikasi({super.key});

  @override
  State<Notifikasi> createState() => _NotifikasiState();
}

class _NotifikasiState extends State<Notifikasi> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ApiModel model = ApiModel('home');

  List<dynamic> data = [];

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    model.postJson().then((value) async {
      setState(() {
        data = value['notifikasi'];
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
        setState(() {
          // data = [];
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
                    'Notifikasi',
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
                    EdgeInsets.symmetric(vertical: 10.sp, horizontal: 15.sp),
                margin: EdgeInsets.only(top: 40.sp),
                // color: Color(0xffcccccc),
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
                    ...List.generate(data.length, (index) {
                      Map<String, dynamic> itemData = data[index];
                      String tanggal = itemData['tanggal'];
                      String title = itemData['notifikasi'];
                      String status = 'Silahkan melakukan penilaian disini';
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  // Text(
                                  //   '[ $status ]',
                                  //   style: TextStyle(
                                  //     fontSize: 9.sp,
                                  //     color: Colors.blue[400],
                                  //   ),
                                  // ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    })
                  ],
                ),
              ),
            ]),
          ]),
    );
  }
}
