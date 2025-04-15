import 'package:flutter/material.dart';
import 'package:hris/components/buttonicon.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/components/textinput.dart';

class PengajuanCutiAdd extends StatefulWidget {
  const PengajuanCutiAdd({super.key});

  @override
  State<PengajuanCutiAdd> createState() => _PengajuanCutiAddState();
}

class _PengajuanCutiAddState extends State<PengajuanCutiAdd> {
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
                    'Tambah Pengajuan Cuti',
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
            Container(
              // width: 40.sp,
              // height: 0.1.sh - ScreenUtil().statusBarHeight,
              padding: EdgeInsets.symmetric(vertical: 25.sp, horizontal: 15.sp),
              margin: EdgeInsets.only(top: 40.sp),
              // color: Color(0xff888888),
              child: Column(
                spacing: 15.sp,
                children: [
                  TextInput(
                    label: 'Alasan Cuti :',
                    initialValue: '',
                    onchanged: (p0) {
                      setState(() {
                        // nama = p0!;
                      });
                    },
                    required: true,
                  ),
                  Row(
                    spacing: 15.sp,
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextInput(
                          label: 'Tanggal Awal :',
                          initialValue: '',
                          onchanged: (p0) {
                            setState(() {
                              // nama = p0!;
                            });
                          },
                          required: true,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: TextInput(
                          label: 'Tanggal Akhir :',
                          initialValue: '',
                          onchanged: (p0) {
                            setState(() {
                              // nama = p0!;
                            });
                          },
                          required: true,
                        ),
                      )
                    ],
                  ),
                  TextInput(
                    label: 'Alamat',
                    initialValue: '',
                    onchanged: (p0) {
                      setState(() {
                        // nama = p0!;
                      });
                    },
                    required: true,
                  ),
                  TextInput(
                    label: 'Telepon',
                    initialValue: '',
                    onchanged: (p0) {
                      setState(() {
                        // nama = p0!;
                      });
                    },
                    required: true,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(
                    height: 40.sp,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 15.sp,
                    children: [
                      ButtonIcon(
                        labelColor: Colors.white,
                        bgColor: Color(0xfffdbd5e),
                        icon: Icon(Icons.replay, color: Colors.white, size: 16),
                        label: Text(
                          'Reset',
                          style: TextStyle(
                              fontFamily: 'GrenadineMVB', fontSize: 10),
                        ),
                        onPressed: () {},
                      ),
                      ButtonIcon(
                        labelColor: Colors.white,
                        bgColor: Color(0xff53b6e2),
                        icon: Icon(Icons.send, color: Colors.white, size: 16),
                        label: Text(
                          'Submit',
                          style: TextStyle(
                              fontFamily: 'GrenadineMVB', fontSize: 10),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]),
    );
  }
}
