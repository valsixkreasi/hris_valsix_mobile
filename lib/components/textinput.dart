import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInput extends StatefulWidget {
  const TextInput({
    required this.label,
    this.initialValue = '',
    this.hintText = '...',
    this.obscureText = false,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.keyboardType,
    this.onchanged,
    super.key,
  });

  final void Function(String?)? onchanged;
  final String initialValue;
  final String hintText;
  final String label;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool required;
  final TextInputType? keyboardType;

  @override
  _TextInput createState() => _TextInput();
}

class _TextInput extends State<TextInput> {
  bool secureText = false;
  bool isInit = true;
  bool isUpdateWidget = false;

  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.initialValue);
    setState(() {
      secureText = widget.obscureText;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (controller.text != widget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (oldWidget.initialValue != widget.initialValue) {
          controller.value = TextEditingValue(
            text: widget.initialValue,
            selection: TextSelection(
              baseOffset: widget.initialValue.length,
              extentOffset: widget.initialValue.length,
            ),
          );
        }
      });
    }

    /*

    if (!isUpdateWidget) {
      isUpdateWidget = true;
      if (isInit) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (oldWidget.initialValue != widget.initialValue) {
            controller.value = TextEditingValue(
              text: widget.initialValue,
              selection: TextSelection(
                baseOffset: widget.initialValue.length,
                extentOffset: widget.initialValue.length,
              ),
            );
          }
        }).then((value) {
          isInit = false;
          isUpdateWidget = false;
        });
      } else {
        isUpdateWidget = true;
        if (oldWidget.initialValue != widget.initialValue) {
          controller.value = TextEditingValue(
            text: widget.initialValue,
            selection: TextSelection(
              baseOffset: widget.initialValue.length,
              extentOffset: widget.initialValue.length,
            ),
          );
        }
        isUpdateWidget = false;
      }
    }
    */
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // validator: (value) {
      //   if (widget.required) {
      //     if (value == null || value.isEmpty) {
      //       return 'harus diisi';
      //     }
      //   }
      //   return null;
      // },
      onChanged: widget.onchanged,
      keyboardType: widget.keyboardType,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 11.sp,
        fontFamily: 'GrenadineMVB',
      ),
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      decoration: Constants.inputDecorationV2(
        widget.label,
        errorText: widget.errorText,
        enabled: widget.enabled,
      ),
      inputFormatters: _inputFormatters(),
    );
  }

  String _getOnlyNumbers(String text) {
    if (text.isNotEmpty && text.substring(0, 1) == "-") {
      return text;
    }
    return text.replaceAll(RegExp(r'[^,\d]'), '');
  }

  List<TextInputFormatter>? _inputFormatters() {
    if (widget.keyboardType == TextInputType.number) {
      return [
        TextInputFormatter.withFunction((oldValue, newValue) {
          String num = _getOnlyNumbers(newValue.text);
          String str = num;
          List<String> parts = [];
          List<String> output = [];
          int i = 1;

          String? formatted;

          if (str.indexOf(',') > 0) {
            parts = str.split(",");
            str = parts[0];
          }

          List<String> strs = str.split("").reversed.toList();
          for (var j = 0, len = strs.length; j < len; j++) {
            if (strs[j] != ".") {
              output.add(strs[j]);
              if (i % 3 == 0 && j < (len - 1)) {
                output.add(".");
              }
              i++;
            }
          }

          formatted = output.reversed.toList().join("");
          String dec = '';
          if (parts.length > 1) {
            dec += ',';
            dec += parts[1];
          }
          var hasil = (formatted + dec);
          var adaMinus = hasil.indexOf('-.');

          if (adaMinus == 0) {
            hasil = hasil.replaceAll('-.', '-');
          }

          return TextEditingValue(
            text: hasil,
            selection: TextSelection(
              baseOffset: hasil.length,
              extentOffset: hasil.length,
            ),
          );
        })
      ];
    }
    return null;
  }
}
