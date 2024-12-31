import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:template/pages/crop_page.dart';

class HomePageButtons extends StatelessWidget {
  final Function setAudio;
  final String? name;
  final String? url;

  HomePageButtons({
    super.key,
    required this.setAudio,
    required this.name,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Crop Music Button
        Container(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => AudioCropperPage(
                    name: name!,
                    setAudio: setAudio,
                    url: url!,
                  ),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_note),
                Text(
                  'Crop Music',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Times New Roman',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 44), // Adds space between the buttons

        // Save Video Button
        Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Save Video',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Colors.grey[800]),
                  fixedSize: MaterialStateProperty.all(Size(250, 45)),
                ),
              ),
              SizedBox(height: 14), // Adds space between buttons

              // Save Button
              TextButton(
                onPressed: () {},
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Times New Roman',
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  fixedSize: MaterialStateProperty.all(Size(250, 45)),
                  side: MaterialStateProperty.all(
                    BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
