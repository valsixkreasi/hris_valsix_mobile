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
    String uriParam =
        '?iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true';
    _param.forEach((key, value) {
      uriParam += '&$key=$value';
    });

    var response = await Constants.get(_url + uriParam);
    return jsonDecode(response);
  }

  Future postJson() async {
    Map<String, String> _body = {};
    var response = await Constants.postJson(_url, _body);
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
