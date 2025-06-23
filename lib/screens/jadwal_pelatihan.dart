import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/inputview.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/models/api.dart';

class JadwalPelatihan extends StatefulWidget {
  const JadwalPelatihan({super.key});

  @override
  State<JadwalPelatihan> createState() => _JadwalPelatihanState();
}

class _JadwalPelatihanState extends State<JadwalPelatihan> {
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
        data = value['pelatihan'];
      });

      EasyLoading.dismiss();
    });
    super.initState();
  }

  Future<void> popupPelatihan(
      BuildContext context, Map<String, dynamic> itemsPelatihan) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detil Pelatihan'),
          titleTextStyle: TextStyle(
            fontFamily: 'GrenadineMVB',
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: Constants.primaryBlue,
          ),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: 1.sw,
                  child: Column(
                    children: [
                      InputView(
                        label: 'Nama Pelatihan',
                        value: itemsPelatihan['nama'],
                      ),
                      InputView(
                        label: 'Kategori Pelatihan',
                        value: itemsPelatihan['kategori_pelatihan'],
                      ),
                      InputView(
                        label: 'Jenis Pelatihan',
                        value: itemsPelatihan['jenis_pelatihan'],
                      ),
                      InputView(
                        label: 'Tujuan',
                        value: itemsPelatihan['tujuan'],
                      ),
                      InputView(
                        label: 'Kurikulum',
                        value: itemsPelatihan['kurikulum'],
                      ),
                      InputView(
                        label: 'Penyelenggara',
                        value: itemsPelatihan['penyelenggara'],
                      ),
                      InputView(
                        label: 'Lokasi',
                        value: itemsPelatihan['lokasi'],
                      ),
                      InputView(
                        label: 'Tingkat',
                        value: itemsPelatihan['tingkat'],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
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
                    'Jadwal Training & Sertifikasi',
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
                width: double.infinity,
                // height: 1.sh - ScreenUtil().statusBarHeight,
                padding:
                    EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
                margin: EdgeInsets.only(top: 40.sp),
                // color: Color(0xffcccccc),
                decoration: BoxDecoration(
                  // color: Colors.white,
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
                      String tanggalPelatihan = itemData['tanggal_awal'] +
                          ' s.d ' +
                          itemData['tanggal_awal'];
                      return InkWell(
                        onTap: () {
                          popupPelatihan(context, itemData);
                        },
                        child: Container(
                          width: double.infinity,
                          // height: 100.sp,
                          padding: EdgeInsets.all(10.sp),
                          margin:
                              EdgeInsets.only(top: index == 0 ? 15.sp : 6.sp),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Color(0xffcccccc), width: 0.7.sp),
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 1.sw,
                                child: Text(
                                  itemData['nama'],
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'GrenadineMVB',
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 6.sp),
                                    child: Image.asset(
                                      'assets/images/icons8-bill.png',
                                      width: 8.sp,
                                      height: 8.sp,
                                      color: Constants.primaryYellow,
                                    ),
                                  ),
                                  Text(
                                    'Kategori : ' +
                                        itemData['kategori_pelatihan'],
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 6.sp),
                                    child: Image.asset(
                                      'assets/images/icons8-neighbor.png',
                                      width: 8.sp,
                                      height: 8.sp,
                                    ),
                                  ),
                                  Text(
                                    'Penyelenggara : ' +
                                        itemData['penyelenggara'],
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 6.sp),
                                    child: Image.asset(
                                      'assets/images/icons8-tear-off_calendar.png',
                                      width: 8.sp,
                                      height: 8.sp,
                                    ),
                                  ),
                                  Text(
                                    tanggalPelatihan,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 6.sp),
                                    child: Image.asset(
                                      'assets/images/icons8-location.png',
                                      width: 8.sp,
                                      height: 8.sp,
                                    ),
                                  ),
                                  Text(
                                    itemData['lokasi'],
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
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
