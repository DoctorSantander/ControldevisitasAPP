import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ficha_clinica_model.dart';
import '../services/ocr_service.dart';
import '../services/ai_extraction_service.dart';
import '../services/csv_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OcrService _ocrService = OcrService();
  final AiExtractionService _aiService = AiExtractionService();
  final CsvService _csvService = CsvService();
  
  List<FichaClinica> _fichas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final fichas = await _csvService.leerFichas();
    setState(() {
      _fichas = fichas;
      _isLoading = false;
    });
  }

  // Procesar imagen desde Cámara o Galería (Soporta lotes)
  Future<void> _procesarImagenes(List<XFile> imagenes) async {
    if (imagenes.isEmpty) return;

    setState(() => _isLoading = true);

    for (var img in imagenes) {
      File archivo = File(img.path);
      String fechaToma = _ocrService.obtenerFechaToma(archivo);
      
      // Ejecutar OCR local
      String textoOCR = await _ocrService.procesarImagen(archivo);

      // Extraer campos estructurados
      FichaClinica nuevaFicha = _aiService.extraerDatos(textoOCR, fechaToma);

      // Guardar en CSV
      await _csvService.agregarFicha(nuevaFicha);
    }

    await _cargarDatos();
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Procesamiento por lotes finalizado con éxito')),
    );
  }

  // Capturar con cámara
  Future<void> _escanearConCamara() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.camera);
    if (imagen != null) {
      await _procesarImagenes([imagen]);
    }
  }

  // Seleccionar lote de galería
  Future<void> _cargarLoteGaleria() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> imagenes = await picker.pickMultiImage();
    if (imagenes.isNotEmpty) {
      await _procesarImagenes(imagenes);
    }
  }

  // Eliminar registro
  Future<void> _eliminarRegistro(int index) async {
    await _csvService.borrarFicha(index);
    await _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Fichas Clínicas Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _csvService.exportarCSV(),
            tooltip: 'Exportar CSV',
          ),
        ],
      ),
      body: _isLoading
          .
          ? const Center(child: CircularProgressIndicator())
          : _fichas.isEmpty
              ? const Center(
                  child: Text(
                    'No hay fichas registradas.\nUsa la cámara o galería para escanear.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _fichas.length,
                  itemBuilder: (context, index) {
                    final ficha = _fichas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text('${ficha.nombre} - RUT: ${ficha.rut}'),
                        subtitle: Text(
                          'Fecha: ${ficha.fechaAtencion} | Servicio: ${ficha.servicio}\nDialisis: ${ficha.seDialisa} | Catéter: ${ficha.tieneCateter}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarRegistro(index),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btnCamara',
            onPressed: _escanearConCamara,
            label: const Text('Escanear'),
            icon: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'btnGaleria',
            onPressed: _cargarLoteGaleria,
            label: const Text('Lote Galería'),
            icon: const Icon(Icons.photo_library),
            backgroundColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
