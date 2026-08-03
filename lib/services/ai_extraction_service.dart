import '../models/ficha_clinica_model.dart';

class AiExtractionService {
  FichaClinica extraerDatos(String textoOCR, String fechaToma) {
    // Expresiones regulares para buscar patrones comunes en fichas clínicas
    final rutRegex = RegExp(r'\b\d{1,2}\.\d{3}\.\d{3}-[0-9kK]\b');
    final fechaNacRegex = RegExp(r'(?:Nacimiento|Nac|FN)[:\s]*(\d{2}[-/]\d{2}[-/]\d{4})', caseSensitive: false);
    final sexoRegex = RegExp(r'\b(Femenino|Masculino|F|M)\b', caseSensitive: false);
    final dialisisRegex = RegExp(r'(dialisis|dializa)', caseSensitive: false);
    final cateterRegex = RegExp(r'cateter|catéter', caseSensitive: false);

    // Extracción de campos usando las regex
    String rut = rutRegex.firstMatch(textoOCR)?.group(0) ?? 'No especificado';
    String fechaNac = fechaNacRegex.firstMatch(textoOCR)?.group(1) ?? 'No especificada';
    
    // Extracción inteligente básica de sexo
    String sexo = 'No especificado';
    final matchSexo = sexoRegex.firstMatch(textoOCR);
    if (matchSexo != null) {
      String s = matchSexo.group(0)!.toUpperCase();
      sexo = (s.startsWith('F')) ? 'Femenino' : 'Masculino';
    }

    // Indicadores booleanos basados en palabras clave dentro del texto
    String seDialisa = dialisisRegex.hasMatch(textoOCR) ? 'Sí' : 'No';
    String tieneCateter = cateterRegex.hasMatch(textoOCR) ? 'Sí' : 'No';

    // Estimación genérica si no se detecta el nombre de forma estructurada
    String nombre = "Paciente Extraído Automáticamente";
    String servicio = "General";
    String diagnosticos = "Revisar texto de origen";
    String edad = "No calculada";

    return FichaClinica(
      fechaAtencion: fechaToma,
      nombre: nombre,
      rut: rut,
      fechaNacimiento: fechaNac,
      edad: edad,
      sexo: sexo,
      servicio: servicio,
      diagnosticos: diagnosticos,
      seDialisa: seDialisa,
      tieneCateter: tieneCateter,
    );
  }
}
