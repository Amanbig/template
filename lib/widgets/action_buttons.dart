import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  var cropAndSaveAudio;
  ActionButtons({super.key,required this.cropAndSaveAudio});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 14,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            fixedSize: MaterialStateProperty.all(Size(250, 45)),
            maximumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 3, 45)),
            side: MaterialStateProperty.all(
              BorderSide(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, color: Colors.grey[800]),
              SizedBox(
                width: 4,
              ),
              Text('Back',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Times New Roman',
                  )),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => cropAndSaveAudio(),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
            fixedSize: MaterialStateProperty.all(Size(250, 45)),
            maximumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 3, 45)),
          ),
          child: Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
  }