import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatefulWidget {
  const DateRangePicker({
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
  final DateTimeRange? value;
  final bool showSearchBox;
  final bool enabled;
  final bool required;
  final List<Map<String, dynamic>> items;
  final void Function(DateTimeRange)? onChanged;

  @override
  DateRangePickerState createState() => DateRangePickerState();
}

class DateRangePickerState extends State<DateRangePicker> {
  DateTimeRange? selectedItem;
  @override
  void initState() {
    setState(() {
      selectedItem = widget.value;
    });
    super.initState();
  }

  void show() {
    if (widget.enabled) {
      showDateRangePicker(
        context: context,
        initialDateRange: widget.value,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
      ).then((value) {
        widget.onChanged!(value!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTimeRange>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (widget.required) {
          if (value == null) {
            return 'harus diisi';
          }
        }
        return null;
      },
      initialValue: widget.value,
      builder: (FormFieldState state) {
        return InkWell(
          child: InputDecorator(
            decoration: Constants.inputDecoration(
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
                  : (DateFormat('dd MMM yyyy').format(widget.value!.start) +
                      ' - ' +
                      DateFormat('dd MMM yyyy').format(widget.value!.end)),
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
