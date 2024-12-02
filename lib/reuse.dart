import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget myText(BuildContext context, String label,
    TextEditingController controller, bool isObscured) {
  return TextFormField(
    controller: controller,
    obscureText: isObscured,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    ),
  );
}

Widget myText1(
  BuildContext context,
  String label, {
  required TextEditingController controller,
  TextInputType? keyboardType,
  int? maxLength,
  List<TextInputFormatter>? inputFormatters,
  Function(String)? onChanged,
  VoidCallback? onEditingComplete,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        counterText: '',
      ),
    ),
  );
}

ElevatedButton myButton(
    BuildContext context, VoidCallback onTap, String label) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF008080),
        minimumSize: const Size(200, 60),
        textStyle: const TextStyle(fontSize: 18),
        elevation: 5,
        shadowColor: Colors.blueGrey.withOpacity(0.5),
      ),
      onPressed: onTap,
      child: Text(label));
}

ElevatedButton myButton1(
    BuildContext context, VoidCallback onTap, String label) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        minimumSize: const Size(200, 60),
        textStyle: const TextStyle(fontSize: 18),
        elevation: 5,
        shadowColor: Colors.blueGrey.withOpacity(0.5),
      ),
      onPressed: onTap,
      child: Text(label));
}

ElevatedButton myButton2(
    BuildContext context, VoidCallback onTap, String label) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF008080),
      minimumSize: const Size(200, 60),
      textStyle: const TextStyle(fontSize: 18),
    ),
    onPressed: onTap,
    child: Text(label),
  );
}

ElevatedButton myButton3(
    BuildContext context, VoidCallback onTap, String label) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      minimumSize: const Size(200, 60),
      textStyle: const TextStyle(fontSize: 18),
    ),
    onPressed: onTap,
    child: Text(label),
  );
}

SizedBox myBox(double height, double width) {
  return SizedBox(
    height: height,
    width: width,
  );
}

ElevatedButton myImageButton(
    BuildContext context, VoidCallback? onTap, String label) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      disabledBackgroundColor: Colors.grey.shade300,
      disabledForegroundColor: Colors.grey.shade600,
    ),
    onPressed: onTap,
    child: Text(label),
  );
}

TextButton myButext(BuildContext context, VoidCallback onTap, String label) {
  return TextButton(
      style: TextButton.styleFrom(foregroundColor: Colors.black),
      onPressed: onTap,
      child: Text(label));
}

Widget myBoatTypeDropdown(BuildContext context, String label,
    {String? value, Function(String?)? onChanged}) {
  return DropdownButtonFormField<String>(
    value: value,
    items: ['Sailboat', 'Motorboat', 'Traditional Boat']
        .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
        .toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    ),
  );
}

Widget myDateDropdowns(
  BuildContext context,
  String label, {
  int? selectedYear,
  int? selectedMonth,
  int? selectedDate,
  Function(int?)? onYearChanged,
  Function(int?)? onMonthChanged,
  Function(int?)? onDateChanged,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Year Dropdown
      Expanded(
        child: DropdownButtonFormField<int>(
          value: selectedYear,
          items: List.generate(30, (index) => 2023 - index)
              .map((year) => DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  ))
              .toList(),
          onChanged: onYearChanged,
          decoration: InputDecoration(
            labelText: 'Year',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          ),
        ),
      ),
      const SizedBox(width: 10),
      // Month Dropdown
      Expanded(
        child: DropdownButtonFormField<int>(
          value: selectedMonth,
          items: List.generate(12, (index) => index + 1)
              .map((month) => DropdownMenuItem(
                    value: month,
                    child: Text(month.toString()),
                  ))
              .toList(),
          onChanged: onMonthChanged,
          decoration: InputDecoration(
            labelText: 'Month',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          ),
        ),
      ),
      const SizedBox(width: 10),
      // Date Dropdown
      Expanded(
        child: DropdownButtonFormField<int>(
          value: selectedDate,
          items: List.generate(31, (index) => index + 1)
              .map((date) => DropdownMenuItem(
                    value: date,
                    child: Text(date.toString()),
                  ))
              .toList(),
          onChanged: onDateChanged,
          decoration: InputDecoration(
            labelText: 'Date',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          ),
        ),
      ),
    ],
  );
}

Widget uploadButton({
  required VoidCallback onPressed,
  required String label,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.camera_alt),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      minimumSize: const Size(200, 50),
      textStyle: const TextStyle(fontSize: 16),
      side: const BorderSide(color: Colors.grey),
      elevation: 2,
    ),
  );
}
