import 'package:flutter/material.dart';

class ButtonIcon extends StatefulWidget {
  const ButtonIcon({
    this.labelColor = Colors.white,
    this.bgColor = Colors.blue,
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final Color labelColor;
  final Color bgColor;
  final Icon icon;
  final Text label;
  final void Function() onPressed;

  @override
  State<ButtonIcon> createState() => _ButtonIconState();
}

class _ButtonIconState extends State<ButtonIcon> {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: widget.labelColor,
        backgroundColor: widget.bgColor,
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        minimumSize: Size(100, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: widget.onPressed,
      icon: widget.icon,
      label: widget.label,
    );
  }
}
