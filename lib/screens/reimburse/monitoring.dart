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

class PengajuanReimburse extends StatefulWidget {
  const PengajuanReimburse({super.key});

  @override
  State<PengajuanReimburse> createState() => _PengajuanReimburseState();
}

class _PengajuanReimburseState extends State<PengajuanReimburse> {
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
    ApiModel model = ApiModel('pengajuan-reimburse');
    model.get().then((value) async {
      setState(() {
        data = value;
      });
      EasyLoading.dismiss();
    });
  }

  void _navigateToPage(String id) async {
    final result;
    if (id == '') {
      result = await Navigator.pushNamed(context, '/pengajuan_reimburse_add');
    } else {
      result = await Navigator.pushNamed(
        context,
        '/pengajuan_reimburse_add',
        arguments: {
          'id': id,
        },
      );
    }
    // result adalah Data kembalian dari Navigator.pop() dari halaman add;
    if (result == true) {
      getData();
    }
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _navigateToPage('');
            },
            backgroundColor: const Color(0xff53b6e2),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
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
                    'Permohonan Reimburse',
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
                            Color status_color = Constants.draft;
                            if (dataItem['status'] == 'APPROVE') {
                              status_color = Constants.approve;
                            } else if (dataItem['status'] == 'POSTING') {
                              status_color = Constants.primaryYellow;
                            } else if (dataItem['status'] == 'REJECT') {
                              status_color = Constants.reject;
                            }
                            return Button(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/pengajuan_reimburse_view',
                                  arguments: {
                                    'id': dataItem['permohonan_reimburse_id'],
                                  },
                                );
                              },
                              padding: const EdgeInsets.all(0),
                              child: Card(
                                elevation: 4.0,
                                // color: Constants.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: Color(0xffcccccc),
                                    width: 0.5,
                                  ),
                                ),
                                color: Color(0xffffffff),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(0xffe6e6e6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dataItem['nomor'] ?? '-',
                                            style: TextStyle(
                                                fontFamily: 'GrenadineMVB',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.sp),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 9,
                                                child: Text(
                                                  'Tanggal : ${dataItem['tanggal'] ?? '-'}',
                                                  style: TextStyle(
                                                    fontFamily: 'GrenadineMVB',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 10.sp,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: dataItem['status'] ==
                                                        'DRAFT'
                                                    ? InkResponse(
                                                        onTap: () {
                                                          _navigateToPage(dataItem[
                                                              'permohonan_reimburse_id']);
                                                        },
                                                        child: Icon(
                                                          Icons.edit_square,
                                                          color: Constants
                                                              .primaryYellow,
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              ),
                                            ],
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
                                          SizedBox(height: 1.sp),
                                          InputView(
                                              label: 'Nama Pasien :',
                                              value:
                                                  dataItem['pegawai'] ?? '-'),
                                          InputView(
                                              label: 'Status Keluarga :',
                                              value:
                                                  dataItem['status_keluarga'] ??
                                                      '-'),
                                          InputView(
                                              label: 'Jenis Pemeriksaan :',
                                              value: dataItem['jenis_faskes'] ??
                                                  '-'),
                                          InputView(
                                              label: 'Kondisi :',
                                              value:
                                                  dataItem['kondisi'] ?? '-'),
                                          Statusview(
                                            label:
                                                dataItem['status_desc'] ?? '-',
                                            color: status_color,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
