import 'package:flutter/material.dart';

class TimetableEntryWidget extends StatelessWidget {
  final String day;
  final int index;
  final Map<String, String> lecture;
  final Function(String, int, String, String) onUpdate;

  TimetableEntryWidget(
      {required this.day,
      required this.index,
      required this.lecture,
      required this.onUpdate,
      required List<String> facultyList});

  Future<void> pickTime(BuildContext context, String key) async {
    TimeOfDay? selectedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (selectedTime != null) {
      String formattedTime = selectedTime.format(context);
      onUpdate(day, index, key, formattedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextButton(
                onPressed: () => pickTime(context, "start_time"),
                child: Text(lecture["start_time"]!.isEmpty
                    ? "Pick Start Time"
                    : lecture["start_time"]!))),
        Expanded(
            child: TextButton(
                onPressed: () => pickTime(context, "end_time"),
                child: Text(lecture["end_time"]!.isEmpty
                    ? "Pick End Time"
                    : lecture["end_time"]!))),
        Expanded(
            child: TextField(
                onChanged: (val) => onUpdate(day, index, "subject", val),
                decoration: InputDecoration(labelText: "Subject"))),
        Expanded(
            child: TextField(
                onChanged: (val) => onUpdate(day, index, "faculty", val),
                decoration: InputDecoration(labelText: "Faculty"))),
      ],
    );
  }
}
