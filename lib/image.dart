import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<String?> pickImageAndConvertToBase64() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final bytes = File(pickedFile.path).readAsBytesSync();
    return base64Encode(bytes);
  }
  return null;
}

Future<String> convertImageToBase64(File imageFile) async {
  try {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  } catch (e) {
    print('Error converting image to base64: $e');
    throw e;
  }
}