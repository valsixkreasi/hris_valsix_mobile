import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hris/configs/constants.dart';

var responsedefault = '''
  {
    "code": "001",
    "status": "success",
    "profil": {
        "user_login_mobile_id": "-",
        "user_login_id": "-",
        "pegawai_id": "-",
        "pegawai_md5_id": "-",
        "perusahaan_id": "-",
        "regional_grup_kode": "-",
        "regional_grup": "-",
        "regional_kode": "-",
        "regional": "-",
        "area_kode": "-",
        "area": "-",
        "nrp": "-",
        "pegawai": "-",
        "jabatan": "-",
        "email": "-",
        "telepon": "-",
        "struktur_organ": "-",
        "kelompok_pegawai": "-",
        "kelompok_pegawai_sub": "-",
        "status_pegawai": "-",
        "status_penugasan": "-",
        "kelompok_shift": "-",
        "user_login": null,
        "user_group_id": "",
        "user_group": "",
        "hak_akses": null,
        "status_aktif": "-",
        "waktu_login": "-",
        "token": "-",
        "status": "-",
        "device_id": "-",
        "imei": "-",
        "token_firebase": null,
        "ip_address": "-",
        "akses_melalui": "-",
        "akses_browser": "-",
        "akses_target": "",
        "waktu_login_desc": "-"
    },
    "presensi": {
        "jadwal_masuk": "--:--",
        "jadwal_pulang": "--:--",
        "absensi_masuk": "--:--",
        "absensi_pulang": "--:--",
        "cuti_tahun": "-",
        "cuti_tahunan_sisa": "-",
        "cuti_tahunan_total": "-",
        "cuti_panjang_sisa": "-",
        "cuti_panjang_total": "-"
    },
    "peraturan": [],
    "cetak_cv": ""
  }
''';

class HomeModel extends ChangeNotifier {
  BuildContext context;
  Map<String, dynamic> _data = jsonDecode(responsedefault);

  HomeModel(this.context) {
    fetch();
  }

  get data => _data;

  void setData(data) {
    _data = data;
    notifyListeners();
  }

  Future fetch() async {
    Map<String, String> _body = {};

    var response = await Constants.postJson('home', _body);

    Map<String, dynamic> result = jsonDecode(response);
    if (result['status'] == 'success') {
      setData(result);
    } else {
      // Constants.showMyDialog(context, Text(result['message']));
    }

    return response;
  }
}
