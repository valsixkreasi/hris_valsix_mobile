import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';

class InfoPegawaiHome extends StatelessWidget {
  final String iconPath;
  final String title;
  final String desc;

  const InfoPegawaiHome({
    super.key,
    this.iconPath = 'assets/images/icons8-profile.png',
    this.title = '',
    this.desc = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: title == 'Status'
          ? 0.27.sw
          : title == 'Kelompok'
              ? 0.29.sw
              : 0.5.sw,
      // color: Colors.amber,
      padding: EdgeInsets.only(left: 8.sp, top: 10.sp),
      margin: EdgeInsets.only(right: 2.sp),
      child: Row(
        children: [
          Container(
            width: 30.sp,
            height: 30.sp,
            padding: EdgeInsets.all(8.sp),
            margin: EdgeInsets.only(right: 6.sp),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Image.asset(
              iconPath,
              width: 15.sp,
              height: 15.sp,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  // fontFamily: 'GrenadineMVB',
                  fontSize: 9.sp,
                  color: Colors.white,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontFamily: 'GrenadineMVB',
                  fontWeight: FontWeight.bold,
                  fontSize: 9.sp,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
