import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/ficha_clinica_model.dart';

class CsvService {
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/fichas_clinicas.csv');
  }

  // Leer todas las fichas guardadas
  Future<List<FichaClinica>> leerFichas() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      List<List<dynamic>> rows = const CsvToListConverter().convert(contents);

      // Omitir cabecera si existe
      if (rows.isEmpty) return [];
      int startIndex = rows[0][0].toString().contains('Fecha') ? 1 : 0;

      List<FichaClinica> fichas = [];
      for (int i = startIndex; i < rows.length; i++) {
        fichas.add(FichaClinica.fromList(rows[i]));
      }
      return fichas;
    } catch (e) {
      print("Error leyendo CSV: $e");
      return [];
    }
  }

  // Guardar nuevas fichas o actualizar el archivo completo
  Future<void> guardarFichas(List<FichaClinica> fichas) async {
    final file = await _getLocalFile();

    List<List<dynamic>> rows = [
      [
        'fecha_atencion',
        'nombre',
        'rut',
        'fecha_nacimiento',
        'edad',
        'sexo',
        'servicio',
        'diagnosticos',
        'se_dialisa',
        'tiene_cateter'
      ]
    ];

    for (var ficha in fichas) {
      rows.add(ficha.toList());
    }

    String csvData = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csvData);
  }

  // Agregar una nueva ficha
  Future<void> agregarFicha(FichaClinica nuevaFicha) async {
    List<FichaClinica> fichas = await leerFichas();
    fichas.add(nuevaFicha);
    await guardarFichas(fichas);
  }

  // Borrar una ficha por índice
  Future<void> borrarFicha(int index) async {
    List<FichaClinica> fichas = await leerFichas();
    if (index >= 0 && index < fichas.length) {
      fichas.removeAt(index);
      await guardarFichas(fichas);
    }
  }

  // Exportar / Compartir el archivo CSV
  Future<void> exportarCSV() async {
    final file = await _getLocalFile();
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'Exportación de Fichas Clínicas en CSV');
    }
  }
}
