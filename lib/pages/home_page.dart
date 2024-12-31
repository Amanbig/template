import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:template/components/drop_down.dart';
import 'package:template/components/home_page_buttons.dart';
import 'package:template/pages/crop_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  double start = 0;
  double end = 0;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDropdownVisible = false;

  void setAudio(double start, double end) {
    widget.start = start;
    widget.end = end;
  }

  String url = '';


  Future<String> getFilePath() async {
    // Get the app's document directory (platform-specific)
    final directory = await getApplicationDocumentsDirectory();

    // Return the full file path in the app's documents folder
    return directory.path;  // You can append file name if needed
  }

  Future<void> updatePath(String path) async {
    setState(() {
      url = path;
    });
  }

  void updateDropDown(bool dropdown) {
    setState(() {
      _isDropdownVisible = dropdown;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back),
                Text(
                  'Video Music Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Times New Roman',
                  ),
                ),
                SizedBox(
                  width: 22,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 25,
                    children: [
                      Text(
                        'Total Video Duration: 3:45',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Total Music Duration: 3:45',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Selected Music:',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      DropDown(updateDropDown: updateDropDown, isDropdownVisible: _isDropdownVisible, updatePath: updatePath,),
                    ],
                  ),
                ),
                !_isDropdownVisible
                    ? HomePageButtons(
                  setAudio: setAudio,
                  name: 'hello',
                  url: url,
                  // Removed null coalescing
                )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
