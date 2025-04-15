import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';

class TextInputLogin extends StatefulWidget {
  const TextInputLogin(
      {required this.hintText,
      this.iconPath = 'assets/images/username.png',
      this.initialValue = '',
      this.obscureText = false,
      required this.onchanged,
      super.key});

  final void Function(String?) onchanged;
  final String? initialValue;
  final String hintText;
  final bool obscureText;
  final String iconPath;

  @override
  _TextInput createState() => _TextInput();
}

class _TextInput extends State<TextInputLogin> {
  Color borderColor = const Color(0xffaaaaaa);
  double borderWidth = 1.0;
  bool secureText = false;

  @override
  void initState() {
    setState(() {
      secureText = widget.obscureText;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.sp),
      padding: EdgeInsets.only(
        left: 15.sp,
        right: 15.sp,
      ),
      width: 0.7.sw,
      height: 40.sp,
      decoration: BoxDecoration(
        color: const Color(0xffe9e7e7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Color(0xffd9d6d6),
          width: 1,
        ),
      ),
      child: FocusScope(
        child: Focus(
          onFocusChange: (focus) {
            if (focus) {
              setState(() {
                borderColor = const Color(0xff55b5e5);
                borderWidth = 2.0.sp;
              });
            } else {
              setState(() {
                borderColor = const Color(0xffaaaaaa);
                borderWidth = 1.0.sp;
              });
            }
          },
          child: Row(
            children: <Widget>[
              Image.asset(
                widget.iconPath,
                width: 16.sp,
                height: 16.sp,
              ),
              Expanded(
                child: TextFormField(
                  initialValue: widget.initialValue,
                  onChanged: widget.onchanged,
                  style: TextStyle(
                    color: borderColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    fontFamily: 'Poppins',
                  ),
                  obscureText: secureText,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: 0.03.swr,
                      right: 0.03.swr,
                    ),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              widget.obscureText
                  ? IconButton(
                      icon: Image.asset(
                        secureText
                            ? 'assets/images/icons8-invisible.png'
                            : 'assets/images/icons8-eye.png',
                        width: 18.sp,
                        height: 18.sp,
                        color: const Color(0xff6883b0),
                      ),
                      padding: const EdgeInsets.all(0),
                      alignment: Alignment.centerRight,
                      iconSize: 16.sp,
                      onPressed: () {
                        setState(() {
                          secureText = !secureText;
                        });
                      },
                    )
                  : SizedBox(
                      width: 16.sp,
                      height: 16.sp,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
