import 'package:flutter/material.dart';

class TimeLabels extends StatelessWidget {
  String start = '00:00'; 
  String end = '00:00';
  TimeLabels({super.key,required this.start,required this.end});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            start,
            style: const TextStyle(color: Colors.black54),
          ),
          Text(
            end,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}


// _formatTime(start)
// _formatTime(end)