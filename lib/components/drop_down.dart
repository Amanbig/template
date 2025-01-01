import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DropDown extends StatefulWidget {
  final bool isDropdownVisible;
  final void Function(bool) updateDropDown;
  final void Function(String) updatePath;

  const DropDown({
    Key? key,
    required this.isDropdownVisible,
    required this.updateDropDown,
    required this.updatePath,
  }) : super(key: key);

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  List<String> musicList = [
    'Upload your own music',
    'Music 1',
    'Music 2',
    'Music 3',
    'Music 4',
    'Music 5',
  ];
  String selectedMusic = 'Music 1';
  bool isDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    isDropdownVisible = widget.isDropdownVisible;
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      String? path = result.files.single.path;
      if (path != null) {
        widget.updatePath(path);
        setState(() {
          selectedMusic = 'New Audio';
          musicList.insert(1, selectedMusic); // Add the new audio dynamically.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownVisible = !isDropdownVisible;
              widget.updateDropDown(isDropdownVisible);
            });
          },
          child: Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(selectedMusic),
          ),
        ),
        Visibility(
          visible: isDropdownVisible,
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(5),
            ),
            child: SizedBox(
              height: 250, // Limit the height of the dropdown
              child: ListView.builder(
                itemCount: musicList.length,
                itemBuilder: (context, index) {
                  final item = musicList[index];
                  return InkWell(
                    onTap: () async {
                      if (index == 0) {
                        await pickFile();
                      } else {
                        setState(() {
                          selectedMusic = item;
                          isDropdownVisible = false;
                          widget.updateDropDown(isDropdownVisible);
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          index == 0
                              ? const Icon(Icons.upload)
                              : const Icon(Icons.play_circle_outlined),
                          const SizedBox(width: 8),
                          Text(
                            item,
                            style: TextStyle(
                              color: index == 0 ? Colors.green : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
