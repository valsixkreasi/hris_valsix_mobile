import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hris/components/gridangle.dart';
import 'package:hris/components/textinputlogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spring/spring.dart';

import 'package:hris/configs/constants.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';

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
  late bool isLogin;
  late bool _isLoggedIn = false;
  late Timer timer;
  String tokenFirebase = '';

  @override
  void initState() {
    timer = Timer(const Duration(seconds: 4), getSession);
    super.initState();
  }

  void getSession() {
    _getSession().then((value) {
      if (value != null) {
        Map<String, dynamic> session =
            jsonDecode(value) as Map<String, dynamic>;
        Constants.session = session;

        // if (Constants.session['USER_TYPE'] == 'TRANSPORTIR') {
        //   Navigator.pushReplacementNamed(context, '/home_transportir');
        // } else if (Constants.session['USER_TYPE'] == 'OPERATOR') {
        //   Navigator.pushReplacementNamed(context, '/home_operator');
        // } else if (Constants.session['USER_TYPE'] == 'CUSTOMER') {
        //   Navigator.pushReplacementNamed(context, '/home_customer');
        // } else {
        //   Navigator.pushReplacementNamed(context, '/home_staff');
        // }
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
          // child: _isLoggedIn ? const Login() : __Splash(),
          child: __Splash(),
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
            Color(0xff315694),
            Color(0xff5e7fb6),
          ],
        ),
      ),
      padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
      width: 1.sw,
      height: 1.sh,
      child: Stack(
        children: [
          // gambar pojok kanan bawah
          Positioned(
            bottom: 0,
            right: 0,
            child: Spring.translate(
              beginOffset: Offset(0.7.swr, 0),
              endOffset: const Offset(0, 0),
              animDuration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              delay: const Duration(seconds: 1),
              child: Image.asset(
                'assets/images/footer.png',
                width: 0.7.swr,
                height: 0.7.swr,
              ),
            ),
          ),
          // tulisan pojok kiri bawah
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              // color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Spring.translate(
                  beginOffset: Offset(-0.4.swr, 0),
                  endOffset: Offset(0, 0),
                  animDuration: Duration(seconds: 1),
                  child: Text(
                    '© 2022',
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Audiowide',
                      color: Color(0xffee8048),
                    ),
                  )),
            ),
          ),
          // log PEL pojok kiri atas
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.all(30.sp),
              child: Spring.scale(
                start: 0.0,
                end: 1.0,
                animDuration: Duration(microseconds: 600),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/images/logo-pel.png',
                  width: 0.3.swr,
                  height: 0.3.swr,
                ),
              ),
            ),
          ),
          // gambar polkadot
          GridAngle(
            width: 0.36.swr,
            height: 0.6.swr,
            top: 0.55.sh,
            left: 0,
          ),
          Positioned(
            top: 0.5.sh,
            left: 0,
            child: Container(
              padding: EdgeInsets.only(left: 20.sp),
              width: 0.64.swr,
              height: 0.64.swr,
              child: Spring.flip(
                springController: springFlipController,
                frontWidget: Image.asset(
                  'assets/images/bbm-man.png',
                  width: 0.64.swr,
                  height: 0.64.swr,
                ),
                rearWidget: Image.asset(
                  'assets/images/bbm-man.png',
                  width: 0.64.swr,
                  height: 0.64.swr,
                ),
                animDuration: Duration(milliseconds: 800),
              ),
            ),
          ),
          Positioned(
            top: 0.08.shr,
            left: 0.15.swr,
            child: Spring.scale(
              start: 0.0,
              end: 1.0,
              delay: const Duration(milliseconds: 100),
              animDuration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Spring.translate(
                beginOffset: const Offset(-200, -100),
                endOffset: const Offset(0, 0),
                delay: const Duration(milliseconds: 100),
                animDuration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/images/fitur1.png',
                  width: 0.75.swr,
                  height: 0.75.swr,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.08.shr,
            left: 0.15.swr,
            child: Spring.scale(
              start: 0.0,
              end: 1.0,
              delay: const Duration(milliseconds: 500),
              animDuration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Spring.translate(
                beginOffset: const Offset(-200, -100),
                endOffset: const Offset(0, 0),
                delay: const Duration(milliseconds: 500),
                animDuration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/images/fitur2.png',
                  width: 0.75.swr,
                  height: 0.75.swr,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.08.shr,
            left: 0.15.swr,
            child: Spring.scale(
              start: 0.0,
              end: 1.0,
              delay: const Duration(milliseconds: 900),
              animDuration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Spring.translate(
                beginOffset: const Offset(-200, -100),
                endOffset: const Offset(0, 0),
                delay: const Duration(milliseconds: 900),
                animDuration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/images/fitur3.png',
                  width: 0.75.swr,
                  height: 0.75.swr,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.08.shr,
            left: 0.15.swr,
            child: Spring.scale(
              start: 0.0,
              end: 1.0,
              delay: const Duration(milliseconds: 1300),
              animDuration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Spring.translate(
                beginOffset: const Offset(-200, -100),
                endOffset: const Offset(0, 0),
                delay: const Duration(milliseconds: 1300),
                animDuration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/images/fitur4.png',
                  width: 0.75.swr,
                  height: 0.75.swr,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.08.shr,
            left: 0.15.swr,
            child: Spring.scale(
              start: 0.0,
              end: 1.0,
              delay: const Duration(milliseconds: 1700),
              animDuration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Spring.translate(
                beginOffset: const Offset(-200, -100),
                endOffset: const Offset(0, 0),
                delay: const Duration(milliseconds: 1700),
                animDuration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                animStatus: (p0) {
                  springFlipController.play();
                },
                child: Image.asset(
                  'assets/images/fitur5.png',
                  width: 0.75.swr,
                  height: 0.75.swr,
                ),
              ),
            ),
          ),
        ],
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
  String reqUser = '';
  String reqPasswd = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xff315694),
              Color(0xff5e7fb6),
            ],
          ),
        ),
        padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
        width: 1.sw,
        height: 1.sh,
        child: Stack(
          children: [
            GridAngle(
              width: 0.36.swr,
              height: 0.6.swr,
              top: 0.54.sh,
              left: 0,
              padding: EdgeInsets.only(left: 30.sp),
              crossAxisCount: 8,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            Center(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: ScreenUtil().statusBarHeight,
                      bottom: 20.sp,
                    ),
                    child: Image.asset(
                      'assets/images/logo-pel-1.png',
                      width: 0.3.swr,
                      height: 0.3.swr,
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      'assets/images/icons8-petrol.png',
                      width: 0.1.sw,
                      height: 0.1.sw,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'SYSTEM',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp,
                      color: const Color(0xff9abde9),
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    'Keagenan BBM',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 24.sp,
                      color: const Color(0xffffffff),
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
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
