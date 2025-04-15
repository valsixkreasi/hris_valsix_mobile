import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';

class MainMenuHome extends StatelessWidget {
  final String iconPath;
  final String title;

  const MainMenuHome({
    super.key,
    this.iconPath = 'assets/images/icons8-profile.png',
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.275.sw,
      // color: Colors.white,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(left: 6.sp, top: 8.sp, bottom: 8.sp),
      // margin: EdgeInsets.only(right: 2.sp),
      child: Row(
        children: [
          Container(
            width: 26.sp,
            height: 26.sp,
            padding: EdgeInsets.all(8.sp),
            margin: EdgeInsets.only(right: 6.sp),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Image.asset(
              iconPath,
              width: 15.sp,
              height: 15.sp,
            ),
          ),
          SizedBox(
            width: 55.sp,
            // color: Colors.grey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    // fontFamily: 'GrenadineMVB',
                    fontWeight: FontWeight.w500,
                    fontSize: 8.5.sp,
                    color: Colors.black,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
