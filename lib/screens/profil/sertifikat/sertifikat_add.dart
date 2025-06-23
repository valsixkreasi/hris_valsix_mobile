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

class SertifikatAdd extends StatefulWidget {
  final Object? arguments;
  const SertifikatAdd({super.key, this.arguments});

  @override
  State<SertifikatAdd> createState() => _SertifikatAddState();
}

class _SertifikatAddState extends State<SertifikatAdd> {
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

  Future<void> _handleSubmit(String status) async {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Konfirmasi simpan.",
      desc:
          "Pastikan data yang Anda masukkan sudah sesuai. Klik OK jika sudah yakin.",
      buttons: [
        DialogButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: 'GrenadineMVB',
              fontWeight: FontWeight.w800,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
        ),
        DialogButton(
          child: Text(
            'OK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: 'GrenadineMVB',
              fontWeight: FontWeight.w800,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            if (dokumen != null) {
              uploadFile(status);
            } else {
              submit(status);
            }
          },
          width: 120,
        ),
      ],
    ).show();
  }

  Future<void> uploadFile(String status) async {
    EasyLoading.show(status: 'Prosess Upload...');
    Map<String, String> body = {
      'reqJenisDokumen': 'SERTIFIKAT',
    };
    Map<String, String> files = {};
    if (dokumen != null) {
      if (dokumen!.files.isNotEmpty) {
        Map<String, String> file = {
          "reqLinkFile": dokumen!.files[0].path ?? ''
        };
        files.addAll(file);
      }
    }
    print(body);
    print(dokumen);

    var response = await Constants.postFile(
      'pengajuan-unggah-dokumen',
      body,
      files: files,
    );
    Map<String, dynamic> responseJson =
        jsonDecode(response) as Map<String, dynamic>;

    print(responseJson);

    if (responseJson['status'] == 'success') {
      setState(() {
        pathFile = responseJson['file'];
      });
      submit(status);
    } else {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> submit(String status) async {
    EasyLoading.show(
      status: 'Prosess simpan...',
    );
    Map<String, String> body = {
      'PENGAJUAN_SERTIFIKAT_ID': reqId,
      'NOMOR': noSertifikat,
      'NAMA': namaSertifikat,
      'DITERBITKAN_OLEH': diterbitkanOleh,
      'TANGGAL': DateFormat('dd-MM-yyyy').format(tanggalTerbit!),
      'TANGGAL_EXPIRED': DateFormat('dd-MM-yyyy').format(tanggalKadaluarsa!),
      'SERTIFIKAT_DOKUMEN': pathFile,
      'STATUS': status
    };
    print(body);

    var response = await Constants.postJson('pengajuan-sertifikat', body);
    Map<String, dynamic> responseJson = {};
    try {
      responseJson = jsonDecode(response) as Map<String, dynamic>;
    } on FormatException {
      EasyLoading.showToast(
        'Network error!',
        duration: const Duration(seconds: 1),
      );
    }

    print(responseJson);
    EasyLoading.dismiss();

    if (responseJson['status'] == 'success') {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 2),
      );
      Navigator.pop(context);
    } else {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 1),
      );
    }
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
                      onchanged: (p0) {
                        setState(() {
                          namaSertifikat = p0!;
                        });
                      },
                      required: true,
                    ),
                    TextInput(
                      label: 'No. Sertifikat :',
                      initialValue: noSertifikat,
                      onchanged: (p0) {
                        setState(() {
                          noSertifikat = p0!;
                        });
                      },
                      required: true,
                    ),
                    TextInput(
                      label: 'Diterbitkan Oleh :',
                      initialValue: diterbitkanOleh,
                      onchanged: (p0) {
                        setState(() {
                          diterbitkanOleh = p0!;
                        });
                      },
                      required: true,
                    ),
                    Row(
                      spacing: 15.sp,
                      children: [
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'Tanggal Terbit',
                            value: tanggalTerbit,
                            onChanged: (p0) {
                              setState(() {
                                tanggalTerbit = p0!;
                              });
                            },
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: true,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'Tanggal Kadaluarsa',
                            value: tanggalKadaluarsa,
                            onChanged: (p0) {
                              setState(() {
                                tanggalKadaluarsa = p0!;
                              });
                            },
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: true,
                          ),
                        )
                      ],
                    ),
                    FilesPicker(
                      label: 'Dokumen',
                      value: dokumen,
                      onChanged: (p0) {
                        // hanya bisa upload file pdf.
                        PlatformFile file = p0!.files.first;
                        if (file.extension == 'pdf') {
                          setState(() {
                            dokumen = p0!;
                          });
                        } else {
                          EasyLoading.showToast(
                            'Tidak bisa upload, Format file anda ${file.extension}',
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
                      fromCamera: false,
                      link: '',
                      enabled: true,
                    ),
                    Row(
                      children: [
                        Expanded(
                          // width: double.infinity,
                          flex: 6,
                          child: Text(
                            '*Upload file dengan format .pdf',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'GrenadineMVB',
                              fontSize: 9.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: pathFile != ''
                              ? InkWell(
                                  onTap: () {
                                    // Constants.launchUrl(pathFile);
                                    Navigator.pushNamed(context, '/viewpdf',
                                        arguments: {
                                          'url':
                                              Constants.baseWebUrl + pathFile,
                                          'title': 'Dokumen',
                                          'btn_download': false,
                                        });
                                  },
                                  child: Text(
                                    'Lihat dokumen',
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
                      ],
                    ),
                    SizedBox(height: 40.sp),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 15.sp,
                      children: [
                        ButtonIcon(
                          labelColor: Colors.white,
                          bgColor: Color(0xfffdbd5e),
                          icon: Icon(Icons.save, color: Colors.white, size: 16),
                          label: Text(
                            'Simpan Draft',
                            style: TextStyle(
                                fontFamily: 'GrenadineMVB', fontSize: 12),
                          ),
                          onPressed: () {
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              if (_formKey.currentState!.validate()) {
                                _handleSubmit('DRAFT');
                              }
                            });
                          },
                        ),
                        ButtonIcon(
                          labelColor: Colors.white,
                          bgColor: Color(0xff53b6e2),
                          icon: Icon(Icons.send, color: Colors.white, size: 16),
                          label: Text(
                            'Submit',
                            style: TextStyle(
                                fontFamily: 'GrenadineMVB', fontSize: 12),
                          ),
                          onPressed: () {
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              if (_formKey.currentState!.validate()) {
                                _handleSubmit('DRAFT');
                              }
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ]),
    );
  }
}
