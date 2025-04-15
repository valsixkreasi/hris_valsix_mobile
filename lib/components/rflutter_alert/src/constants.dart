/*
 * rflutter_alert
 * Created by Ratel
 * https://ratel.com.tr
 *
 * Copyright (c) 2018 Ratel, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

/// Alert types
enum AlertType { error, success, info, warning, none }

/// Alert animation types
enum AnimationType { fromRight, fromLeft, fromTop, fromBottom, grow, shrink }

/// Buttons container
enum ButtonsDirection { row, column }

/// Default Alert Padding
/// horizontal: 40.0 , vertical: 24.0
EdgeInsets defaultAlertPadding =
    EdgeInsets.symmetric(horizontal: 40.sp, vertical: 24.sp);

TextStyle titleStyle = TextStyle(
  color: Colors.black,
  fontSize: 16.sp,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w800,
);

TextStyle descStyle = TextStyle(
  color: Colors.black,
  fontSize: 14.sp,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w600,
);

/// Library images path
const String kImagePath = "assets/images";

typedef AlertAnimation = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);
