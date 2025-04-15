// ignore_for_file: prefer_const_constructors, unused_field, unused_element

import 'package:dynamic_icons/dynamic_icons.dart';
import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/configs/constants.dart';

import 'expansiontile.dart';

class NavHeader extends StatefulWidget {
  const NavHeader({
    required this.children,
    required this.scaffoldKey,
    this.title,
    this.badges = const [0, 11, 8, 0, 0],
    this.showBottomNavigationBar = true,
    this.showDrawer = true,
    this.floatingActionButton,
    super.key,
  });

  final List<Widget> children;
  final List<int> badges;
  final Widget? title;
  final Widget? floatingActionButton;
  final bool showBottomNavigationBar;
  final bool showDrawer;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _NavHeader createState() => _NavHeader();
}

class _NavHeader extends State<NavHeader> {
  int _selectedIndex = 0;
  bool _customTileExpanded = false;

  String route = '';

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      drawer: _createDrawer(),
      extendBody: true,
      resizeToAvoidBottomInset: true,
      floatingActionButton: widget.floatingActionButton,
      backgroundColor: const Color(0xfff8f8fa),
      bottomNavigationBar: _createBottomNavigationBar(),
      body: Container(
        color: const Color(0xfff8f8fa),
        child: Stack(
          children: [
            // Area bakground gambar
            Positioned(
              top: 0.5.shr,
              left: -0.15.swr,
              child: Image.asset(
                'assets/images/circural.png',
                width: 0.7.swr,
                height: 0.7.swr,
                opacity: AlwaysStoppedAnimation(0.7),
              ),
            ),
            // Area Boddy
            ListView(
              children: widget.children,
            ),
            // Area StatusBar
            Positioned(
              top: 0,
              child: Container(
                width: 1.sw,
                height: ScreenUtil().statusBarHeight,
                color: const Color(0xffececec),
              ),
            ),
            // Area Header
            Positioned(
              top: ScreenUtil().statusBarHeight,
              child: Container(
                width: 1.sw,
                height: 50.sp,
                decoration: BoxDecoration(
                  // color: const Color(0xffcccccc),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: widget.title,
              ),
            ),
            // Area Garis dibawah header
            Positioned(
              top: 71.sp,
              right: 15.sp,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 0.57.sw,
                    height: 1.sp,
                    color: Constants.primaryGreen,
                    margin: EdgeInsets.only(right: 3.sp),
                  ),
                  Container(
                    width: 0.1.sw,
                    height: 1.4.sp,
                    color: Constants.primaryBlue,
                    margin: EdgeInsets.only(right: 3.sp),
                  ),
                  Container(
                    width: 0.1.sw,
                    height: 2.sp,
                    color: Constants.primaryYellow,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget? _createDrawer() {
    if (!widget.showDrawer) {
      return null;
    }
    List<Widget> drawerMenu = [];
    List<Widget> drawerMenuProfil = [];
    List<Map<String, dynamic>> menu = [];
    List<Map<String, dynamic>> menuProfil = [];

    // menu = Constants.menuTrans;
    menuProfil = Constants.menuProfil;

    drawerMenu = menu.map((title) {
      List<Widget> child = [];
      for (var element in (title['menu'] as List)) {
        child.add(ListTile(
          onTap: () {
            routeTo(element['route'] ?? '');
          },
          // selected: route == (element['route'] ?? ''),
          // selectedTileColor: Color(0xff009ee9),
          contentPadding: EdgeInsets.only(left: 30.sp),
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(
            (element['title'] ?? ''),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: const Color(0xff333333),
            ),
          ),
        ));
      }

      return MyExpansionTile(
        childrenPadding: EdgeInsets.zero,
        title: Text(
          (title['title'] ?? ''),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: const Color(0xff333333),
          ),
        ),
        trailing: Icon(
          _customTileExpanded
              ? Icons.arrow_drop_down_circle
              : Icons.arrow_drop_down,
        ),
        children: child,
        onExpansionChanged: (bool expanded) {
          setState(() => _customTileExpanded = expanded);
        },
      );
    }).toList();

    drawerMenuProfil = menuProfil.map((item) {
      return Column(
        children: [
          ListTile(
            leading: DynamicIcons.getIconFromName(item['icon'] ?? ''),
            title: Text(
              (item['title'] ?? ''),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'GrenadineMVB',
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
                color: const Color(0xff333333),
              ),
            ),
            // trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              routeTo(item['route'] ?? '');
            },
            // selected: route == (element['route'] ?? ''),
            // selectedTileColor: Color(0xff009ee9),
            // tileColor: Colors.cyan,
            // contentPadding: EdgeInsets.only(left: 20.sp),
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            // leading: Icon(Icons.switch_account_outlined),
          ),
          Divider(height: 2),
        ],
      );
    }).toList();

    return SizedBox(
      width: 0.7.sw,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              height: 0.3.sh,
              padding: EdgeInsets.all(15.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const <Color>[
                    Color(0xff24cc43),
                    Color(0xff1eb93b),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
                    padding: EdgeInsets.only(top: 10.sp),
                    width: 0.15.sw,
                    child: Image.asset(
                      'assets/images/foto.png',
                      height: 37.sp,
                      width: 37.sp,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    Constants.session['data']['pegawai'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'GrenadineMVB',
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    Constants.session['data']['nrp'],
                    style: TextStyle(
                      fontFamily: 'GrenadineMVB',
                      fontWeight: FontWeight.normal,
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    Constants.session['data']['jabatan'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'GrenadineMVB',
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            // ...drawerMenu,
            ...drawerMenuProfil,
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void routeTo(String r) {
    setState(() {
      route = r;
    });
    Navigator.pushNamed(context, r);
  }

  Widget? _createBottomNavigationBar() {
    return null;
    /*
    if (!widget.showBottomNavigationBar) {
      return null;
    }
    Map<String, dynamic> session = Constants.session;
    List<BottomNavigationBarItem> barItem = [];
    if (session['USER_TYPE'] == 'ADMIN' || session['USER_TYPE'] == 'Staff') {
      barItem = [
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 50.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? const Color(0xffee8048)
                        : const Color(0xffc0cfe8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons8-equal_housing_opportunity.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 0
                            ? Colors.white
                            : const Color(0xff4369a9),
                      ),
                      Text(
                        'Home',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          wordSpacing: 0,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          color: _selectedIndex == 0
                              ? Colors.white
                              : const Color(0xff333333),
                        ),
                      ),
                    ],
                  ),
                ),
                _createBadge(0)
              ],
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 50.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? const Color(0xffee8048)
                        : const Color(0xffc0cfe8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons8-sign_document.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 1
                            ? Colors.white
                            : const Color(0xff4369a9),
                      ),
                      Text(
                        'Permintaan',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          wordSpacing: 0,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          color: _selectedIndex == 1
                              ? Colors.white
                              : const Color(0xff333333),
                        ),
                      ),
                    ],
                  ),
                ),
                _createBadge(1)
              ],
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 50.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? const Color(0xffee8048)
                        : const Color(0xffc0cfe8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons8-data_quality.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 2
                            ? Colors.white
                            : const Color(0xff4369a9),
                      ),
                      Text(
                        'Verifikasi',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          wordSpacing: 0,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          color: _selectedIndex == 2
                              ? Colors.white
                              : const Color(0xff333333),
                        ),
                      ),
                    ],
                  ),
                ),
                _createBadge(2)
              ],
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 50.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3
                        ? const Color(0xffee8048)
                        : const Color(0xffc0cfe8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons8-petrol.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 3
                            ? Colors.white
                            : const Color(0xff4369a9),
                      ),
                      Text(
                        'Jenis BBM',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          wordSpacing: 0,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          color: _selectedIndex == 3
                              ? Colors.white
                              : const Color(0xff333333),
                        ),
                      ),
                    ],
                  ),
                ),
                _createBadge(3)
              ],
            ),
          ),
          label: 'Jenis BBM',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 50.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 4
                        ? const Color(0xffee8048)
                        : const Color(0xffc0cfe8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons8-map_marker.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 4
                            ? Colors.white
                            : const Color(0xff4369a9),
                      ),
                      Text(
                        'Wilayah',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          wordSpacing: 0,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          color: _selectedIndex == 4
                              ? Colors.white
                              : const Color(0xff333333),
                        ),
                      ),
                    ],
                  ),
                ),
                _createBadge(4)
              ],
            ),
          ),
          label: 'Wilayah',
        ),
      ];
    } else {
      barItem = [
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 50.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? const Color(0xffee8048)
                        : const Color(0xffc0cfe8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons8-equal_housing_opportunity.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 0
                            ? Colors.white
                            : const Color(0xff4369a9),
                      ),
                      Text(
                        'Home',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          wordSpacing: 0,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          color: _selectedIndex == 0
                              ? Colors.white
                              : const Color(0xff333333),
                        ),
                      ),
                    ],
                  ),
                ),
                _createBadge(0)
              ],
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 50.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? const Color(0xffee8048)
                        : const Color(0xffc0cfe8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons8-recieve.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 1
                            ? Colors.white
                            : const Color(0xff4369a9),
                      ),
                      Text(
                        'Pengambilan',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          wordSpacing: 0,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          color: _selectedIndex == 1
                              ? Colors.white
                              : const Color(0xff333333),
                        ),
                      ),
                    ],
                  ),
                ),
                _createBadge(1)
              ],
            ),
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
          ),
          label: 'Jenis BBM',
        ),
        const BottomNavigationBarItem(
          icon: SizedBox(
            width: 76.0,
            height: 50.0,
          ),
          label: 'Wilayah',
        ),
      ];
    }
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0x20ffffff),
            Color(0x80ffffff),
            Color(0xaaffffff)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.clamp,
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0x00ffffff),
        items: barItem,
      ),
    );
    */
  }

  Widget _createBadge(int index) {
    int badge = widget.badges[index];

    if (badge > 0) {
      return Positioned(
        top: 0,
        right: 0,
        width: 20,
        height: 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            badge.toString(),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              letterSpacing: 0,
              wordSpacing: 0,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Color(0xffff5000),
            ),
          ),
        ),
      );
    }
    return const Positioned(
      top: 0,
      right: 0,
      width: 20,
      height: 20,
      child: SizedBox(),
    );
  }
}
