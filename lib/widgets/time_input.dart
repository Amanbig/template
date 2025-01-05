import 'package:flutter/material.dart';

class TimeInput extends StatelessWidget {
  String label;
  TextEditingController controller;
  bool isStart;
  bool isSmallScreen;
  var updateTimeFromText;
  TimeInput(
      {super.key,
      required this.controller,
      required this.label,
      required this.isStart,
      required this.isSmallScreen,
      required this.updateTimeFromText});

  @override
  Widget build(BuildContext context) {

    final double width =
        isSmallScreen ? 50 : 70;
        
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$label:',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onSubmitted: (_) => updateTimeFromText(isStart),
            ),
          ],
        ),
      ),
    );
  }
}
