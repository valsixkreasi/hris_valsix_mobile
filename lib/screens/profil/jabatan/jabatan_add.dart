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

class JabatanAdd extends StatefulWidget {
  final Object? arguments;
  const JabatanAdd({super.key, this.arguments});

  @override
  State<JabatanAdd> createState() => _JabatanAddState();
}

class _JabatanAddState extends State<JabatanAdd> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  String reqId = '';
  Map<String, dynamic> jabatan = {'id': '', 'kode': '', 'nama': '', 'text': ''};
  List<Map<String, dynamic>> dataJabatan = [];
  List<Map<String, dynamic>> arrJabatan = [];
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

  String searchJabatan = '';

  @override
  void initState() {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);

    getCombo();
    // getComboJabatan('manager');

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
    });
  }

  void getComboJabatan(BuildContext context) async {
    if (searchJabatan.length < 3) {
      return EasyLoading.showToast('Ketik minimal 3 huruf',
          duration: Duration(seconds: 1));
    }
    ApiModel comboJabatan = ApiModel('combo-jabatan');
    comboJabatan.setBody({'term': searchJabatan});
    comboJabatan.getCombo().then((value) async {
      setState(() {
        dataJabatan = value;
        arrJabatan = value;
      });
      Navigator.pop(context);
      popupJabatan(context);
    });
  }

  void getCombo() async {
    ApiModel comboLevel = ApiModel('combo-level-bod');
    comboLevel.getCombo().then((value) async {
      setState(() {
        dataLevelBod = value;
      });
    });
    ApiModel comboJobGrade = ApiModel('combo-job-grade');
    comboJobGrade.getCombo().then((value) async {
      setState(() {
        datajobGrade = value;
      });
    });
    ApiModel comboPerusahaan = ApiModel('combo-perusahaan');
    comboPerusahaan.setBody({'term': ''});
    comboPerusahaan.getCombo().then((value) async {
      setState(() {
        dataperusahaan = value;
      });
    });
    ApiModel comboPersonelArea = ApiModel('combo-personnel-area');
    comboPersonelArea.setBody({'term': ''});
    comboPersonelArea.getCombo().then((value) async {
      setState(() {
        datapersonelArea = value;
      });
    });

    Timer(const Duration(seconds: 2), () {
      EasyLoading.dismiss();
    });
  }

  void getComboBagian(String id) async {
    ApiModel comboBagian = ApiModel('combo-perusahaan-bagian');
    comboBagian.setBody({'PERUSAHAAN_PENUGASAN_KODE': id});
    comboBagian.getCombo().then((value) async {
      setState(() {
        databagian = value;
      });
    });
  }

  void getComboPersonelSubArea(String id) async {
    ApiModel comboPersonelSubArea = ApiModel('combo-personnel-subarea');
    comboPersonelSubArea.setBody({'regional_kode': id});
    comboPersonelSubArea.getCombo().then((value) async {
      setState(() {
        datapersonelSubArea = value;
      });
    });
  }

  Future<void> _handleSubmit(String status) async {
    if (tmtJabatan == null) {
      return EasyLoading.showToast(
        'Harap isi TMT Jabatan',
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
      'reqJenisDokumen': 'SK_JABATAN',
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
      'PENGAJUAN_JABATAN_ID': reqId,
      'JABATAN_KODE_JABATAN': jabatan['kode'],
      'LEVEL_BOD': levelBod['id'],
      'PERUSAHAAN_JABATAN_KODE': perusahaan['kode'],
      'BAGIAN_JABATAN_KODE': bagian['kode'],
      'REGIONAL_KODE_JABATAN': personelArea['kode'],
      'AREA_KODE_JABATAN': personelSubArea['kode'],
      'NO_SK_JABATAN': noSK,
      'KELOMPOK_JABATAN_GRADE': jobGrade['id'],
      'KELOMPOK_GRADE': grade,
      'LEVEL_GRADE': level,
      'TANGGAL_SK_JABATAN':
          tanggalSk == null ? '' : DateFormat('dd-MM-yyyy').format(tanggalSk!),
      'TMT_JABATAN': DateFormat('dd-MM-yyyy').format(tmtJabatan!),
      'TMT_BERAKHIR': tmtBerakhir == null
          ? ''
          : DateFormat('dd-MM-yyyy').format(tmtBerakhir!),
      'SK_JABATAN_DOKUMEN': pathFile,
      'STATUS': status
    };
    print(body);

    var response = await Constants.postJson('pengajuan-jabatan', body);
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

  void _updateJabatan(Map<String, dynamic> value) {
    setState(() {
      jabatan = value;
    });
  }

  Future<void> popupJabatan(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        bool loadJabatan = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            // title: const Text('Ubah Password aa'),
            content: Stack(
              children: [
                TextFormField(
                  initialValue: searchJabatan,
                  onChanged: (value) {
                    setState(() {
                      searchJabatan = value;
                    });
                  },
                  onFieldSubmitted: (value) {
                    if (value.length >= 3) {
                      setState(() {
                        loadJabatan = true;
                      });
                      getComboJabatan(context);
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
                        if (searchJabatan.length >= 3) {
                          setState(() {
                            loadJabatan = true;
                          });
                          getComboJabatan(context);
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
                    child: loadJabatan
                        ? Center(
                            heightFactor: 2,
                            child: CircularProgressIndicator(
                              color: Constants.primaryBlue,
                            ))
                        : arrJabatan.length > 0
                            ? Column(
                                children: [
                                  ...List.generate(arrJabatan.length, (index) {
                                    Map<String, dynamic> itemJabatan =
                                        arrJabatan[index];
                                    return InkWell(
                                      onTap: () {
                                        _updateJabatan(arrJabatan[index]);
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
                                        child: Text(itemJabatan['text']),
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
                    TextInput(
                      label: 'Jabatan :',
                      initialValue: jabatan['text'],
                      onchanged: (p0) {},
                      ontap: () {
                        popupJabatan(context);
                      },
                      required: true,
                      readOnly: true,
                      suffixIcon: Padding(
                        padding:
                            EdgeInsets.all(0), // add padding to adjust icon
                        child: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    /*
                    Select(
                      label: 'Jabatan',
                      value: jabatan,
                      required: true,
                      onChanged: (p0) {
                        // print(p0);
                        setState(() {
                          jabatan = p0!;
                        });
                      },
                      items: dataJabatan,
                    ),
                    */
                    Select(
                      label: 'Level BOD',
                      value: levelBod,
                      required: true,
                      onChanged: (p0) {
                        setState(() {
                          levelBod = p0!;
                        });
                      },
                      items: dataLevelBod,
                    ),
                    Select(
                      label: 'Job Grade',
                      value: jobGrade,
                      required: true,
                      onChanged: (p0) {
                        setState(() {
                          jobGrade = p0!;
                        });
                      },
                      items: datajobGrade,
                    ),
                    Select(
                      label: 'Perusahaan',
                      value: perusahaan,
                      required: true,
                      onChanged: (p0) {
                        // print(p0?['kode']);
                        getComboBagian(p0?['kode']);
                        setState(() {
                          perusahaan = p0!;
                        });
                      },
                      items: dataperusahaan,
                    ),
                    Select(
                      label: 'Bagian',
                      value: bagian,
                      required: true,
                      onChanged: (p0) {
                        setState(() {
                          bagian = p0!;
                        });
                      },
                      items: databagian,
                    ),
                    Select(
                      label: 'Personel Area',
                      value: personelArea,
                      required: true,
                      onChanged: (p0) {
                        getComboPersonelSubArea(p0?['kode']);
                        setState(() {
                          personelArea = p0!;
                        });
                      },
                      items: datapersonelArea,
                    ),
                    Select(
                      label: 'Personel Sub Area',
                      value: personelSubArea,
                      required: true,
                      onChanged: (p0) {
                        setState(() {
                          personelSubArea = p0!;
                        });
                      },
                      items: datapersonelSubArea,
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
                            required: true,
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
                            required: true,
                          ),
                        )
                      ],
                    ),
                    TextInput(
                      label: 'No. SK :',
                      initialValue: noSK,
                      onchanged: (p0) {
                        setState(() {
                          noSK = p0!;
                        });
                      },
                      required: true,
                    ),
                    DatePicker(
                      label: 'Tanggal SK',
                      value: tanggalSk,
                      onChanged: (p0) {
                        setState(() {
                          tanggalSk = p0!;
                        });
                      },
                      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                      lastDate: DateTime(DateTime.now().year + 100),
                      enabled: true,
                    ),
                    Row(
                      spacing: 15.sp,
                      children: [
                        Expanded(
                          flex: 5,
                          child: DatePicker(
                            label: 'TMT Jabatan',
                            value: tmtJabatan,
                            onChanged: (p0) {
                              setState(() {
                                tmtJabatan = p0!;
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
                            label: 'TMT Berakhir',
                            value: tmtBerakhir,
                            onChanged: (p0) {
                              setState(() {
                                tmtBerakhir = p0!;
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
