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

import 'package:hris/screens/notifikasi.dart';
import 'package:hris/screens/jadwal_pelatihan.dart';
// profil
import 'package:hris/screens/profil/identitas.dart';
import 'package:hris/screens/profil/pribadi.dart';
import 'package:hris/screens/profil/keluarga.dart';
import 'package:hris/screens/profil/jabatan/jabatan.dart';
import 'package:hris/screens/profil/jabatan/jabatan_add.dart';
import 'package:hris/screens/profil/jabatan/jabatan_view.dart';
import 'package:hris/screens/profil/rangkap.dart';
import 'package:hris/screens/profil/penugasan.dart';
import 'package:hris/screens/profil/pendidikan.dart';
import 'package:hris/screens/profil/pelatihan/pelatihan.dart';
import 'package:hris/screens/profil/pelatihan/pelatihan_add.dart';
import 'package:hris/screens/profil/pelatihan/pelatihan_view.dart';
import 'package:hris/screens/profil/sertifikat/sertifikat.dart';
import 'package:hris/screens/profil/sertifikat/sertifikat_add.dart';
import 'package:hris/screens/profil/sertifikat/sertifikat_view.dart';
import 'package:hris/screens/profil/pengalaman/pengalaman.dart';
import 'package:hris/screens/profil/pengalaman/pengalaman_add.dart';
import 'package:hris/screens/profil/pengalaman/pengalaman_view.dart';
import 'package:hris/screens/profil/penghargaan.dart';
import 'package:hris/screens/profil/hukuman.dart';
import 'package:hris/screens/profil/kesehatan.dart';
import 'package:hris/screens/profil/emergency.dart';
import 'package:hris/screens/profil/tanggal_acuan.dart';
import 'package:hris/screens/profil/pkwt.dart';
import 'package:hris/screens/profil/log_pengajuan.dart';
// cuti
import 'package:hris/screens/cuti/monitoring.dart';
import 'package:hris/screens/cuti/add.dart';
import 'package:hris/screens/cuti/view.dart';
// izin
import 'package:hris/screens/izin/monitoring.dart';
import 'package:hris/screens/izin/add.dart';
import 'package:hris/screens/izin/view.dart';
// reimburse
import 'package:hris/screens/reimburse/monitoring.dart';
import 'package:hris/screens/reimburse/add.dart';
import 'package:hris/screens/reimburse/view.dart';
// persetujuan
import 'package:hris/screens/persetujuan/monitoring.dart';
// presensi
import 'package:hris/screens/presensi/presensi_map.dart';
import 'package:hris/screens/presensi/presensi_log.dart';
import 'package:hris/screens/presensi/presensi_log_detil.dart';
import 'package:hris/screens/presensi/presensi_log_bawahan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configLoading();

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
                '/notifikasi': (context) => const Notifikasi(),
                '/jadwal_pelatihan': (context) => const JadwalPelatihan(),
                '/identitas': (context) => const Identitas(),
                '/pribadi': (context) => const Pribadi(),
                '/keluarga': (context) => const Keluarga(),
                '/jabatan': (context) => const Jabatan(),
                '/jabatan_add': (context) =>
                    JabatanAdd(arguments: settings.arguments),
                '/jabatan_view': (context) =>
                    JabatanView(arguments: settings.arguments),
                '/rangkap': (context) => const Rangkap(),
                '/penugasan': (context) => const Penugasan(),
                '/pendidikan': (context) => const Pendidikan(),
                '/pelatihan': (context) => const Pelatihan(),
                '/pelatihan_add': (context) =>
                    PelatihanAdd(arguments: settings.arguments),
                '/pelatihan_view': (context) =>
                    PelatihanView(arguments: settings.arguments),
                '/sertifikat': (context) => const Sertifikat(),
                '/sertifikat_add': (context) =>
                    SertifikatAdd(arguments: settings.arguments),
                '/sertifikat_view': (context) =>
                    SertifikatView(arguments: settings.arguments),
                '/pengalaman': (context) => const Pengalaman(),
                '/pengalaman_add': (context) =>
                    PengalamanAdd(arguments: settings.arguments),
                '/pengalaman_view': (context) =>
                    PengalamanView(arguments: settings.arguments),
                '/penghargaan': (context) => const Penghargaan(),
                '/hukuman': (context) => const Hukuman(),
                '/kesehatan': (context) => const Kesehatan(),
                '/emergency': (context) => const Emergency(),
                '/tanggal_acuan': (context) => const TanggalAcuan(),
                '/pkwt': (context) => const Pkwt(),
                '/log_pengajuan': (context) => const LogPengajuan(),
                '/pengajuan_cuti': (context) => const PengajuanCuti(),
                '/pengajuan_cuti_add': (context) =>
                    PengajuanCutiAdd(arguments: settings.arguments),
                '/pengajuan_cuti_view': (context) =>
                    PengajuanCutiView(arguments: settings.arguments),
                '/pengajuan_izin': (context) => const PengajuanIzin(),
                '/pengajuan_izin_add': (context) =>
                    PengajuanIzinAdd(arguments: settings.arguments),
                '/pengajuan_izin_view': (context) =>
                    PengajuanIzinView(arguments: settings.arguments),
                '/pengajuan_reimburse': (context) => const PengajuanReimburse(),
                '/pengajuan_reimburse_add': (context) =>
                    PengajuanReimburseAdd(arguments: settings.arguments),
                '/pengajuan_reimburse_view': (context) =>
                    PengajuanReimburseView(arguments: settings.arguments),
                '/persetujuan': (context) => const Persetujuan(),
                '/presensi': (context) => const PresensiMap(),
                '/presensi_log': (context) => const PresensiLog(),
                '/presensi_log_detil': (context) =>
                    PresensiLogDetil(arguments: settings.arguments),
                '/presensi_log_bawahan': (context) =>
                    const PresensiLogBawahan(),
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
