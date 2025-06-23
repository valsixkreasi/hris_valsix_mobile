import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

import 'dropdown_search.dart';

class SelectDialog extends StatefulWidget {
  const SelectDialog({
    required this.label,
    required this.value,
    required this.onChanged,
    this.items = const [],
    this.showSearchBox = true,
    this.errorText,
    Key? key,
  }) : super(key: key);

  final String label;
  final List<Map<String, dynamic>> value;
  final bool showSearchBox;
  final String? errorText;
  final List<Map<String, dynamic>> items;
  final void Function(List<Map<String, dynamic>>)? onChanged;

  @override
  _Select createState() => _Select();
}

class _Select extends State<SelectDialog> {
  List<Map<String, dynamic>> selectedItem = [];

  @override
  void initState() {
    setState(() {
      selectedItem = widget.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Map<String, dynamic>>.multiSelection(
      searchDelay: const Duration(milliseconds: 10),
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          constraints: BoxConstraints(maxHeight: 40.sp),
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
        return Container(
          height: 30.sp,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x10000000),
                offset: Offset(1.0, 2.0),
                blurRadius: 2.0,
                spreadRadius: 1.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xffF47E4C),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.add,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
      showDropdownButton: false,
      dropdownSearchDecoration: InputDecoration(
        constraints: BoxConstraints(
          maxHeight: 30.sp,
          maxWidth: 30.sp,
        ),
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      mode: Mode.DIALOG,
      showSearchBox: widget.showSearchBox,
      showSelectedItems: true,
      items: widget.items,
      onChanged: (_value) {
        setState(() {
          selectedItem = _value;
        });
        widget.onChanged!(_value);
      },
      selectedItems: widget.value,
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
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
      );
    }
  }
}
