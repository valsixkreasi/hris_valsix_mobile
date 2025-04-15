import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button(
      {required this.child, required this.onPressed, this.padding, super.key});

  final void Function() onPressed;
  final Widget child;
  final EdgeInsets? padding;

  @override
  _Button createState() => _Button();
}

class _Button extends State<Button> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
        ),
        padding: widget.padding,
      ),
      child: widget.child,
    );
  }
}
