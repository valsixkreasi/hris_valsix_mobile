import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/buttonicon.dart';
import 'package:hris/components/datepicker.dart';
import 'package:hris/components/filepicker.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/inputview.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/components/rflutter_alert/src/alert.dart';
import 'package:hris/components/rflutter_alert/src/constants.dart';
import 'package:hris/components/rflutter_alert/src/dialog_button.dart';
import 'package:hris/components/select.dart';
import 'package:hris/components/statusview.dart';
import 'package:hris/components/subtitleview.dart';
import 'package:hris/components/textinput.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/models/api.dart';
import 'package:intl/intl.dart';

class PengajuanReimburseAdd extends StatefulWidget {
  final Object? arguments;
  const PengajuanReimburseAdd({super.key, this.arguments});

  @override
  State<PengajuanReimburseAdd> createState() => _PengajuanReimburseAddState();
}

class _PengajuanReimburseAddState extends State<PengajuanReimburseAdd> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> dataKeluargaPasien = [];
  List<Map<String, dynamic>> dataJenisFaskes = [];
  List<Map<String, dynamic>> dataDokumenPendukung = [];
  String searchApproval = '';
  List<Map<String, dynamic>> dataApproval = [];
  bool loadApproval = false;

  String reqId = '';
  Map<String, dynamic> keluargaPasien = {};
  Map<String, dynamic> jenisFaskes = {};
  DateTime? tgl;
  DateTime? tglPemeriksaan;
  String kondisi = '';
  String deskripsi = '';
  String jumlahPengajuan = '';
  List<Map<String, dynamic>> dokumen = [];
  List<dynamic> dokumenFilename = [];
  List<dynamic> dokumenTemporary = [];
  int hitungUpload = 0;
  String pathFile = '';
  Map<String, dynamic> approval = {
    'PEGAWAI_ID': '',
    'NIK': '',
    'NAMA': '',
    'JABATAN': ''
  };
  String status = 'DRAFT';

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    getKeluargaPasien();
    var arg = widget.arguments as Map<String, dynamic>?;
    if (arg != null) {
      getData(arg['id']);
      getJenisFaskes(arg['id']);
    } else {
      getJenisFaskes('');
    }
    super.initState();
  }

  void getKeluargaPasien() async {
    ApiModel model = ApiModel('combo-data-keluarga-diri');
    model.get().then((value) async {
      // print(value);
      List<dynamic> res = value;
      List<Map<String, dynamic>> result =
          res.map((e) => e as Map<String, dynamic>).toList();
      setState(() {
        dataKeluargaPasien = result;
      });
      EasyLoading.dismiss();
    });
  }

  void getJenisFaskes(String id) async {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    Map<String, String> body = {
      'reqId': id,
    };
    print(body);
    // return;
    var response = await Constants.postJson('combo-jenis-faskes', body);
    List<dynamic> res = jsonDecode(response);
    List<Map<String, dynamic>> result =
        res.map((e) => e as Map<String, dynamic>).toList();
    // print(result);
    setState(() {
      dataJenisFaskes = result;
    });
    EasyLoading.dismiss();
  }

  void getDokumenPendukung(String id) async {
    ApiModel model = ApiModel('pengajuan-reimburse-dokumen/${id}');
    model.get().then((value) async {
      // print(value);
      List<dynamic> res = value;
      List<Map<String, dynamic>> result =
          res.map((e) => e as Map<String, dynamic>).toList();
      setState(() {
        dataDokumenPendukung = result;
      });
      EasyLoading.dismiss();
    });
  }

  void getData(String id) async {
    ApiModel model = ApiModel('pengajuan-reimburse/${id}');
    model.get().then((value) async {
      List<dynamic> resDokumen = jsonDecode(value['dokumen']);
      List<Map<String, dynamic>> arrDokumen =
          resDokumen.map((e) => e as Map<String, dynamic>).toList();
      // print(arrDokumen);
      setState(() {
        reqId = value['permohonan_reimburse_id'];
        keluargaPasien = {
          'id': value['nama'],
          'text': value['nama'],
          'hubungan_keluarga': value['status_keluarga'],
        };
        jenisFaskes = {
          'id': value['jenis_faskes_id'],
          'text': value['jenis_faskes'],
        };
        tgl = DateFormat('yyyy-MM-dd').parse(value['tanggal'] ?? '');
        tglPemeriksaan =
            DateFormat('yyyy-MM-dd').parse(value['tanggal_pemeriksaan'] ?? '');
        kondisi = value['kondisi'];
        deskripsi = value['deskripsi'];
        jumlahPengajuan = value['jumlah_pengajuan'];
        dokumen = arrDokumen;
        approval = {
          'PEGAWAI_ID': value['approver_id'],
          'NIK': value['approver_nik'],
          'NAMA': value['approver'],
          'JABATAN': value['approver_jabatan']
        };
        status = value['status'];
      });
      getDokumenPendukung(value['jenis_faskes_id']);
      // EasyLoading.dismiss();
    });
  }

  void getDataApproval(BuildContext context) async {
    setState(() {
      loadApproval = true;
    });
    // if (searchApproval.length < 3) {
    //   return EasyLoading.showToast('Ketik minimal 3 huruf',
    //       duration: Duration(seconds: 1));
    // }
    Map<String, String> _body = {
      'STRUKTUR_ORGAN_KODE': Constants.session['data']['struktur_organ_kode'],
      'STRUKTUR_ORGAN_ATASAN_KODE': Constants.session['data']
          ['struktur_organ_atasan_kode'],
      'reqSearch': searchApproval
    };
    var response = await Constants.postJson('pengajuan-approval-lookup', _body);
    List<dynamic> res = jsonDecode(response);
    List<Map<String, dynamic>> result =
        res.map((e) => e as Map<String, dynamic>).toList();
    print(result);
    setState(() {
      dataApproval = result;
      loadApproval = false;
    });
    Navigator.pop(context);
    popupApproval(context);
  }

  Future<void> _handleSubmit() async {
    if (tgl == null) {
      return EasyLoading.showToast(
        'Harap isi Tanggal',
        duration: const Duration(seconds: 2),
      );
    }
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
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            loopingUpload();
          },
          width: 120,
        ),
      ],
    ).show();
  }

  Future<void> loopingUpload() async {
    EasyLoading.show(status: 'Prosess Upload...');
    int idx = 0;
    for (var item in dataDokumenPendukung) {
      setState(() {
        hitungUpload = hitungUpload +
            1; // hitung jumlah dokumen yg telah melalui proses upload
      });
      if (item['dokumen'] != null) {
        dokumenFilename.add(item['nama_file']);
        await uploadFile(
            item['dokumen']); // Menunggu sampai selesai sebelum lanjut
      } else {
        // print('lewati upload => ${item['nama']}');
        // dokumen.length == 0 sudah pasti mode insert
        if (dokumen.length > 0) {
          // (mode update) jika tidak ada update file maka ambil dari detil (variabel dokume)
          dokumenFilename.add(dokumen[idx]['nama_file']);
          dokumenTemporary.add(dokumen[idx]['file']);
        } else {
          // (mode isert) jika tidak ada update file maka di isi kosong saja.
          dokumenFilename.add("");
          dokumenTemporary.add("");
        }
        if (hitungUpload >= dataDokumenPendukung.length) {
          submit();
        }
      }
      idx++;
    }
  }

  Future<void> uploadFile(dynamic dokumen) async {
    Map<String, String> body = {
      'reqJenisDokumen': 'PERMOHONAN_REIMBURSE',
    };
    Map<String, String> files = {};
    if (dokumen != null) {
      if (dokumen!.files.isNotEmpty) {
        Map<String, String> file = {
          "reqLinkFile": dokumen!.files[0].path ?? ''
        };
        files.addAll(file);
      }
    } else {
      dokumenTemporary.add(""); // tambah data kosong
      print("Skip karena file kosong.");
      return;
    }
    print(body);
    print(files);
    // print(dokumenTemporary);
    var response = await Constants.postFile(
      'pengajuan-unggah-dokumen',
      body,
      files: files,
    );
    Map<String, dynamic> responseJson =
        jsonDecode(response) as Map<String, dynamic>;
    print(responseJson);
    if (responseJson['status'] == 'success') {
      // ambil 2 value paling belakang
      String lastTwo = responseJson['file']
          .split('/')
          .reversed
          .take(2)
          .toList()
          .reversed
          .join('/');
      print('lastTwo => ${lastTwo}');
      setState(() {
        dokumenTemporary.add(lastTwo);
      });
      if (hitungUpload >= dataDokumenPendukung.length) {
        submit();
      }
    } else {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> submit() async {
    EasyLoading.show(status: 'Prosess simpan...');
    List<dynamic> dokumenNama =
        dataDokumenPendukung.map((e) => e['nama']).toList();
    // List<dynamic> dokumenFilename =
    // dataDokumenPendukung.map((e) => e['nama_file']).toList();
    List<dynamic> dokumenTemplate =
        dataDokumenPendukung.map((e) => e['file']).toList();
    Map<String, dynamic> body = {
      'reqId': reqId,
      'TAHUN': '',
      'NAMA': keluargaPasien['id'],
      'JENIS_FASKES_ID': jenisFaskes['id'],
      'STATUS_KELUARGA': keluargaPasien['hubungan_keluarga'],
      'TANGGAL': tgl == null ? '' : DateFormat('dd-MM-yyyy').format(tgl!),
      'TANGGAL_PEMERIKSAAN': tglPemeriksaan == null
          ? ''
          : DateFormat('dd-MM-yyyy').format(tglPemeriksaan!),
      'JENIS_PEMERIKSAAN': '',
      'JENIS_PEMERIKSAAN_LAINNYA': '',
      'KONDISI': kondisi,
      'DESKRIPSI': deskripsi,
      'KESEHATAN_DOKUMEN': '',
      'dokumen_nama': dokumenNama,
      'dokumen_filename': dokumenFilename,
      'dokumen_temporary': dokumenTemporary,
      'dokumen_template': dokumenTemplate,
      'STRUKTUR_ORGAN': '',
      'JUMLAH_PENGAJUAN': jumlahPengajuan,
      'APPROVER_NIK': approval['NIK'],
      'APPROVER_ID': approval['PEGAWAI_ID'],
      'STATUS': status
    };
    print(body);
    // return;
    var response = await Constants.postJson2('pengajuan-reimburse-add', body);
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
        duration: const Duration(seconds: 3),
      );
      Navigator.pop(context, true);
    } else {
      EasyLoading.showToast(
        responseJson['message'] ?? '',
        duration: const Duration(seconds: 1),
      );
    }
  }

  void _updateApproval(Map<String, dynamic> value) {
    setState(() {
      approval = value;
      searchApproval = '';
    });
  }

  void onChangeDokumen(String key, dynamic value) {
    if (value!.files.isNotEmpty) {
      int index = dataDokumenPendukung.indexWhere((obj) => obj['nama'] == key);
      if (index != -1) {
        setState(() {
          dataDokumenPendukung[index]['nama_file'] = value!.files[0].name;
          dataDokumenPendukung[index]['dokumen'] = value;
        });
      }
    } else {
      print('Tidak ada file.');
    }
  }

  Future<void> popupApproval(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            // title: const Text('Ubah Password aa'),
            content: Stack(
              children: [
                TextFormField(
                  initialValue: searchApproval,
                  onChanged: (value) {
                    setState(() {
                      searchApproval = value;
                    });
                  },
                  onFieldSubmitted: (value) {
                    if (value.length >= 3) {
                      setState(() {
                        loadApproval = true;
                      });
                      getDataApproval(context);
                    } else {
                      EasyLoading.showToast('Ketik minimal 3 huruf',
                          duration: Duration(seconds: 1));
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Ketik 3 atau lebih huruf...",
                    border: OutlineInputBorder(),
                    suffix: InkWell(
                      onTap: () {
                        if (searchApproval.length >= 3) {
                          setState(() {
                            loadApproval = true;
                          });
                          getDataApproval(context);
                        } else {
                          EasyLoading.showToast('Ketik minimal 3 huruf',
                              duration: Duration(seconds: 1));
                        }
                      },
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(),
                  ),
                  style: TextStyle(
                    fontFamily: 'GrenadineMVB',
                    fontWeight: FontWeight.normal,
                    fontSize: 10.sp,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 55.sp),
                  child: SingleChildScrollView(
                    child: loadApproval
                        ? Center(
                            heightFactor: 2,
                            child: CircularProgressIndicator(
                              color: Constants.primaryBlue,
                            ))
                        : dataApproval.length > 0
                            ? Column(
                                children: [
                                  ...List.generate(dataApproval.length,
                                      (index) {
                                    Map<String, dynamic> itemApproval =
                                        dataApproval[index];
                                    return InkWell(
                                      onTap: () {
                                        _updateApproval(dataApproval[index]);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 3, horizontal: 0),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemApproval['NIK'],
                                              style: TextStyle(
                                                  fontFamily: 'GrenadineMVB',
                                                  fontSize: 10),
                                            ),
                                            Text(
                                              itemApproval['NAMA'],
                                              style: TextStyle(
                                                fontFamily: 'GrenadineMVB',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              itemApproval['JABATAN'],
                                              style: TextStyle(
                                                  fontFamily: 'GrenadineMVB',
                                                  fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              )
                            : Center(
                                heightFactor: 2,
                                child: Text('Tidak ada data.'),
                              ),
                  ),
                ),
              ],
            ),
          );
        });
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
                    'Tambah Permohonan Reimburse',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.sp,
                children: [
                  Subtitleview(
                    label: 'PERMOHONAN REIMBURSE',
                  ),
                  SizedBox(
                    height: 0.5.sp,
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 15.sp,
                        children: [
                          DatePicker(
                            label: 'Tanggal Permohonan',
                            value: tgl,
                            onChanged: (p0) {
                              if (p0 != null) {
                                setState(() {
                                  tgl = p0;
                                });
                              }
                            },
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: true,
                          ),
                          Select(
                            label: 'Nama Pasien',
                            value: keluargaPasien,
                            required: true,
                            onChanged: (p0) {
                              setState(() {
                                keluargaPasien = p0!;
                              });
                            },
                            items: dataKeluargaPasien,
                          ),
                          Select(
                            label: 'Jenis Pemeriksaan',
                            value: jenisFaskes,
                            required: true,
                            onChanged: (p0) {
                              if (p0!['validasi'] == '1') {
                                getDokumenPendukung(p0!['id']);
                                setState(() {
                                  jenisFaskes = p0;
                                });
                              } else {
                                setState(() {
                                  jenisFaskes = {'id': '', 'text': ''};
                                  dataDokumenPendukung = [];
                                });
                                EasyLoading.showToast(
                                  'Anda telah mengajukan ${p0['text']} pada tanggal ${p0['tanggal_permohonan']}, silahkan mengjukan kembali pada tanggal ${p0['tanggal_berikutnya']}.',
                                  duration: const Duration(seconds: 4),
                                );
                              }
                            },
                            items: dataJenisFaskes,
                          ),
                          DatePicker(
                            label: 'Tanggal Pemeriksaan',
                            value: tglPemeriksaan,
                            onChanged: (p0) {
                              if (p0 != null) {
                                setState(() {
                                  tglPemeriksaan = p0;
                                });
                              }
                            },
                            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                            lastDate: DateTime(DateTime.now().year + 100),
                            enabled: true,
                          ),
                          TextInput(
                            label: 'Kondisi',
                            initialValue: kondisi,
                            onchanged: (p0) {
                              setState(() {
                                kondisi = p0!;
                              });
                            },
                            required: true,
                          ),
                          TextInput(
                            label: 'Nama Klinik / RS',
                            initialValue: deskripsi,
                            onchanged: (p0) {
                              setState(() {
                                deskripsi = p0!;
                              });
                            },
                            required: true,
                          ),
                          TextInput(
                            label: 'Jumlah Pengajuan (RP)',
                            initialValue: jumlahPengajuan,
                            onchanged: (p0) {
                              setState(() {
                                jumlahPengajuan = p0!;
                              });
                            },
                            required: true,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 1.sp),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                flex: 8,
                                child: TextInput(
                                  label: 'Atasan',
                                  initialValue: approval['NAMA'] ?? '-',
                                  required: false,
                                  enabled: false,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Button(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    getDataApproval(context);
                                    popupApproval(context);
                                  },
                                  child: Container(
                                    // width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    child: Icon(Icons.people,
                                        color: Colors.black, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Subtitleview(
                            label: 'Dokumen Pendukung',
                          ),
                          Container(
                            child: dokumen.length > 0
                                ? Column(
                                    children: [
                                      ...List.generate(dokumen.length, (index) {
                                        Map<String, dynamic> dataItemDok =
                                            dokumen[index];
                                        return Card(
                                          elevation: 4.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              color: Color(0xffcccccc),
                                              width: 0.5,
                                            ),
                                          ),
                                          color: Color(0xffffffff),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              spacing: 10.sp,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: dataItemDok[
                                                              'template'] !=
                                                          null
                                                      ? InkWell(
                                                          onTap: () {
                                                            // Constants.launchUrl(pathFile);
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/viewpdf',
                                                                arguments: {
                                                                  'url': Constants
                                                                          .baseWebUrl +
                                                                      'uploads/' +
                                                                      dataItemDok[
                                                                          'template'],
                                                                  'title':
                                                                      'Dokumen',
                                                                  'btn_download':
                                                                      false,
                                                                });
                                                          },
                                                          child: Text(
                                                            'Lihat Template',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'GrenadineMVB',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 10.sp,
                                                              color: const Color(
                                                                  0xff3174c7),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ),
                                                FilesPicker(
                                                  label: dataItemDok['nama'],
                                                  value: dataItemDok['dokumen'],
                                                  onChanged: (p0) {
                                                    // hanya bisa upload file pdf.
                                                    PlatformFile file =
                                                        p0!.files.first;
                                                    if (file.extension ==
                                                        'pdf') {
                                                      onChangeDokumen(
                                                          dataItemDok['nama'],
                                                          p0);
                                                    } else {
                                                      EasyLoading.showToast(
                                                        'Tidak bisa upload, Format file anda ${file.extension}',
                                                        duration:
                                                            const Duration(
                                                                seconds: 2),
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
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'GrenadineMVB',
                                                          fontSize: 9.sp,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child:
                                                          dataItemDok['file'] !=
                                                                  null
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    // Constants.launchUrl(pathFile);
                                                                    Navigator.pushNamed(
                                                                        context,
                                                                        '/viewpdf',
                                                                        arguments: {
                                                                          'url': Constants.baseWebUrl +
                                                                              'uploads/' +
                                                                              dataItemDok['file'],
                                                                          'title':
                                                                              'Dokumen',
                                                                          'btn_download':
                                                                              false,
                                                                        });
                                                                  },
                                                                  child: Text(
                                                                    'Lihat Lampiran',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'GrenadineMVB',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          10.sp,
                                                                      color: const Color(
                                                                          0xff3174c7),
                                                                    ),
                                                                  ),
                                                                )
                                                              : SizedBox(),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                    ],
                                  )
                                : Column(
                                    children: [
                                      ...List.generate(
                                          dataDokumenPendukung.length, (index) {
                                        Map<String, dynamic> dataItem =
                                            dataDokumenPendukung[index];
                                        return Card(
                                          elevation: 4.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              color: Color(0xffcccccc),
                                              width: 0.5,
                                            ),
                                          ),
                                          color: Color(0xffffffff),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              spacing: 10.sp,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: dataItem['file'] !=
                                                          null
                                                      ? InkWell(
                                                          onTap: () {
                                                            // Constants.launchUrl(pathFile);
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/viewpdf',
                                                                arguments: {
                                                                  'url': Constants
                                                                          .baseWebUrl +
                                                                      'uploads/' +
                                                                      dataItem[
                                                                          'file'],
                                                                  'title':
                                                                      'Dokumen',
                                                                  'btn_download':
                                                                      false,
                                                                });
                                                          },
                                                          child: Text(
                                                            'Lihat Template',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'GrenadineMVB',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 10.sp,
                                                              color: const Color(
                                                                  0xff3174c7),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ),
                                                FilesPicker(
                                                  label: dataItem['nama'],
                                                  value: dataItem['dokumen'],
                                                  onChanged: (p0) {
                                                    // hanya bisa upload file pdf.
                                                    PlatformFile file =
                                                        p0!.files.first;
                                                    if (file.extension ==
                                                        'pdf') {
                                                      onChangeDokumen(
                                                          dataItem['nama'], p0);
                                                    } else {
                                                      EasyLoading.showToast(
                                                        'Tidak bisa upload, Format file anda ${file.extension}',
                                                        duration:
                                                            const Duration(
                                                                seconds: 2),
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
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'GrenadineMVB',
                                                          fontSize: 9.sp,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                          ),
                          SizedBox(height: 10.sp),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 15.sp,
                            children: [
                              ButtonIcon(
                                labelColor: Colors.white,
                                bgColor: Constants.primaryYellow,
                                icon: Icon(Icons.save,
                                    color: Colors.white, size: 16),
                                label: Text(
                                  'Dfaft',
                                  style: TextStyle(
                                      fontFamily: 'GrenadineMVB', fontSize: 10),
                                ),
                                onPressed: () {
                                  setState(() {
                                    status = 'DRAFT';
                                  });
                                  _handleSubmit();
                                },
                              ),
                              ButtonIcon(
                                labelColor: Colors.white,
                                bgColor: Constants.primaryGreen,
                                icon: Icon(Icons.send,
                                    color: Colors.white, size: 16),
                                label: Text(
                                  'Posting',
                                  style: TextStyle(
                                      fontFamily: 'GrenadineMVB', fontSize: 10),
                                ),
                                onPressed: () {
                                  setState(() {
                                    status = 'POSTING';
                                  });
                                  _handleSubmit();
                                },
                              ),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ]),
    );
  }
}
