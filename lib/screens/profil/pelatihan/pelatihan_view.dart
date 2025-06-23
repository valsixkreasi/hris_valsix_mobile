import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

class PelatihanView extends StatefulWidget {
  final Object? arguments;
  const PelatihanView({super.key, this.arguments});

  @override
  State<PelatihanView> createState() => _PelatihanViewState();
}

class _PelatihanViewState extends State<PelatihanView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final _formKey = GlobalKey<FormState>();

  String reqId = '';
  Map<String, dynamic> pelatihanOleh = {};
  List<Map<String, dynamic>> datapelatihanOleh = [];
  Map<String, dynamic> kategoriPelatihan = {};
  List<Map<String, dynamic>> datakategoriPelatihan = [];
  Map<String, dynamic> jenisPelatihan = {};
  List<Map<String, dynamic>> datajenisPelatihan = [];
  String namaPelatihan = '';
  String tingkat = '';
  String lokasi = '';
  String penyelenggara = '';
  DateTime? tanggalMulai;
  DateTime? tanggalSelesai;
  String jumlahJam = '';
  String noSertifikat = '';
  DateTime? tanggalBerakhir;
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
    ApiModel model = ApiModel('pengajuan-pelatihan/${id}');
    model.get().then((value) async {
      setState(() {
        reqId = value['pengajuan_pelatihan_id'];
        pelatihanOleh = {
          'id': value['pelatihan_oleh'],
          'text': value['pelatihan_oleh'],
        };
        kategoriPelatihan = {
          'id': value['kategori_pelatihan'],
          'text': value['kategori_pelatihan'],
        };
        jenisPelatihan = {
          'id': value['jenis_pelatihan'],
          'kode': value['jenis_pelatihan'],
          'nama': value['jenis_pelatihan'],
          'text': value['jenis_pelatihan'],
        };
        namaPelatihan = value['nama'];
        tingkat = value['tingkat'];
        lokasi = value['lokasi'];
        penyelenggara = value['penyelenggara'];
        tanggalMulai =
            DateFormat('yyyy-MM-dd').parse(value['tanggal_awal'] ?? '');
        tanggalSelesai =
            DateFormat('yyyy-MM-dd').parse(value['tanggal_akhir'] ?? '');
        jumlahJam = value['lama'];
        noSertifikat = value['no_seri'];
        tanggalBerakhir =
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
                    'Pengajuan Pelatihan',
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
                      label: 'Pelatihan Oleh',
                      value: pelatihanOleh,
                      onChanged: (p0) {},
                      items: datapelatihanOleh,
                      enable: false,
                    ),
                    Select(
                      label: 'Kategori Pelatihan',
                      value: kategoriPelatihan,
                      onChanged: (p0) {},
                      items: datakategoriPelatihan,
                      enable: false,
                    ),
                    Select(
                      label: 'Jenis Pelatihan',
                      value: jenisPelatihan,
                      onChanged: (p0) {},
                      items: datajenisPelatihan,
                      enable: false,
                    ),
                    TextInput(
                      label: 'Nama Pelatihan :',
                      initialValue: namaPelatihan,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    TextInput(
                      label: 'Tingkat :',
                      initialValue: tingkat,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    TextInput(
                      label: 'Lokasi :',
                      initialValue: lokasi,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    TextInput(
                      label: 'Penyelenggara :',
                      initialValue: penyelenggara,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    Row(
                      spacing: 15.sp,
                      children: [
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'Tanggal Mulai',
                            value: tanggalMulai,
                            onChanged: (p0) {},
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: false,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'Tanggal Selesai',
                            value: tanggalSelesai,
                            onChanged: (p0) {},
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: false,
                          ),
                        )
                      ],
                    ),
                    TextInput(
                      label: 'Jumlah Jam :',
                      initialValue: jumlahJam,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    TextInput(
                      label: 'No. Sertifikat :',
                      initialValue: noSertifikat,
                      onchanged: (p0) {},
                      enabled: false,
                    ),
                    DatePicker(
                      label: 'Tanggal Berakhir',
                      value: tanggalBerakhir,
                      onChanged: (p0) {},
                      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                      lastDate: DateTime(DateTime.now().year + 100),
                      enabled: false,
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
