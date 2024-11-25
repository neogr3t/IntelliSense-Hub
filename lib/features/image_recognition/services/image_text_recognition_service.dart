import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ImageTextRecognitionService {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      return '';
    }
  }

  void dispose() {
    textRecognizer.close();
  }
}
