import 'package:flutter/material.dart';

class CropPage extends StatefulWidget {
  final String url;
  final String name;

  const CropPage({super.key, required this.url, required this.name});

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  int start = 0;
  int end = 300;
  int duration = 0;

  @override
  void initState() {
    super.initState();
    duration = end - start;
  }

  void updateDuration() {
    setState(() {
      duration = (end > start) ? end - start : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Song Name: ${widget.name}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              // Slider Area
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: start.toDouble(),
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            start = (start + details.delta.dx).toInt();
                            startController.text = start.toString(); 
                            updateDuration();
                          });
                        },
                        child: Container(
                          width: 5,
                          height: 100,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Positioned(
                      left: end.toDouble(),
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            end = (end + details.delta.dx).toInt();
                             endController.text = end.toString(); 
                            updateDuration();
                          });
                        },
                        child: Container(
                          width: 5,
                          height: 100,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Start, End, Duration Inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildInputField(
                    label: 'Start:',
                    controller: startController,
                    onChanged: (text) {
                      setState(() {
                        start = int.tryParse(text) ?? 0;
                        if (start < 0) start = 0;
                        updateDuration();
                      });
                    },
                  ),
                  buildInputField(
                    label: 'End:',
                    controller: endController,
                    onChanged: (text) {
                      setState(() {
                        end = int.tryParse(text) ?? 0;
                        if (end < 0) end = 0;
                        updateDuration();
                      });
                    },
                  ),
                  Column(
                    children: [
                      const Text(
                        'Duration:',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        duration.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
              // Play Button
              GestureDetector(
                onTap: () {
                  // Implement play functionality here
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.play_circle_outline, size: 32),
                    SizedBox(width: 8),
                    Text(
                      'Play',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
                ],
              ),
              const SizedBox(height: 30),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement save functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 50,
          height: 30,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
