import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GridAngle extends StatefulWidget {
  const GridAngle({
    required this.width,
    required this.height,
    this.top,
    this.left,
    this.bottom,
    this.right,
    this.crossAxisCount = 8,
    this.mainAxisSpacing = 5,
    this.crossAxisSpacing = 5,
    this.tiltColor = const Color(0xff315694),
    this.animationDuration = const Duration(milliseconds: 1000),
    this.padding,
    super.key,
  });

  final double width;
  final double height;
  final double? top;
  final double? left;
  final double? bottom;
  final double? right;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Color tiltColor;
  final Duration animationDuration;
  final EdgeInsetsGeometry? padding;

  @override
  _GridAngle createState() => _GridAngle();
}

class _GridAngle extends State<GridAngle> {
  Color borderColor = const Color(0xffaaaaaa);
  double borderWidth = 1.0;
  bool secureText = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      right: widget.right,
      left: widget.left,
      child: Container(
        padding: widget.padding ?? EdgeInsets.only(left: 40.sp),
        width: widget.width,
        height: widget.height,
        child: AnimationLimiter(
          child: GridView.count(
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            children: List.generate(
              widget.crossAxisCount * widget.crossAxisCount,
              (index) {
                int row = (index / widget.crossAxisCount).floor();
                int col = index % widget.crossAxisCount;
                Color color = Colors.transparent;
                if (row + col < widget.crossAxisCount) {
                  color = widget.tiltColor;
                }
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: widget.animationDuration,
                  columnCount: widget.crossAxisCount,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: Container(
                        width: 2.sp,
                        height: 2.sp,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
