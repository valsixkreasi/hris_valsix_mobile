import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

class Constants {
  static Map<String, dynamic> session = <String, dynamic>{};

  static String route = '';

// DEV PTPN
  // static const String baseUrl = kDebugMode
  //     ? 'http://103.130.130.233:81/ptpn-hris/public/api/'
  //     : 'http://103.130.130.233:81/ptpn-hris/public/api/';
  // static const String baseWebUrl = kDebugMode
  //     ? 'http://103.130.130.233:81/ptpn-hris/public/'
  //     : 'http://103.130.130.233:81/ptpn-hris/public/';

// PROD PTPN
  static const String baseUrl = 'https://hris.ptpn1.co.id/api/';
  static const String baseWebUrl = 'https://hris.ptpn1.co.id/';

  static String md5Key = 'P3LB8M';
  static Color primaryGreen = Color(0xff2ccd39);
  static Color primaryBlue = Color(0xff53b6e2);
  static Color primaryYellow = Color(0xfffdbd5e);

  static NumberFormat numberFormat = NumberFormat("#########.###", "en_US");

  static PackageInfo packageInfo = PackageInfo(
    appName: '-',
    packageName: '-',
    version: '-',
    buildNumber: '-',
    buildSignature: '-',
    installerStore: '-',
  );

  static Map<String, dynamic> deviceData = <String, dynamic>{};

  static Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'name': build.name,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      'isLowRamDevice': build.isLowRamDevice,
    };
  }

  static Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'modelName': data.modelName,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'isiOSAppOnMac': data.isiOSAppOnMac,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  static Map<String, dynamic> readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  static Map<String, dynamic> readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  static Map<String, dynamic> readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'modelName': data.modelName,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  static Map<String, dynamic> readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }

  static InputDecoration inputDecoration(
    String label, {
    Widget? suffixIcon,
    String? errorText,
    bool enabled = true,
    BoxConstraints? constraints,
  }) {
    return InputDecoration(
      enabled: enabled,
      constraints: constraints ??
          BoxConstraints(
            minHeight: 40.sp,
            maxHeight: 40.sp,
          ),
      contentPadding: const EdgeInsets.all(0),
      suffixIcon: suffixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0x80c0cfe8),
          width: 0.8,
        ),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'GrenadineMVB',
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          color: Colors.black,
        ),
      ),
      errorText: errorText,
      errorMaxLines: 1,
      errorStyle: const TextStyle(
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static InputDecoration inputDecorationV2(
    String label, {
    Widget? suffixIcon,
    String? errorText,
    bool enabled = true,
    BoxConstraints? constraints,
  }) {
    return InputDecoration(
      enabled: enabled,
      constraints: constraints ??
          BoxConstraints(
            minHeight: 40.sp,
            maxHeight: 40.sp,
          ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      suffixIcon: suffixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      // border: const UnderlineInputBorder(
      //   borderSide: BorderSide(
      //     color: Color(0x80c0cfe8),
      //     width: 0.8,
      //   ),
      // ),
      focusedBorder: OutlineInputBorder(
        // borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Color(0xff53b6e2), width: 1.sp),
      ),
      enabledBorder: OutlineInputBorder(
        // borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Colors.grey, width: 1.sp),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.sp),
      ),
      fillColor: Colors.black.withOpacity(0.1),
      filled: enabled ? true : false,
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'GrenadineMVB',
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
          color: Colors.black,
        ),
      ),
      errorText: errorText,
      errorMaxLines: 1,
      errorStyle: const TextStyle(
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static Future<String> get(String url) async {
    if (url.contains('?')) {
      url = '$url&reqToken=' + (Constants.session['token_user_login'] ?? '');
    } else {
      url = '$url?reqToken=' + (Constants.session['token_user_login'] ?? '');
    }
    print(Constants.baseUrl + url);
    Uri uri = Uri.parse(Constants.baseUrl + url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return jsonEncode({
          'status': 'failed',
          'message': 'Koneksi gagal. Coba lagi nanti.',
        });
      }
    } on SocketException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Periksa koneksi internet anda.',
      });
      // print('No Internet connection');
    } on HttpException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
      // print("Couldn't find the post");
    } on FormatException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
      // print("Bad response format");
    } on HandshakeException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
    }
  }

  static Future<String> postJson(String url, Map<String, String> _body) async {
    Uri uri = Uri.parse(Constants.baseUrl + url);

    var body = json.encode(_body);

    print(Constants.baseUrl + url);
    print("Body " + body);

    try {
      var response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + (Constants.session['token'] ?? ''),
          },
          body: body);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return jsonEncode({
          'status': 'failed',
          'message': 'Koneksi gagal. Coba lagi nanti.',
        });
        // throw Exception('Request Failed');
      }
    } on SocketException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Periksa koneksi internet anda.',
      });
      // print('No Internet connection');
    } on HttpException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
      // print("Couldn't find the post");
    } on FormatException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
      // print("Bad response format");
    } on HandshakeException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
    }
  }

  static Future<String> postFile(String url, Map<String, String> body,
      {Map<String, String>? files}) async {
    if (url.contains('?')) {
      url = '$url&reqToken=' + (Constants.session['token_user_login'] ?? '');
    } else {
      url = '$url?reqToken=' + (Constants.session['token_user_login'] ?? '');
    }

    Uri uri = Uri.parse(Constants.baseUrl + url);
    var request = http.MultipartRequest('POST', uri);
    request.fields.addAll(body);
    request.fields
        .addAll({'reqToken': (Constants.session['token_user_login'] ?? '')});

    if (files != null) {
      for (var file in files.entries) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
          file.key,
          file.value,
        );
        request.files.add(multipartFile);
      }
    }

    print(Constants.baseUrl + url);
    print(request.fields);

    try {
      var response = await request.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return responsed.body;
      } else {
        return jsonEncode({
          'status': 'failed',
          'message': 'Koneksi gagal. Coba lagi nanti.',
        });
        // throw Exception('Request Failed');
      }
    } on SocketException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Periksa koneksi internet anda.',
      });
      // print('No Internet connection');
    } on HttpException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
      // print("Couldn't find the post");
    } on FormatException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
      // print("Bad response format");
    } on HandshakeException {
      return jsonEncode({
        'status': 'failed',
        'message': 'Koneksi gagal. Coba lagi nanti.',
      });
    }
  }

  static List<Map<String, dynamic>> menuProfil = [
    {
      'icon': 'person_pin_outlined',
      'title': 'Identitas Pegawai',
      'route': '/identitas',
    },
    {
      'icon': 'person_pin_rounded',
      'title': 'Data Pribadi',
      'route': '/pribadi',
    },
    {
      'icon': 'family_restroom',
      'title': 'Data Keluarga',
      'route': '/keluarga',
    },
    {
      'icon': 'account_box',
      'title': 'Riwayat Jabatan',
      'route': '/jabatan',
    },
    {
      'icon': 'switch_account_outlined',
      'title': 'Rangkap Jabatan',
      'route': '/rangkap',
    },
    {
      'icon': 'content_paste_go',
      'title': 'Riwayat Penugasan',
      'route': '/penugasan',
    },
    {
      'icon': 'school_outlined',
      'title': 'Riwayat Pendidikan',
      'route': '/pendidikan',
    },
    {
      'icon': 'book_rounded',
      'title': 'Riwayat Pelatihan',
      'route': '/pelatihan',
    },
    {
      'icon': 'file_copy',
      'title': 'Data Sertifikat',
      'route': '/sertifikat',
    },
    {
      'icon': 'work',
      'title': 'Pengalaman Kerja',
      'route': '/pengalaman',
    },
    {
      'icon': 'workspace_premium_outlined',
      'title': 'Penghargaan',
      'route': '/penghargaan',
    },
    {
      'icon': 'gavel',
      'title': 'Hukuman',
      'route': '/hukuman',
    },
    {
      'icon': 'health_and_safety',
      'title': 'Riwayat Kesehatan',
      'route': '/kesehatan',
    },
    {
      'icon': 'contact_phone',
      'title': 'Emergency Contact',
      'route': '/emergency',
    },
    {
      'icon': 'date_range_outlined',
      'title': 'Tanggal Acuan Karyawan',
      'route': '/tanggal_acuan',
    },
    {
      'icon': 'paste',
      'title': 'Kontrak (PKWT)',
      'route': '/pkwt',
    },
  ];
}
