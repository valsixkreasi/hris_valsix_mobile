import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/configs/constants.dart';

class Subtitleview extends StatelessWidget {
  final String label;
  final Color color;

  const Subtitleview({
    super.key,
    this.label = 'Label',
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
        ),
        color: Constants.primaryBlue,
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
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
