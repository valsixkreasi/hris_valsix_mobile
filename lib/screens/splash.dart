import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hris/components/textinputlogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spring/spring.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:hris/configs/constants.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/button.dart';

Future<String?> _getSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('session');
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  late bool isLogin;
  late bool _isLoggedIn = false;
  late Timer timer;
  String tokenFirebase = '';

  @override
  void initState() {
    initPlatformState(); // get info device
    initPackageInfo(); // get info aplikasi
    timer = Timer(const Duration(seconds: 4), getSession);
    super.initState();
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    Constants.packageInfo = info;
  }

  Future<void> initPlatformState() async {
    try {
      if (kIsWeb) {
        Constants.deviceData =
            Constants.readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        Constants.deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            Constants.readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
            Constants.readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.linux =>
            Constants.readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows =>
            Constants.readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS =>
            Constants.readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          TargetPlatform.fuchsia => <String, dynamic>{
              'Error:': 'Fuchsia platform isn\'t supported'
            },
        };
      }
    } on PlatformException {
      Constants.deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    if (kDebugMode) {
      print(Constants.deviceData);
    }
  }

  void getSession() {
    _getSession().then((value) {
      if (value != null) {
        Map<String, dynamic> session =
            jsonDecode(value) as Map<String, dynamic>;
        Constants.session = session;

        // print(session);

        if (Constants.session['USER_TYPE'] == 'TRANSPORTIR') {
          Navigator.pushReplacementNamed(context, '/home_transportir');
        } else if (Constants.session['USER_TYPE'] == 'OPERATOR') {
          Navigator.pushReplacementNamed(context, '/home');
          // Navigator.pushReplacementNamed(context, '/home_operator');
        } else if (Constants.session['USER_TYPE'] == 'CUSTOMER') {
          Navigator.pushReplacementNamed(context, '/home_customer');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _isLoggedIn = true;
        });
      }
      timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 1000),
          reverse: !_isLoggedIn,
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          child: _isLoggedIn ? const Login() : __Splash(),
        ),
      ),
    );
  }
}

class __Splash extends StatelessWidget {
  final SpringController springFlipController = SpringController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xfff8f8fa),
            Color(0xffeeeeef),
          ],
        ),
      ),
      padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
      width: 1.sw,
      height: 1.sh,
      child: Center(
        child: Stack(
          children: [
            // logo splash
            Container(
              padding: EdgeInsets.all(20),
              child: Spring.scale(
                start: 0.0,
                end: 1.0,
                delay: const Duration(milliseconds: 800),
                animDuration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/images/logo-splash.png',
                  width: 0.4.swr,
                  height: 0.4.swr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isFetching = false;
  String reqUser = '';
  String reqPasswd = '';
  String reqDeviceId = '';
  String reqImei = '';

  @override
  void initState() {
    super.initState();
  }

  /*
  Future<void> postRequest1() async {
    Uri url = Uri.parse('http://103.130.130.233:81/ptpn-hris/public/api/home');

    var body = jsonEncode({});

    print("Body: " + body);

    var response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer 9acda58bbf60ac81e696eb29d102f3b7',
        },
        body: body);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
  */

  Future<void> fetchLogin() async {
    if (!isFetching) {
      setState(() {
        isFetching = true;
        reqDeviceId =
            Constants.deviceData['model'] + '#' + Constants.deviceData['id'];
        reqImei =
            Constants.deviceData['model'] + '#' + Constants.deviceData['id'];
      });

      Map<String, String> pbody = {
        'username': reqUser,
        'password': reqPasswd,
        'device_id': reqDeviceId,
        'imei': reqImei,
      };

      // log('body => $pbody');
      // print(pbody);

      var response = await Constants.postJson('login', pbody);
      Map<String, dynamic> responseJson = {};
      try {
        responseJson = jsonDecode(response) as Map<String, dynamic>;
      } on FormatException {
        EasyLoading.showToast(
          'Network error!',
          duration: const Duration(seconds: 1),
        );
      }

      setState(() {
        isFetching = false;
      });

      if (responseJson['status'] == 'success') {
        EasyLoading.showToast(
          responseJson['message'] ?? '',
          duration: const Duration(seconds: 1),
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('session', response);
        Constants.session = responseJson;

        print(responseJson);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        EasyLoading.showToast(
          responseJson['message'] ?? '',
          duration: const Duration(seconds: 1),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          // color: Color(0xff888888),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xfff8f8fa),
              Color(0xffeeeeef),
            ],
          ),
        ),
        padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
        width: 1.sw,
        height: 1.sh,
        child: Stack(
          children: [
            Positioned(
              top: 0.5.shr,
              left: -0.15.swr,
              child: Image.asset(
                'assets/images/circural.png',
                width: 0.7.swr,
                height: 0.7.swr,
              ),
            ),
            Center(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: ScreenUtil().statusBarHeight,
                      bottom: 100.sp,
                    ),
                    child: Image.asset(
                      'assets/images/logo_ptpn1.png',
                      width: 0.3.swr,
                      height: 0.3.swr,
                    ),
                  ),
                  Text(
                    'HRIS',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GrenadineMVB',
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,
                      color: const Color(0xff2ccd39),
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    'Application',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GrenadineMVB',
                      fontStyle: FontStyle.italic,
                      fontSize: 14.sp,
                      color: const Color(0xff000000),
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.sp),
                    // color: Color(0xffffffff),
                    width: 0.8.sw,
                    height: 0.4.sh,
                    child: Column(
                      children: [
                        TextInputLogin(
                          hintText: 'Username...',
                          initialValue: reqUser,
                          iconPath: 'assets/images/username.png',
                          onchanged: (value) {
                            setState(() {
                              reqUser = value!;
                            });
                          },
                        ),
                        TextInputLogin(
                          hintText: 'Password...',
                          initialValue: reqPasswd,
                          iconPath: 'assets/images/password.png',
                          onchanged: (value) {
                            setState(() {
                              reqPasswd = value!;
                            });
                          },
                          obscureText: true,
                        ),
                        Container(
                          width: 0.7.sw,
                          height: 40.sp,
                          margin: EdgeInsets.only(top: 10.sp),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color(0xff55b5e5),
                                Color(0xff3699cb),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6.sp),
                              topRight: Radius.circular(6.sp),
                              bottomLeft: Radius.circular(6.sp),
                              bottomRight: Radius.circular(6.sp),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x10000000),
                                offset: Offset(1.0, 2.0),
                                blurRadius: 2.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Button(
                            child: isFetching
                                ? SizedBox(
                                    height: 16.0.sp,
                                    width: 16.0.sp,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0.sp,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontFamily: 'GrenadineMVB',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                            onPressed: () {
                              // postRequest();
                              fetchLogin();
                              // Navigator.pushReplacementNamed(context, '/home');
                              // setState(() {
                              //   isFetching = true;
                              // });
                              // Timer(const Duration(seconds: 2), () {
                              //   // Navigator.pushNamed(context, '/home');
                              //   Navigator.pushReplacementNamed(
                              //       context, '/home');
                              // });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'App version ${Constants.packageInfo.version}',
                    style: TextStyle(
                        fontFamily: 'GrenadineMVB',
                        fontSize: 10.sp,
                        color: Color(0xff888888)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
