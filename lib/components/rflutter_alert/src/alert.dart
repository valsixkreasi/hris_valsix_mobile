// ignore_for_file: unnecessary_null_comparison

/*
 * rflutter_alert
 * Created by Ratel
 * https://ratel.com.tr
 *
 * Copyright (c) 2018 Ratel, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'dart:async';

import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

import 'alert_style.dart';
import 'animation_transition.dart';
import 'constants.dart';
import 'dialog_button.dart';

/// Main class to create alerts.
///
/// You must call the "show()" method to view the alert class you have defined.
class Alert {
  final String? id;
  final BuildContext context;
  final AlertType? type;

  /// Alert's Style Object
  /// If there is no style provided, default style will be used.
  final AlertStyle style;
  final EdgeInsets? padding;
  final Widget? image;
  final String? title;
  final String? desc;
  final Widget content;

  /// Alert dialog's buttons
  /// if there is no button provided and AlertStyle's "isButtonVisible" parameter
  /// is true, default "Cancel" button will be displayed.
  final List<DialogButton>? buttons;
  final Function? closeFunction;
  final Widget? closeIcon;
  final bool onWillPopActive;
  final bool useRootNavigator;
  final AlertAnimation? alertAnimation;

  /// Alert constructor
  ///
  /// [context] is required.
  Alert({
    required this.context,
    this.id,
    this.type,
    this.style = const AlertStyle(),
    this.padding,
    this.image,
    this.title,
    this.desc,
    this.content = const SizedBox(),
    this.buttons,
    this.closeFunction,
    this.closeIcon,
    this.onWillPopActive = false,
    this.alertAnimation,
    this.useRootNavigator = true,
  });

  /// Displays defined alert window
  Future<bool?> show() async {
    return await showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return _buildDialog();
        },
        barrierDismissible: style.isOverlayTapDismiss,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: style.overlayColor,
        useRootNavigator: useRootNavigator,
        transitionDuration: style.animationDuration,
        transitionBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) =>
            alertAnimation == null
                ? _showAnimation(animation, secondaryAnimation, child)
                : alertAnimation!(
                    context, animation, secondaryAnimation, child));
  }

  /// Dismisses the alert dialog.
  Future<void> dismiss() async {
    Navigator.of(context, rootNavigator: useRootNavigator).pop();
  }

  /// Alert dialog content widget
  Widget _buildDialog() {
    final Widget _child = ConstrainedBox(
      constraints: style.constraints ??
          const BoxConstraints.expand(
              width: double.infinity, height: double.infinity),
      child: Align(
        alignment: style.alertAlignment,
        child: SingleChildScrollView(
          child: AlertDialog(
            key: id == null ? null : Key(id!),
            backgroundColor: style.backgroundColor ??
                Theme.of(context).dialogBackgroundColor,
            shape: style.alertBorder ?? _defaultShape(),
            insetPadding: style.alertPadding ?? defaultAlertPadding,
            elevation: style.alertElevation,
            titlePadding: const EdgeInsets.all(0.0),
            title: SizedBox(
              width: 0.8.sw,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _getCloseButton(),
                    Padding(
                      padding: padding ??
                          EdgeInsets.fromLTRB(20.sp,
                              (style.isCloseButton ? 0 : 10.sp), 20.sp, 0),
                      child: Column(
                        children: <Widget>[
                          _getImage(),
                          title == null ? Container() : SizedBox(height: 15.sp),
                          title == null
                              ? Container()
                              : Text(
                                  title!,
                                  style: style.titleStyle ?? titleStyle,
                                  textAlign: style.titleTextAlign,
                                ),
                          SizedBox(
                            height: desc == null ? 20 : 10,
                          ),
                          desc == null
                              ? Container()
                              : Text(
                                  desc!,
                                  style: style.descStyle ?? descStyle,
                                  textAlign: style.descTextAlign,
                                ),
                          content,
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            contentPadding: style.buttonAreaPadding ?? EdgeInsets.all(20.0.sp),
            content: style.buttonsDirection == ButtonsDirection.column
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _getButtons(),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _getButtons(),
                  ),
          ),
        ),
      ),
    );
    return onWillPopActive
        ? WillPopScope(onWillPop: () async => false, child: _child)
        : _child;
  }

  /// Returns the close button on the top right
  Widget _getCloseButton() {
    return style.isCloseButton
        ? Padding(
            padding: EdgeInsets.fromLTRB(0, 10.sp, 10.sp, 0),
            child: GestureDetector(
              onTap: () {
                if (closeFunction == null) {
                  Navigator.of(context, rootNavigator: useRootNavigator).pop();
                } else {
                  closeFunction!();
                }
              },
              child: Container(
                alignment: FractionalOffset.topRight,
                child: Icon != null
                    ? Container(child: closeIcon)
                    : Container(
                        width: 20.sp,
                        height: 20.sp,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              '$kImagePath/close.png',
                              package: 'rflutter_alert',
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          )
        : Container();
  }

  /// Returns defined buttons. Default: Cancel Button
  List<Widget> _getButtons() {
    List<Widget> expandedButtons = [];
    if (style.isButtonVisible) {
      if (buttons != null) {
        for (var button in buttons!) {
          var buttonWidget = Padding(
            padding: EdgeInsets.only(left: 2.sp, right: 2.sp),
            child: button,
          );
          if ((button.width != null && buttons!.length == 1) ||
              style.buttonsDirection == ButtonsDirection.column) {
            expandedButtons.add(buttonWidget);
          } else {
            expandedButtons.add(Expanded(
              child: buttonWidget,
            ));
          }
        }
      } else {
        Widget cancelButton = DialogButton(
          child: Text(
            "CANCEL",
            style: TextStyle(color: Colors.white, fontSize: 20.sp),
          ),
          onPressed: () => Navigator.pop(context),
        );
        if (style.buttonsDirection == ButtonsDirection.row) {
          cancelButton = Expanded(
            child: cancelButton,
          );
        }
        expandedButtons.add(cancelButton);
      }
    }
    return expandedButtons;
  }

  /// Returns alert default border style
  ShapeBorder _defaultShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0.sp),
      side: const BorderSide(
        color: Colors.blueGrey,
      ),
    );
  }

  /// Returns alert image for icon
  Widget _getImage() {
    Widget response;
    switch (type) {
      case AlertType.success:
        response = Image.asset(
          '$kImagePath/icon_success.png',
          width: 50.sp,
          height: 50.sp,
        );
        break;
      case AlertType.error:
        response = Image.asset(
          '$kImagePath/icon_error.png',
          width: 50.sp,
          height: 50.sp,
        );
        break;
      case AlertType.info:
        response = Image.asset(
          '$kImagePath/icon_info.png',
          width: 50.sp,
          height: 50.sp,
        );
        break;
      case AlertType.warning:
        response = Image.asset(
          '$kImagePath/icon_warning.png',
          width: 50.sp,
          height: 50.sp,
        );
        break;
      case AlertType.none:
        response = Container();
        break;
      default:
        response = image ?? Container();
        break;
    }
    return response;
  }

  /// Shows alert with selected animation
  _showAnimation(animation, secondaryAnimation, child) {
    switch (style.animationType) {
      case AnimationType.fromRight:
        return AnimationTransition.fromRight(
            animation, secondaryAnimation, child);
      case AnimationType.fromLeft:
        return AnimationTransition.fromLeft(
            animation, secondaryAnimation, child);
      case AnimationType.fromBottom:
        return AnimationTransition.fromBottom(
            animation, secondaryAnimation, child);
      case AnimationType.grow:
        return AnimationTransition.grow(animation, secondaryAnimation, child);
      case AnimationType.shrink:
        return AnimationTransition.shrink(animation, secondaryAnimation, child);
      case AnimationType.fromTop:
        return AnimationTransition.fromTop(
            animation, secondaryAnimation, child);
    }
  }
}
