import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/buttonicon.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/inputview.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/components/statusview.dart';
import 'package:hris/components/textinput.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/models/api.dart';

class PengajuanReimburseView extends StatefulWidget {
  final Object? arguments;
  const PengajuanReimburseView({super.key, this.arguments});

  @override
  State<PengajuanReimburseView> createState() => _PengajuanReimburseViewState();
}

class _PengajuanReimburseViewState extends State<PengajuanReimburseView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Map<String, dynamic> data = {};
  String status_desc = 'Draft';
  Color status_color = Constants.draft;

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);

    var arg = widget.arguments as Map<String, dynamic>?;
    if (arg != null) {
      getData(arg['id']);
    }

    super.initState();
  }

  void getData(String id) async {
    ApiModel model = ApiModel('pengajuan-reimburse/${id}');
    model.get().then((value) async {
      if (value['status'] == 'APPROVE') {
        status_color = Constants.approve;
      } else if (value['status'] == 'POSTING') {
        status_color = Constants.primaryYellow;
      } else if (value['status'] == 'REJECT') {
        status_color = Constants.reject;
      }
      setState(() {
        data = value;
      });
      EasyLoading.dismiss();
    });
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
                    'Detil Permohonan Reimburse',
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
                  // height: 1.sh - ScreenUtil().statusBarHeight,
                  padding:
                      EdgeInsets.symmetric(vertical: 20.sp, horizontal: 15.sp),
                  margin: EdgeInsets.only(top: 40.sp),
                  // color: Color(0xffcccccc),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      InputView(
                          label: 'No. Permohonan :',
                          value: data['nomor'] ?? '-'),
                      InputView(
                          label: 'Tanggal Permohonan :',
                          value: data['tanggal'] ?? '-'),
                      InputView(
                          label: 'Nama Pasien :', value: data['nama'] ?? '-'),
                      InputView(
                          label: 'Jenis Pemeriksaan :',
                          value: data['jenis_faskes'] ?? '-'),
                      InputView(
                          label: 'Kondisi :', value: data['kondisi'] ?? '-'),
                      InputView(
                          label: 'Nama Klinik / RS :',
                          value: data['deskripsi'] ?? '-'),
                      InputView(
                          label: 'Jumlah Pengajuan (RP) :',
                          value: data['jumlah_pengajuan'] ?? '-'),
                      InputView(
                          label: 'Atasan :', value: data['approver'] ?? '-'),
                      Statusview(
                        label: data['status_desc'] ?? '-',
                        color: status_color,
                      ),
                      SizedBox(height: 40.sp),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   spacing: 15.sp,
                      //   children: [
                      //     ButtonIcon(
                      //       labelColor: Colors.white,
                      //       bgColor: Constants.primaryYellow,
                      //       icon: Icon(Icons.print,
                      //           color: Colors.white, size: 16),
                      //       label: Text(
                      //         'Cetak',
                      //         style: TextStyle(
                      //             fontFamily: 'GrenadineMVB', fontSize: 12),
                      //       ),
                      //       onPressed: () {
                      //         Navigator.pushNamed(context, '/viewpdf',
                      //             arguments: {
                      //               'url': data['link_url'],
                      //               'title': 'Surat Permohonan Cuti',
                      //               'btn_download': true,
                      //             });
                      //       },
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ],
            ),
          ]),
    );
  }
}
