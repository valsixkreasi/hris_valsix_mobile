import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/configs/constants.dart';
import 'package:flutter/material.dart';

import 'dropdown_search.dart';

class Select extends StatefulWidget {
  const Select({
    required this.label,
    required this.value,
    required this.onChanged,
    this.items = const [],
    this.showSearchBox = true,
    this.errorText,
    this.enable = true,
    this.required = false,
    Key? key,
  }) : super(key: key);

  final String label;
  final Map<String, dynamic> value;
  final bool showSearchBox;
  final bool enable;
  final bool required;
  final String? errorText;
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic>?)? onChanged;

  @override
  _Select createState() => _Select();
}

class _Select extends State<Select> {
  Map<String, dynamic> selectedItem = {};

  @override
  void initState() {
    setState(() {
      selectedItem = widget.value;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (oldWidget.value['id'] != widget.value['id'] ||
        oldWidget.items.length != widget.items.length) {
      setState(() {
        selectedItem = widget.value;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Map<String, dynamic>>(
      searchDelay: const Duration(milliseconds: 10),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (widget.required) {
          if (value == null || value.isEmpty) {
            return 'harus diisi';
          }
        }
        return null;
      },
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          constraints: BoxConstraints(minHeight: 44.sp),
          contentPadding: EdgeInsets.only(left: 6.sp, right: 6.sp),
          suffixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x80c0cfe8),
              width: 0.8,
            ),
          ),
        ),
      ),
      popupItemBuilder: (context, item, isSelected) =>
          _popupItemBuilder(context, item, isSelected, 0),
      dropdownBuilder: (context, _value) {
        return Text(
          _value!['text'] ?? '',
          style: TextStyle(
            fontFamily: 'GrenadineMVB',
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            fontSize: 11.sp,
            color: Colors.black,
          ),
        );
      },
      dropDownButton: const SizedBox(),
      dropdownSearchDecoration: Constants.inputDecorationV2(
        widget.label,
        suffixIcon: widget.enable
            ? const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              )
            : null,
        errorText: widget.errorText,
      ),
      enabled: widget.enable,
      mode: widget.items.length < 6 ? Mode.MENU : Mode.DIALOG,
      showSearchBox: widget.items.length < 6 ? false : widget.showSearchBox,
      showSelectedItems: true,
      items: widget.items,
      onChanged: (_value) {
        setState(() {
          selectedItem = _value!;
        });
        widget.onChanged!(_value);
      },
      selectedItem: selectedItem,
    );
  }

  Widget _popupItemBuilder(BuildContext context, Map<String, dynamic> item,
      bool isSelected, int level) {
    if (item.containsKey('children')) {
      List<Map<String, dynamic>> children = item['children'];

      return _popupItemBuilder(context, children[0], isSelected, level + 1);
    } else {
      return Container(
        padding: EdgeInsets.only(
          left: 20.sp + (level * 10).sp,
          top: 10.sp,
          bottom: 10.sp,
          right: 10.sp,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.6, color: Colors.black38),
          ),
        ),
        child: Text(
          item['text'] ?? '',
          style: TextStyle(
            fontFamily: 'GrenadineMVB',
            fontWeight: FontWeight.w400,
            fontSize: 11.sp,
            color: Colors.black,
          ),
        ),
      );
    }
  }
}
