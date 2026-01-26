import 'package:flutter/material.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/configs/constants.dart';

class ImageUrl extends StatelessWidget {
  final double width;
  final double height;
  final String url;

  const ImageUrl({
    super.key,
    this.width = 100,
    this.height = 100,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      // Menangani proses loading
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child; // Gambar selesai dimuat
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      // Menangani error (link mati atau tidak ada internet)
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.red, size: width / 2),
            ],
          ),
        );
      },
    );
  }
}
