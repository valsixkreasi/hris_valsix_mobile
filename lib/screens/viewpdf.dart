import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hris/components/button.dart';
import 'package:hris/components/flutter_screenutil/flutter_screenutil.dart';
import 'package:hris/components/navheader.dart';
import 'package:hris/configs/constants.dart';

class ViewPDF extends StatefulWidget {
  final Object? arguments;

  const ViewPDF({
    this.arguments,
    super.key,
  });

  @override
  State<ViewPDF> createState() => _ViewPDFState();
}

class _ViewPDFState extends State<ViewPDF> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool _isLoading = true;
  late PDFDocument document;

  Map<String, dynamic> argum = {};

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    var arg = widget.arguments as Map<String, dynamic>?;
    if (arg != null) {
      setState(() {
        argum = arg;
      });
      loadDocument();
    }

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      int progress = data[2];

      if (status == DownloadTaskStatus.complete) {
        print('Download selesai.');
      } else if (status == DownloadTaskStatus.failed) {
        print('Download gagal.');
      }

      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);

    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  void download(String url, String fileName) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      final baseStorage1 =
          await getExternalStorageDirectories(type: StorageDirectory.downloads);
      final Directory? downloadsDir = await getDownloadsDirectory();
      print('baseStorage => ${baseStorage}');
      print('baseStorage1 => ${baseStorage1}');
      print('downloadsDir => ${downloadsDir}');

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        fileName: fileName,
        headers: {}, // optional: header send with url (auth token etc)
        // savedDir: baseStorage!.path,
        savedDir: downloadsDir!.path,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    }
  }

  void downloadFile(String url, String name) async {
    final File? file = await FileDownloader.downloadFile(
        url: url,
        name: name,
        notificationType: NotificationType.all,
        onProgress: (String? fileName, double progress) {
          print('FILE fileName HAS PROGRESS $progress');
        },
        onDownloadCompleted: (String path) {
          print('FILE DOWNLOADED TO PATH: $path');
        },
        onDownloadError: (String error) {
          print('DOWNLOAD ERROR: $error');
        });

    print('FILE: ${file?.path}');
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(
      argum['url'],

      /* cacheManager: CacheManager(
        Config(
          "customCacheKey",
          stalePeriod: const Duration(days: 2),
          maxNrOfCacheObjects: 10,
        ),
      ), */
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: () async {
        loadDocument();
      },
      child: NavHeader(
          showBottomNavigationBar: false,
          showDrawer: true,
          scaffoldKey: scaffoldKey,
          title: Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xff888888),
                  ),
                ),
                Expanded(
                  child: Text(
                    argum['title'] ?? 'DOKUMEN',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GrenadineMVB',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // download(argum['url'], '${argum['title']}.pdf');
                    // download(
                    //     'https://tinypng.com/images/social/developer-api.jpg',
                    //     'PANDA.jpg');

                    downloadFile(argum['url'], '${argum['title']}.pdf');
                    // downloadFile(
                    //     'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
                    //     'sample.pdf');
                  },
                  icon: Icon(
                    Icons.download_rounded,
                    color: Constants.primaryBlue,
                  ),
                ),
                // SizedBox(width: 40.sp),
              ],
            ),
          ),
          children: [
            Stack(children: [
              Container(
                width: 1.sw,
                height: 1.sh - ScreenUtil().statusBarHeight - 40.sp,
                padding:
                    EdgeInsets.symmetric(vertical: 10.sp, horizontal: 15.sp),
                margin: EdgeInsets.only(top: 40.sp),
                // color: Color(0xff888888),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : PDFViewer(
                        document: document,
                        backgroundColor: Colors.transparent,
                        // zoomSteps: 1,
                        //uncomment below line to preload all pages
                        lazyLoad: false,
                        // uncomment below line to scroll vertically
                        scrollDirection: Axis.vertical,
                        //uncomment below code to replace bottom navigation with your own
                        /*
                        navigationBuilder: (context, page, totalPages,
                            jumpToPage, animateToPage) {
                          return ButtonBar(
                            alignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.first_page),
                                onPressed: () {
                                  jumpToPage()(page: 0);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  animateToPage(page: page - 2);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () {
                                  animateToPage(page: page);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.last_page),
                                onPressed: () {
                                  jumpToPage(page: totalPages - 1);
                                },
                              ),
                            ],
                          );
                        },
                        */
                      ),
              ),
            ]),
          ]),
    );
  }
}
