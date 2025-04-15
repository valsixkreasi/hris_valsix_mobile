import 'package:flutter/widgets.dart';

class SessionModel extends ChangeNotifier {
  static Map<String, dynamic> _data = {};

  get data => _data;
  void setDataCustomerlokasi(p) {
    _data = p;
    notifyListeners();
  }
}
