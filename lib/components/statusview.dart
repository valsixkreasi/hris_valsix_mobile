import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/configs/constants.dart';

class Statusview extends StatelessWidget {
  final String label;
  final Color color;

  const Statusview({
    super.key,
    this.label = 'Label',
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      // padding: EdgeInsets.only(bottom: 4.sp),
      // margin: EdgeInsets.only(bottom: 10.sp),
      decoration: BoxDecoration(
          // border: Border(
          //   bottom: BorderSide(width: 1, color: Colors.grey),
          // ),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   label,
          //   style: TextStyle(
          //       fontFamily: 'GrenadineMVB',
          //       fontWeight: FontWeight.bold,
          //       fontSize: 10.sp,
          //       color: Colors.black),
          // ),
          IntrinsicWidth(
            child: Container(
              // width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        // fontFamily: 'GrenadineMVB',
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
