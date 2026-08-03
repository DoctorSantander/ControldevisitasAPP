class FichaClinica {
  String fechaAtencion;
  String nombre;
  String rut;
  String fechaNacimiento;
  String edad;
  String sexo;
  String servicio;
  String diagnosticos;
  String seDialisa;
  String tieneCateter;

  FichaClinica({
    required this.fechaAtencion,
    required this.nombre,
    required this.rut,
    required this.fechaNacimiento,
    required this.edad,
    required this.sexo,
    required this.servicio,
    required this.diagnosticos,
    required this.seDialisa,
    required this.tieneCateter,
  });

  // Convertir objeto a lista para guardar en CSV
  List<dynamic> toList() => [
        fechaAtencion,
        nombre,
        rut,
        fechaNacimiento,
        edad,
        sexo,
        servicio,
        diagnosticos,
        seDialisa,
        tieneCateter,
      ];

  // Crear objeto desde una lista de CSV
  factory FichaClinica.fromList(List<dynamic> list) {
    return FichaClinica(
      fechaAtencion: list.isNotEmpty ? list[0].toString() : '',
      nombre: list.length > 1 ? list[1].toString() : '',
      rut: list.length > 2 ? list[2].toString() : '',
      fechaNacimiento: list.length > 3 ? list[3].toString() : '',
      edad: list.length > 4 ? list[4].toString() : '',
      sexo: list.length > 5 ? list[5].toString() : '',
      servicio: list.length > 6 ? list[6].toString() : '',
      diagnosticos: list.length > 7 ? list[7].toString() : '',
      seDialisa: list.length > 8 ? list[8].toString() : '',
      tieneCateter: list.length > 9 ? list[9].toString() : '',
    );
  }
}
