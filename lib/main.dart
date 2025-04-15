import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:hris/models/session.dart';
import 'package:hris/models/home.dart';
import 'package:hris/configs/constants.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';

import 'package:hris/screens/splash.dart';
import 'package:hris/screens/home.dart';
import 'package:hris/screens/viewpdf.dart';

import 'package:hris/screens/profil/identitas.dart';
import 'package:hris/screens/profil/pribadi.dart';
import 'package:hris/screens/profil/keluarga.dart';
import 'package:hris/screens/profil/jabatan.dart';
import 'package:hris/screens/profil/rangkap.dart';
import 'package:hris/screens/profil/penugasan.dart';
import 'package:hris/screens/profil/pendidikan.dart';
import 'package:hris/screens/profil/pelatihan.dart';
import 'package:hris/screens/profil/sertifikat.dart';
import 'package:hris/screens/profil/pengalaman.dart';
import 'package:hris/screens/profil/penghargaan.dart';
import 'package:hris/screens/profil/hukuman.dart';
import 'package:hris/screens/profil/kesehatan.dart';
import 'package:hris/screens/profil/emergency.dart';
import 'package:hris/screens/profil/tanggalacuan.dart';
import 'package:hris/screens/profil/pkwt.dart';

import 'package:hris/screens/cuti/monitoring.dart';
import 'package:hris/screens/cuti/add.dart';
import 'package:hris/screens/cuti/view.dart';

void main() async {
  configLoading();
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );

  runApp(MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    // ignore: deprecated_member_use
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  void initState() {
    // setupNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _providers(),
      builder: (context, widget) {
        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: () => MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            title: 'HRIS',
            initialRoute: '/',
            // theme: ThemeData(fontFamily: 'Poppins'),
            builder: (context, widget) {
              ScreenUtil.setContext(context);
              return FlutterEasyLoading(child: widget);
            },
            onGenerateRoute: (RouteSettings settings) {
              Constants.route = settings.name ?? '';
              var routes = <String, WidgetBuilder>{
                '/': (context) => const Splash(),
                '/home': (context) => Home(),
                '/viewpdf': (context) => ViewPDF(arguments: settings.arguments),
                '/identitas': (context) => const Identitas(),
                '/pribadi': (context) => const Pribadi(),
                '/keluarga': (context) => const Keluarga(),
                '/jabatan': (context) => const Jabatan(),
                '/rangkap': (context) => const Rangkap(),
                '/penugasan': (context) => const Penugasan(),
                '/pendidikan': (context) => const Pendidikan(),
                '/pelatihan': (context) => const Pelatihan(),
                '/sertifikat': (context) => const Sertifikat(),
                '/pengalaman': (context) => const Pengalaman(),
                '/penghargaan': (context) => const Penghargaan(),
                '/hukuman': (context) => const Hukuman(),
                '/kesehatan': (context) => const Kesehatan(),
                '/emergency': (context) => const Emergency(),
                '/tanggal_acuan': (context) => const TanggalAcuan(),
                '/pkwt': (context) => const Pkwt(),
                '/pengajuan_cuti': (context) => const PengajuanCuti(),
                '/pengajuan_cuti_add': (context) => PengajuanCutiAdd(),
                '/pengajuan_cuti_view': (context) => PengajuanCutiView(),
              };

              WidgetBuilder? builder = routes[settings.name];
              return MaterialPageRoute(
                builder: (ctx) => builder!(ctx),
                settings: settings,
              );
            },
          ),
        );
      },
    );
  }

  List<SingleChildWidget> _providers() {
    return [
      ChangeNotifierProvider(create: (context) => SessionModel()),
      ChangeNotifierProvider(create: (context) => HomeModel(context)),
    ];
  }
}

class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    return Opacity(
      opacity: controller.value,
      child: RotationTransition(
        turns: controller,
        child: child,
      ),
    );
  }
}
