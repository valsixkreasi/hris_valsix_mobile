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

class PengajuanIzinAdd extends StatefulWidget {
  final Object? arguments;
  const PengajuanIzinAdd({super.key, this.arguments});

  @override
  State<PengajuanIzinAdd> createState() => _PengajuanIzinAddState();
}

class _PengajuanIzinAddState extends State<PengajuanIzinAdd> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> dataJenisIzin = [];
  Map<String, dynamic> infoJenisIzin = {};
  List<Map<String, dynamic>> dataLamaIzin = [];
  DateTime? firstdate;
  int sisa_cuti = 0;
  String searchApproval = '';
  List<Map<String, dynamic>> dataApproval = [];
  bool loadApproval = false;
  int total_hari = 0;
  int maksimal_cuti = 0;

  String reqId = '';
  Map<String, dynamic> jenisIzin = {'id': '', 'text': ''};
  String noPengajuan = '';
  DateTime? tglAwal;
  DateTime? tglAkhir;
  Map<String, dynamic> lamaIzin = {'id': '', 'text': ''};
  // String lama = '';
  String alasan = '';
  String alamat = '';
  FilePickerResult? dokumen;
  String pathFile = '';
  String mingguke = '';
  String bulan = '';
  String tahun = '';
  Map<String, dynamic> approval1 = {
    'PEGAWAI_ID': '',
    'NIK': '',
    'NAMA': '',
    'JABATAN': ''
  };
  Map<String, dynamic> approval2 = {
    'PEGAWAI_ID': '',
    'NIK': '',
    'NAMA': '',
    'JABATAN': ''
  };
  String approvalSelected = '';

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    getJenis();
    var arg = widget.arguments as Map<String, dynamic>?;
    if (arg != null) {
      getData(arg['id']);
    }
    super.initState();
  }

  void getJenis() async {
    ApiModel model = ApiModel('combo-jenis-izin');
    model.get().then((value) async {
      // print(value);
      List<dynamic> res = value;
      List<Map<String, dynamic>> result =
          res.map((e) => e as Map<String, dynamic>).toList();
      setState(() {
        dataJenisIzin = result;
      });
      EasyLoading.dismiss();
    });
  }

  void getJenisInfo(int? id) async {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    ApiModel model = ApiModel('combo-jenis-izin-info/${id}');
    model.get().then((value) async {
      // print(value);
      getMaxBackdate(value['SATUAN_PERIODE_PENGAJUAN'],
          value['MAX_TGL_PENGAJUAN_BACKDATE']);
      if (value['JENIS_HARI'] == 'BULAN') {
        getComboLama(value['JLM_MAX_HARI']);
      }
      setState(() {
        infoJenisIzin = value;
      });
      EasyLoading.dismiss();
    });
  }

  void getMaxBackdate(String satuan, int max) async {
    Map<String, String> _body = {
      'SATUAN_PERIODE_PENGAJUAN': satuan,
      'MAX_TGL_PENGAJUAN_BACKDATE': '${max}'
    };
    // print(_body);
    var response = await Constants.postJson('pengajuan-izin-backdate', _body);
    var result = jsonDecode(response);
    // print(result);
    setState(() {
      firstdate = DateTime(
          result['TAHUN_PARAM'], result['BULAN_PARAM'], result['HARI_PARAM']);
    });
  }

  void hitungLamaIzin() async {
    Map<String, String> _body = {
      'TANGGAL_AWAL':
          tglAwal == null ? '' : DateFormat('dd-MM-yyyy').format(tglAwal!),
      'TANGGAL_AKHIR':
          tglAkhir == null ? '' : DateFormat('dd-MM-yyyy').format(tglAkhir!),
      'JUMLAH_HARI': '${lamaIzin['id']}',
      'KETIDAKHADIRAN_ID': '',
      'KETIDAKHADIRAN_JENIS_ID': '${jenisIzin['id']}'
    };
    print(_body);
    var response = await Constants.postJson('pengajuan-izin-info', _body);
    var result = jsonDecode(response);
    print(result);
    if (result['status'] == 'success') {
      if (infoJenisIzin['JENIS_HARI'] == 'BULAN') {
        setState(() {
          tglAkhir =
              DateFormat('yyyy-MM-dd').parse(result['TANGGAL_AKHIR'] ?? '');
          mingguke = result['MINGGU_KE'].toString();
          bulan = result['BULAN'];
          tahun = result['TAHUN'];
        });
      } else {
        setState(() {
          lamaIzin = {
            'id': result['JUMLAH_HARI'],
            'text': result['JUMLAH_HARI']
          };
          mingguke = result['MINGGU_KE'].toString();
          bulan = result['BULAN'];
          tahun = result['TAHUN'];
        });
      }
    } else {
      setState(() {
        tglAkhir = null;
        lamaIzin = {'id': '', 'text': ''};
      });
      EasyLoading.showToast(
        result['message'] ?? '',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void getComboLama(int id) async {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    ApiModel model = ApiModel('combo-lama-izin/${id}');
    model.get().then((value) async {
      // print(value);
      List<dynamic> res = value;
      List<Map<String, dynamic>> result =
          res.map((e) => e as Map<String, dynamic>).toList();
      setState(() {
        dataLamaIzin = result;
      });
      EasyLoading.dismiss();
    });
  }

  void getData(String id) async {
    ApiModel model = ApiModel('pengajuan-izin/${id}');
    model.get().then((value) async {
      setState(() {
        reqId = value['ketidakhadiran_id'];
        jenisIzin = {
          'id': value['ketidakhadiran_jenis_id'],
          'text': value['ketidakhadiran_jenis']
        };
        noPengajuan = value['nomor'];
        tglAwal = DateFormat('yyyy-MM-dd').parse(value['tanggal_awal'] ?? '');
        tglAkhir = DateFormat('yyyy-MM-dd').parse(value['tanggal_akhir'] ?? '');
        lamaIzin = {
          'id': '${value['jumlah_hari']}',
          'text': '${value['jumlah_hari']}'
        };
        alasan = value['keterangan'];
        alamat = value['alamat'];
        pathFile = value['lampiran'];
        mingguke = value['minggu_ke'];
        bulan = value['bulan'];
        tahun = value['tahun'];
        approval1 = {
          'PEGAWAI_ID': value['pegawai_id_approval1'],
          'NIK': value['pegawai_nik_approval1'],
          'NAMA': value['pegawai_approval1'],
          'JABATAN': value['jabatan_approval1']
        };
        approval2 = {
          'PEGAWAI_ID': value['pegawai_id_approval2'],
          'NIK': value['pegawai_nik_approval2'],
          'NAMA': value['pegawai_approval2'],
          'JABATAN': value['jabatan_approval2']
        };
      });
      getJenisInfo(int.tryParse(value['ketidakhadiran_jenis_id']));
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

  Future<void> _handleSubmit(String status) async {
    if (tglAwal == null || tglAkhir == null) {
      return EasyLoading.showToast(
        'Harap isi Tanggal Awal & Tanggal Akhir',
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
      'reqJenisDokumen': 'permohonan',
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
    EasyLoading.show(status: 'Prosess simpan...');
    Map<String, String> body = {
      'reqId': reqId,
      'KETIDAKHADIRAN_JENIS_ID': jenisIzin['id'].toString(),
      'NOMOR': noPengajuan,
      'TANGGAL_AWAL':
          tglAwal == null ? '' : DateFormat('dd-MM-yyyy').format(tglAwal!),
      'TANGGAL_AKHIR':
          tglAkhir == null ? '' : DateFormat('dd-MM-yyyy').format(tglAkhir!),
      'JUMLAH_HARI': lamaIzin['id'].toString(),
      'ALAMAT': alamat,
      'KETERANGAN': alasan,
      'TELEPON': '',
      'PERMOHONAN_DOKUMEN': pathFile,
      "MINGGU_KE": mingguke.toString(),
      "BULAN": bulan,
      "TAHUN": tahun,
      'PEGAWAI_ID_APPROVAL1': approval1['PEGAWAI_ID'],
      'PEGAWAI_ID_APPROVAL2': approval2['PEGAWAI_ID'],
      'STATUS': status
    };
    print(body);
    // return;
    var response = await Constants.postJson('pengajuan-izin-add', body);
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

  void onChangeTglAwal(DateTime val) async {
    if (DateFormat('yyyy-MM-dd').format(val) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      return EasyLoading.showToast(
        'Tidak bisa pilih tanggal hari ini.',
        duration: const Duration(seconds: 2),
      );
    } else {
      if (infoJenisIzin['JENIS_HARI'] != 'BULAN') {
        setState(() {
          lamaIzin = {'id': '', 'text': ''};
        });
      }
      setState(() {
        tglAwal = val;
        tglAkhir = null;
      });
    }
    if ((infoJenisIzin['JENIS_HARI'] == 'BULAN') && lamaIzin.isEmpty) {
      setState(() {
        tglAwal = null;
      });
      return EasyLoading.showToast(
        'Tentukan lama pengajuan.',
        duration: const Duration(seconds: 2),
      );
    }
    if (infoJenisIzin['JENIS_HARI'] == 'BULAN') {
      hitungLamaIzin();
    }
  }

  void onChangeTglAkhir(DateTime val) async {
    if (DateFormat('yyyy-MM-dd').format(val) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      return EasyLoading.showToast(
        'Tidak bisa pilih tanggal hari ini.',
        duration: const Duration(seconds: 2),
      );
    } else if (tglAwal == null) {
      return EasyLoading.showToast(
        'Isi Tanggal Mulai terlebih dahulu.',
        duration: const Duration(seconds: 2),
      );
    } else {
      setState(() {
        tglAkhir = val;
      });
    }
    hitungLamaIzin();
  }

  void _updateApproval(Map<String, dynamic> value) {
    if (approvalSelected == '1') {
      setState(() {
        approval1 = value;
        searchApproval = '';
      });
    } else {
      setState(() {
        approval2 = value;
        searchApproval = '';
      });
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
                    'Tambah Pengajuan Izin',
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
                    label: 'PENGAJUAN IZIN',
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
                          Select(
                            label: 'Jenis Izin',
                            value: jenisIzin,
                            required: true,
                            onChanged: (p0) {
                              getJenisInfo(p0!['id']);
                              setState(() {
                                jenisIzin = p0;
                                tglAwal = null;
                                tglAkhir = null;
                                lamaIzin = {'id': '', 'text': ''};
                              });
                            },
                            items: dataJenisIzin,
                          ),
                          Container(
                            child: infoJenisIzin.isEmpty
                                ? SizedBox()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 10.sp,
                                    children: [
                                      TextInput(
                                        label: 'No. Pengajuan :',
                                        initialValue: noPengajuan,
                                        onchanged: (p0) {
                                          setState(() {
                                            noPengajuan = p0!;
                                          });
                                        },
                                        required: true,
                                      ),
                                      Container(
                                        child: infoJenisIzin['JENIS_HARI'] ==
                                                'BULAN'
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                spacing: 10.sp,
                                                children: [
                                                  Select(
                                                    label: 'Lama Izin',
                                                    value: lamaIzin,
                                                    required: true,
                                                    onChanged: (p0) {
                                                      setState(() {
                                                        lamaIzin = p0!;
                                                        tglAwal = null;
                                                        tglAkhir = null;
                                                      });
                                                    },
                                                    items: dataLamaIzin,
                                                  ),
                                                  Row(
                                                    spacing: 10.sp,
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: DatePicker(
                                                          label: 'Tanggal Awal',
                                                          value: tglAwal,
                                                          onChanged: (p0) {
                                                            if (p0 != null) {
                                                              onChangeTglAwal(
                                                                  p0!);
                                                            }
                                                          },
                                                          firstDate:
                                                              firstdate ??
                                                                  DateTime
                                                                      .now(),
                                                          lastDate: DateTime(
                                                              DateTime.now()
                                                                      .year +
                                                                  100),
                                                          enabled: true,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: DatePicker(
                                                          label:
                                                              'Tanggal Akhir',
                                                          value: tglAkhir,
                                                          onChanged: (p0) {
                                                            if (p0 != null) {
                                                              onChangeTglAkhir(
                                                                  p0!);
                                                            }
                                                          },
                                                          firstDate:
                                                              DateTime.now(),
                                                          lastDate: DateTime(
                                                              DateTime.now()
                                                                      .year +
                                                                  100),
                                                          enabled: false,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                spacing: 10.sp,
                                                children: [
                                                  Row(
                                                    spacing: 10.sp,
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: DatePicker(
                                                          label: 'Tanggal Awal',
                                                          value: tglAwal,
                                                          onChanged: (p0) {
                                                            if (p0 != null) {
                                                              onChangeTglAwal(
                                                                  p0!);
                                                            }
                                                          },
                                                          firstDate:
                                                              DateTime.now(),
                                                          lastDate: DateTime(
                                                              DateTime.now()
                                                                      .year +
                                                                  100),
                                                          enabled: true,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: DatePicker(
                                                          label:
                                                              'Tanggal Akhir',
                                                          value: tglAkhir,
                                                          onChanged: (p0) {
                                                            if (p0 != null) {
                                                              onChangeTglAkhir(
                                                                  p0!);
                                                            }
                                                          },
                                                          firstDate:
                                                              DateTime.now(),
                                                          lastDate: DateTime(
                                                              DateTime.now()
                                                                      .year +
                                                                  100),
                                                          enabled: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 0.4.sw,
                                                    child: TextInput(
                                                        label: 'Lama Izin',
                                                        initialValue:
                                                            '${lamaIzin['id']}',
                                                        enabled: false),
                                                  ),
                                                ],
                                              ),
                                      ),
                                      Container(
                                        child: int.tryParse(infoJenisIzin[
                                                    'KETERANGAN'])! >
                                                0
                                            ? TextInput(
                                                label: 'Alasan',
                                                initialValue: alasan,
                                                onchanged: (p0) {
                                                  setState(() {
                                                    alasan = p0!;
                                                  });
                                                },
                                                required: true,
                                              )
                                            : SizedBox(),
                                      ),
                                      TextInput(
                                        label: 'Alamat',
                                        initialValue: alamat,
                                        onchanged: (p0) {
                                          setState(() {
                                            alamat = p0!;
                                          });
                                        },
                                        required: true,
                                      ),
                                      FilesPicker(
                                        label: 'Lampiran',
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
                                              duration:
                                                  const Duration(seconds: 2),
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
                                                      Navigator.pushNamed(
                                                          context, '/viewpdf',
                                                          arguments: {
                                                            'url': Constants
                                                                    .baseWebUrl +
                                                                pathFile,
                                                            'title': 'Dokumen',
                                                            'btn_download':
                                                                false,
                                                          });
                                                    },
                                                    child: Text(
                                                      'Lihat Lampiran',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'GrenadineMVB',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 10.sp,
                                                        color: const Color(
                                                            0xff3174c7),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 1.sp),
                                      Row(
                                        spacing: 10.sp,
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: TextInput(
                                              label: 'Approval I',
                                              initialValue:
                                                  approval1['NAMA'] ?? '-',
                                              required: false,
                                              enabled: false,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Button(
                                              padding: EdgeInsets.all(0),
                                              onPressed: () {
                                                setState(() {
                                                  approvalSelected = '1';
                                                });
                                                getDataApproval(context);
                                                popupApproval(context);
                                              },
                                              child: Container(
                                                // width: double.infinity,
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.all(11),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1),
                                                ),
                                                child: Icon(Icons.people,
                                                    color: Colors.black,
                                                    size: 22),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        child: Constants.session['data']
                                                    ['struktur_organ_level'] ==
                                                4
                                            ? Row(
                                                spacing: 10.sp,
                                                children: [
                                                  Expanded(
                                                    flex: 8,
                                                    child: TextInput(
                                                      label: 'Approval II',
                                                      initialValue:
                                                          approval2['NAMA'] ??
                                                              '-',
                                                      required: false,
                                                      enabled: false,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Button(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      onPressed: () {
                                                        setState(() {
                                                          approvalSelected =
                                                              '2';
                                                        });
                                                        getDataApproval(
                                                            context);
                                                        popupApproval(context);
                                                      },
                                                      child: Container(
                                                        // width: double.infinity,
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            EdgeInsets.all(11),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1),
                                                        ),
                                                        child: Icon(
                                                            Icons.people,
                                                            color: Colors.black,
                                                            size: 22),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                      ),
                                      SizedBox(
                                        height: 10.sp,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                  fontFamily: 'GrenadineMVB',
                                                  fontSize: 10),
                                            ),
                                            onPressed: () {
                                              _handleSubmit('DRAFT');
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
                                                  fontFamily: 'GrenadineMVB',
                                                  fontSize: 10),
                                            ),
                                            onPressed: () {
                                              _handleSubmit('POSTING');
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
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
