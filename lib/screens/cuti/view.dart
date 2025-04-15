import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/inputview.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/components/textinput.dart';

class PengajuanCutiView extends StatefulWidget {
  const PengajuanCutiView({super.key});

  @override
  State<PengajuanCutiView> createState() => _PengajuanCutiViewState();
}

class _PengajuanCutiViewState extends State<PengajuanCutiView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Map<String, dynamic> data = {};

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
                    'Detil Pengajuan Cuti',
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
                SizedBox(width: 40.sp),
              ],
            ),
          ),
          children: [
            Stack(
              children: [
                Container(
                  width: 1.sw,
                  height: 1.sh - ScreenUtil().statusBarHeight,
                  padding:
                      EdgeInsets.symmetric(vertical: 20.sp, horizontal: 15.sp),
                  margin: EdgeInsets.only(top: 40.sp),
                  // color: Color(0xffcccccc),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      InputView(
                          label: 'Tanggal Permohonan :',
                          value: '02 Maret 2025'),
                      InputView(
                          label: 'Alasan Cuti :',
                          value:
                              'Lorem Ipsum is simply dummy text of the printing and typesetting industry'),
                      Row(
                        spacing: 15,
                        children: [
                          Expanded(
                            flex: 5,
                            child: InputView(
                                label: 'Tanggal Awal :',
                                value: '02 Maret 2025'),
                          ),
                          Expanded(
                            flex: 5,
                            child: InputView(
                                label: 'Tanggal Akhir :',
                                value: '02 Maret 2025'),
                          )
                        ],
                      ),
                      InputView(
                          label: 'Alamat :',
                          value:
                              'Lorem Ipsum is simply dummy text of the printing and typesetting industry'),
                      InputView(label: 'Telepon :', value: '091334345343'),
                    ],
                  ),
                ),
              ],
            ),
          ]),
    );
  }
}
