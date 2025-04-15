import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class OverlayMenu extends StatefulWidget {
  final List<Icon> icons;
  final List<Text> texts;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  final ValueChanged<int> onChange;

  const OverlayMenu({
    super.key,
    required this.icons,
    required this.texts,
    required this.borderRadius,
    this.backgroundColor = const Color(0xfff67c0b),
    this.iconColor = Colors.black,
    required this.onChange,
  });
  @override
  _OverlayMenuState createState() => _OverlayMenuState();
}

class _OverlayMenuState extends State<OverlayMenu>
    with SingleTickerProviderStateMixin {
  late GlobalKey _key;
  bool isMenuOpen = false;
  late Offset buttonPosition;
  late Size buttonSize;
  late OverlayEntry _overlayEntry;
  late BorderRadius _borderRadius;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _borderRadius = widget.borderRadius;
    _key = LabeledGlobalKey("button_icon");
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  findButton() {
    RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    // buttonSize = renderBox.size;
    buttonSize = Size(33.sp, 33.sp);
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void closeMenu() {
    _overlayEntry.remove();
    _animationController.reverse();
    isMenuOpen = !isMenuOpen;
  }

  void openMenu() {
    findButton();
    _animationController.forward();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context).insert(_overlayEntry);
    isMenuOpen = !isMenuOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // alignment: Alignment.centerRight,
      // color: Colors.amber,
      child: TextButton(
        child: Container(
          key: _key,
          width: 30.sp,
          height: 30.sp,
          padding: EdgeInsets.all(6.sp),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffececec),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/icons8-menu.png',
            // width: 10.sp,
            // height: 10.sp,
            color: Colors.black,
          ),
        ),
        onPressed: () {
          if (isMenuOpen) {
            closeMenu();
          } else {
            openMenu();
          }
        },
      ),
    );
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition.dy + buttonSize.height - 5.sp,
          left: buttonPosition.dx - buttonSize.width * 3.sp,
          width: buttonSize.width * 4.sp,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: ClipPath(
                    clipper: ArrowClipper(),
                    child: Container(
                      width: 17.sp,
                      height: 17.sp,
                      color: widget.backgroundColor,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0.sp),
                  child: Container(
                    height: widget.icons.length * buttonSize.height,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: _borderRadius,
                    ),
                    child: Theme(
                      data: ThemeData(
                        iconTheme:
                            IconThemeData(color: widget.iconColor, size: 15.sp),
                      ),
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.icons.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              widget.onChange(index);
                              closeMenu();
                            },
                            child: Container(
                              width: buttonSize.width * 4.sp,
                              height: buttonSize.height,
                              color: Colors.transparent,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(spacing: 4, children: [
                                  widget.icons[index],
                                  widget.texts[index],
                                ]),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
