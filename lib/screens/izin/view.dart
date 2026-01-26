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

class PengajuanIzinView extends StatefulWidget {
  final Object? arguments;
  const PengajuanIzinView({super.key, this.arguments});

  @override
  State<PengajuanIzinView> createState() => _PengajuanIzinViewState();
}

class _PengajuanIzinViewState extends State<PengajuanIzinView> {
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
    ApiModel model = ApiModel('pengajuan-izin/${id}');
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
                    'Detil Pengajuan Izin',
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
                          label: 'Jenis Izin :',
                          value: data['ketidakhadiran_jenis'] ?? '-'),
                      InputView(
                          label: 'No. Pengajuan :',
                          value: data['nomor'] ?? '-'),
                      Row(
                        spacing: 15,
                        children: [
                          Expanded(
                            flex: 5,
                            child: InputView(
                                label: 'Tanggal Mulai :',
                                value: data['tanggal_awal'] ?? '-'),
                          ),
                          Expanded(
                            flex: 5,
                            child: InputView(
                                label: 'Tanggal Selesai :',
                                value: data['tanggal_akhir'] ?? '-'),
                          )
                        ],
                      ),
                      InputView(
                          label: 'Lama Cuti :',
                          value: '${data['jumlah_hari'] ?? '-'}'),
                      InputView(
                          label: 'Alasan :', value: data['keterangan'] ?? '-'),
                      InputView(
                          label: 'Alamat :', value: data['alamat'] ?? '-'),
                      SizedBox(height: 10.sp),
                      Container(
                        child: data['lampiran'] != ''
                            ? InkWell(
                                onTap: () {
                                  // Constants.launchUrl(pathFile);
                                  Navigator.pushNamed(context, '/viewpdf',
                                      arguments: {
                                        'url': Constants.baseWebUrl +
                                            data['lampiran'],
                                        'title': 'Dokumen',
                                        'btn_download': false,
                                      });
                                },
                                child: Text(
                                  'Lihat Lampiran',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'GrenadineMVB',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10.sp,
                                    color: const Color(0xff3174c7),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ),
                      SizedBox(height: 10.sp),
                      InputView(
                          label: 'Approval I :',
                          value: data['pegawai_approval1'] ?? '-'),
                      InputView(
                          label: 'Approval II :',
                          value: data['pegawai_approval2'] ?? '-'),
                      Statusview(
                        label: data['status_desc'] ?? '-',
                        color: status_color,
                      ),
                      SizedBox(height: 40.sp),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 15.sp,
                        children: [
                          ButtonIcon(
                            labelColor: Colors.white,
                            bgColor: Constants.primaryYellow,
                            icon: Icon(Icons.print,
                                color: Colors.white, size: 16),
                            label: Text(
                              'Cetak',
                              style: TextStyle(
                                  fontFamily: 'GrenadineMVB', fontSize: 12),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/viewpdf',
                                  arguments: {
                                    'url': data['link_url'],
                                    'title': 'Surat Permohonan Cuti',
                                    'btn_download': true,
                                  });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ]),
    );
  }
}
