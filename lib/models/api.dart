import 'dart:convert';
import 'package:hris/configs/constants.dart';

class ApiModel {
  String _url;
  Map<String, String> _param = {};
  Map<String, String> _body = {};
  Map<String, String> _files = {};

  get url => _url;
  void setUrl(p) {
    _url = p;
  }

  get param => _param;
  void setParam(p) {
    _param = p;
  }

  get body => _body;
  void setBody(p) {
    _body = p;
  }

  get files => _files;
  void setFiles(p) {
    _files = p;
  }

  ApiModel(this._url);

  Future get() async {
    String uriParam = '';
    _param.forEach((key, value) {
      uriParam += '&$key=$value';
    });

    var response = await Constants.get(_url + uriParam);
    return jsonDecode(response);
  }

  Future getCombo() async {
    // Map<String, String> _body = {};
    // print(_body);
    var response = await Constants.postJson(_url, _body);
    List<dynamic> res = jsonDecode(response);
    List<Map<String, dynamic>> result =
        res.map((e) => e as Map<String, dynamic>).toList();
    return result;
  }

  Future postJson() async {
    Map<String, String> _body = {};
    var response = await Constants.postJson(_url, _body);
    // print(response);
    return jsonDecode(response);
  }

  Future postFile() async {
    var response = await Constants.postFile(_url, _body, files: _files);
    return jsonDecode(response);
  }
}

class ApiUrl {
  static ApiUrlProfil profil = ApiUrlProfil();
}

class ApiUrlProfil {
  String view = 'profil-pegawai';
}
