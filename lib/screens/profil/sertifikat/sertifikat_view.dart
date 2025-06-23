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

class SertifikatView extends StatefulWidget {
  final Object? arguments;
  const SertifikatView({super.key, this.arguments});

  @override
  State<SertifikatView> createState() => _SertifikatViewState();
}

class _SertifikatViewState extends State<SertifikatView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final _formKey = GlobalKey<FormState>();

  String reqId = '';
  String namaSertifikat = '';
  String noSertifikat = '';
  String diterbitkanOleh = '';
  DateTime? tanggalTerbit;
  DateTime? tanggalKadaluarsa;
  FilePickerResult? dokumen;
  String pathFile = '';

  @override
  void initState() {
    var arg = widget.arguments as Map<String, dynamic>?;
    if (arg != null) {
      EasyLoading.show(
          status: 'Loading...', maskType: EasyLoadingMaskType.black);
      getData(arg['id']);
    }

    super.initState();
  }

  void getData(String id) async {
    ApiModel model = ApiModel('pengajuan-sertifikat/${id}');
    model.get().then((value) async {
      setState(() {
        reqId = value['pengajuan_sertifikat_id'];
        namaSertifikat = value['nama'];
        noSertifikat = value['nomor'];
        diterbitkanOleh = value['diterbitkan_oleh'];
        tanggalTerbit = DateFormat('yyyy-MM-dd').parse(value['tanggal'] ?? '');
        tanggalKadaluarsa =
            DateFormat('yyyy-MM-dd').parse(value['tanggal_expired'] ?? '');
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
                    'Pengajuan Sertifikat',
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
                    TextInput(
                      label: 'Nama Sertifikat :',
                      initialValue: namaSertifikat,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    TextInput(
                      label: 'No. Sertifikat :',
                      initialValue: noSertifikat,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    TextInput(
                      label: 'Diterbitkan Oleh :',
                      initialValue: diterbitkanOleh,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    Row(
                      spacing: 15.sp,
                      children: [
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'Tanggal Terbit',
                            value: tanggalTerbit,
                            onChanged: (p0) {},
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: false,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'Tanggal Kadaluarsa',
                            value: tanggalKadaluarsa,
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
