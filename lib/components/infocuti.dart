import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';

class InfoCuti extends StatelessWidget {
  final String iconPath;
  final String title;
  final String ambil;
  final String sisa;

  const InfoCuti({
    super.key,
    this.iconPath = 'assets/images/icons8-profile.png',
    this.title = '',
    this.ambil = '',
    this.sisa = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.43.sw,
      // color: Colors.white,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xffdadada),
          width: 0.7.sp,
        ),
      ),
      padding: EdgeInsets.only(left: 6.sp, top: 8.sp, bottom: 8.sp),
      // margin: EdgeInsets.only(right: 2.sp),
      child: Row(
        children: [
          Container(
            width: 35.sp,
            height: 35.sp,
            padding: EdgeInsets.all(8.sp),
            margin: EdgeInsets.only(right: 6.sp),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Image.asset(
              iconPath,
              width: 15.sp,
              height: 15.sp,
            ),
          ),
          Container(
            width: 100.sp,
            // color: Colors.grey,
            padding: EdgeInsets.only(left: 6.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    // fontFamily: 'GrenadineMVB',
                    // fontWeight: FontWeight.w500,
                    fontSize: 9.sp,
                    color: Colors.black,
                  ),
                  softWrap: true,
                ),
                Text(
                  '$ambil/$sisa',
                  style: TextStyle(
                    fontFamily: 'GrenadineMVB',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
