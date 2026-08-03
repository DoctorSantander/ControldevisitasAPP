import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> procesarImagen(File imagenFile) async {
    try {
      final inputImage = InputImage.fromFile(imagenFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      print("Error en OCR: $e");
      return "";
    }
  }

  // Obtiene la fecha de la foto basada en la última modificación del archivo (metadata local)
  String obtenerFechaToma(File imagenFile) {
    try {
      final DateTime fechaMod = imagenFile.lastModifiedSync();
      return "${fechaMod.year}-${fechaMod.month.toString().padLeft(2, '0')}-${fechaMod.day.toString().padLeft(2, '0')}";
    } catch (e) {
      final DateTime ahora = DateTime.now();
      return "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}";
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
