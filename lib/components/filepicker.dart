import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/rflutter_alert/rflutter_alert.dart';
import 'package:hris/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

class FilesPicker extends StatefulWidget {
  const FilesPicker({
    required this.label,
    required this.onChanged,
    this.errorText,
    this.value,
    this.link = '',
    this.items = const [],
    this.showSearchBox = true,
    this.enabled = true,
    this.required = false,
    this.fromCamera = false,
    Key? key,
  }) : super(key: key);

  final String label;
  final String link;
  final String? errorText;
  final FilePickerResult? value;
  final bool showSearchBox;
  final bool enabled;
  final bool required;
  final bool fromCamera;
  final List<Map<String, dynamic>> items;
  final void Function(FilePickerResult?)? onChanged;

  @override
  FilesPickerState createState() => FilesPickerState();
}

class FilesPickerState extends State<FilesPicker> {
  FilePickerResult? selectedItem;
  @override
  void initState() {
    setState(() {
      selectedItem = widget.value;
    });
    super.initState();
  }

  void show() {
    if (widget.enabled) {
      if (widget.fromCamera) {
        Alert(
          context: context,
          title: "Ambil file dari?",
          buttons: [
            DialogButton(
              child: Text(
                'Camera',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontFamily: 'GrenadineMVB',
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                pickCamera();
              },
              width: 120,
            ),
            DialogButton(
              child: Text(
                'Browse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontFamily: 'GrenadineMVB',
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                pickFiles();
              },
              width: 120,
            ),
          ],
        ).show();
      } else {
        pickFiles();
      }
    } else {
      Constants.launchUrl(widget.link);
    }
  }

  void pickFiles() async {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    ).then((value) {
      widget.onChanged!(value);
    });
  }

  void pickCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
    );

    if (photo != null) {
      int size = await photo.length();
      PlatformFile file =
          PlatformFile(name: photo.name, size: size, path: photo.path);
      FilePickerResult value = FilePickerResult([file]);
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<FilePickerResult>(
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
            decoration: Constants.inputDecorationV2(
              widget.label,
              constraints: BoxConstraints(minHeight: 40.sp, maxHeight: 50.sp),
              suffixIcon: widget.enabled
                  ? const Icon(
                      Icons.file_upload,
                      size: 20,
                      color: Colors.black,
                    )
                  : null,
              errorText: widget.errorText,
              enabled: widget.enabled,
            ),
            child: widget.link != ''
                ? Text(
                    'Lihat dokumen',
                    style: TextStyle(
                      fontFamily: 'GrenadineMVB',
                      fontWeight: FontWeight.w400,
                      fontSize: 11.sp,
                      color: const Color(0xff3174c7),
                    ),
                  )
                : Text(
                    widget.value == null
                        ? widget.link
                        : widget.value!.files[0].name,
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
