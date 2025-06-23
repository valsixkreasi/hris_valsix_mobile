import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    required this.label,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.errorText,
    this.value,
    this.items = const [],
    this.showSearchBox = true,
    this.enabled = true,
    this.required = false,
    Key? key,
  }) : super(key: key);

  final DateTime firstDate;
  final DateTime lastDate;
  final String label;
  final String? errorText;
  final DateTime? value;
  final bool showSearchBox;
  final bool required;
  final bool enabled;
  final List<Map<String, dynamic>> items;
  final void Function(DateTime?)? onChanged;

  @override
  DatePickerState createState() => DatePickerState();
}

class DatePickerState extends State<DatePicker> {
  DateTime? selectedItem;
  @override
  void initState() {
    setState(() {
      selectedItem = widget.value;
    });
    super.initState();
  }

  void show() {
    if (widget.enabled) {
      showDatePicker(
        context: context,
        initialDate: widget.value ?? DateTime.now(),
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
      ).then((value) {
        widget.onChanged!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (widget.required) {
          if (value == null) {
            return 'harus diisi';
          }
        }
        return null;
      },
      initialValue: widget.value ?? DateTime.now(),
      builder: (FormFieldState state) {
        return InkWell(
          child: InputDecorator(
            decoration: Constants.inputDecorationV2(
              widget.label,
              suffixIcon: widget.enabled
                  ? const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.black,
                    )
                  : null,
              errorText: widget.errorText,
              enabled: widget.enabled,
            ),
            child: Text(
              widget.value == null
                  ? ''
                  : DateFormat('dd MMM yyyy')
                      .format(widget.value ?? DateTime.now()),
              style: TextStyle(
                fontFamily: 'GrenadineMVB',
                fontWeight: FontWeight.w400,
                fontSize: 11.sp,
                color: Colors.black,
              ),
            ),
          ),
          onTap: show,
        );
      },
    );
  }
}
