import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';

class InputView extends StatelessWidget {
  final String label;
  final String value;

  const InputView({
    super.key,
    this.label = 'Label',
    this.value = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 4.sp),
      margin: EdgeInsets.only(bottom: 10.sp),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontFamily: 'GrenadineMVB',
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
                color: Colors.black),
          ),
          Text(
            value,
            style: TextStyle(
                // fontFamily: 'GrenadineMVB',
                fontSize: 11.sp,
                color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
