import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/buttonicon.dart';
import 'package:hris/components/datepicker.dart';
import 'package:hris/components/filepicker.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/components/rflutter_alert/src/alert.dart';
import 'package:hris/components/rflutter_alert/src/constants.dart';
import 'package:hris/components/rflutter_alert/src/dialog_button.dart';
import 'package:hris/components/select.dart';
import 'package:hris/components/select_dialog.dart';
import 'package:hris/components/textinput.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/models/api.dart';
import 'package:intl/intl.dart';

class JabatanView extends StatefulWidget {
  final Object? arguments;
  const JabatanView({super.key, this.arguments});

  @override
  State<JabatanView> createState() => _JabatanViewState();
}

class _JabatanViewState extends State<JabatanView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final _formKey = GlobalKey<FormState>();

  String reqId = '';
  Map<String, dynamic> jabatan = {};
  List<Map<String, dynamic>> dataJabatan = [];
  Map<String, dynamic> levelBod = {};
  List<Map<String, dynamic>> dataLevelBod = [];
  Map<String, dynamic> jobGrade = {};
  List<Map<String, dynamic>> datajobGrade = [];
  Map<String, dynamic> perusahaan = {};
  List<Map<String, dynamic>> dataperusahaan = [];
  Map<String, dynamic> bagian = {};
  List<Map<String, dynamic>> databagian = [];
  Map<String, dynamic> personelArea = {};
  List<Map<String, dynamic>> datapersonelArea = [];
  Map<String, dynamic> personelSubArea = {};
  List<Map<String, dynamic>> datapersonelSubArea = [];
  String grade = '';
  String level = '';
  String noSK = '';
  DateTime? tanggalSk;
  DateTime? tmtJabatan;
  DateTime? tmtBerakhir;
  FilePickerResult? dokumen;
  String pathFile = '';

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
    ApiModel model = ApiModel('pengajuan-jabatan/${id}');
    model.get().then((value) async {
      setState(() {
        reqId = value['pengajuan_jabatan_id'];
        jabatan = {
          'id': value['jabatan'],
          'kode': value['jabatan_kode'],
          'nama': value['jabatan'],
          'text': value['jabatan'] + " (" + value['jabatan_kode'] + ")",
        };
        levelBod = {
          'id': value['level_bod'],
          'text': value['level_bod'],
        };
        jobGrade = {
          'id': value['kelompok_jabatan_grade'],
          'text': value['kelompok_jabatan_grade'],
        };
        perusahaan = {
          'id': value['perusahaan_penugasan'],
          'kode': value['perusahaan_penugasan_kode'],
          'text': value['perusahaan_penugasan'],
        };
        bagian = {
          'id': value['bagian_penugasan'],
          'kode': value['bagian_penugasan_kode'],
          'text': value['bagian_penugasan'],
        };
        personelArea = {
          'id': value['regional'],
          'kode': value['regional_kode'],
          'text': value['regional'],
        };
        personelSubArea = {
          'id': value['area'],
          'kode': value['area_kode'],
          'text': value['area'],
        };
        grade = value['kelompok_grade'] ?? '';
        level = value['level_grade'];
        noSK = value['no_sk'];
        tanggalSk = DateFormat('yyyy-MM-dd').parse(value['tanggal_sk'] ?? '');
        tmtJabatan = DateFormat('yyyy-MM-dd').parse(value['tmt_jabatan'] ?? '');
        tmtBerakhir =
            DateFormat('yyyy-MM-dd').parse(value['tmt_berakhir'] ?? '');
        pathFile = value['dokumen'];
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
                    'Pengajuan Riwayat Jabatan',
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
            Form(
              key: _formKey,
              child: Container(
                // width: 40.sp,
                // height: 0.1.sh - ScreenUtil().statusBarHeight,
                padding:
                    EdgeInsets.symmetric(vertical: 25.sp, horizontal: 15.sp),
                margin: EdgeInsets.only(top: 40.sp),
                // color: Color(0xff888888),
                child: Column(
                  spacing: 15.sp,
                  children: [
                    Select(
                      label: 'Jabatan',
                      value: jabatan,
                      onChanged: (p0) {
                        // print(p0);
                        setState(() {
                          jabatan = p0!;
                        });
                      },
                      items: dataJabatan,
                      enable: false,
                    ),
                    Select(
                      label: 'Level BOD',
                      value: levelBod,
                      onChanged: (p0) {
                        setState(() {
                          levelBod = p0!;
                        });
                      },
                      items: dataLevelBod,
                      enable: false,
                    ),
                    Select(
                      label: 'Job Grade',
                      value: jobGrade,
                      onChanged: (p0) {
                        setState(() {
                          jobGrade = p0!;
                        });
                      },
                      items: datajobGrade,
                      enable: false,
                    ),
                    Select(
                      label: 'Perusahaan',
                      value: perusahaan,
                      onChanged: (p0) {
                        setState(() {
                          perusahaan = p0!;
                        });
                      },
                      items: dataperusahaan,
                      enable: false,
                    ),
                    Select(
                      label: 'Bagian',
                      value: bagian,
                      onChanged: (p0) {
                        setState(() {
                          bagian = p0!;
                        });
                      },
                      items: databagian,
                      enable: false,
                    ),
                    Select(
                      label: 'Personel Area',
                      value: personelArea,
                      onChanged: (p0) {
                        setState(() {
                          personelArea = p0!;
                        });
                      },
                      items: datapersonelArea,
                      enable: false,
                    ),
                    Select(
                      label: 'Personel Sub Area',
                      value: personelSubArea,
                      onChanged: (p0) {
                        setState(() {
                          personelSubArea = p0!;
                        });
                      },
                      items: datapersonelSubArea,
                      enable: false,
                    ),
                    Row(
                      spacing: 15.sp,
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextInput(
                            label: 'Grade :',
                            initialValue: grade,
                            onchanged: (p0) {
                              setState(() {
                                grade = p0!;
                              });
                            },
                            enabled: false,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: TextInput(
                            label: 'Level :',
                            initialValue: level,
                            onchanged: (p0) {
                              setState(() {
                                level = p0!;
                              });
                            },
                            enabled: false,
                          ),
                        )
                      ],
                    ),
                    TextInput(
                      label: 'No. SK :',
                      initialValue: noSK,
                      enabled: false,
                    ),
                    DatePicker(
                      label: 'Tanggal SK',
                      value: tanggalSk,
                      onChanged: (p0) {},
                      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                      lastDate: DateTime(DateTime.now().year + 100),
                      enabled: false,
                    ),
                    Row(
                      spacing: 15.sp,
                      children: [
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'TMT Jabatan',
                            value: tmtJabatan,
                            onChanged: (p0) {},
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: false,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'TMT Berakhir',
                            value: tmtBerakhir,
                            onChanged: (p0) {},
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: false,
                          ),
                        )
                      ],
                    ),
                    FilesPicker(
                      label: 'Dokumen',
                      value: dokumen,
                      onChanged: (p0) {},
                      fromCamera: false,
                      link: pathFile,
                      enabled: false,
                    ),
                    SizedBox(height: 40.sp),
                  ],
                ),
              ),
            ),
          ]),
    );
  }
}
