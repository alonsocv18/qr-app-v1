// Modelos para el sistema de trazabilidad de mangos

class Lote {
  final String id;
  final String productor;
  final String ubicacion;
  final String variedad;
  final DateTime fechaCosecha;
  final Map<String, dynamic> condicionesClimaticas;
  final String? coordenadasGPS;
  final String estado; // 'cosechado', 'postcosecha', 'empacado', 'paletizado', 'almacenado', 'transportado', 'distribuido'
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  Lote({
    required this.id,
    required this.productor,
    required this.ubicacion,
    required this.variedad,
    required this.fechaCosecha,
    required this.condicionesClimaticas,
    this.coordenadasGPS,
    required this.estado,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  // Constructor factory para crear un lote nuevo (sin ID)
  factory Lote.nuevo({
    required String productor,
    required String ubicacion,
    required String variedad,
    required DateTime fechaCosecha,
    required Map<String, dynamic> condicionesClimaticas,
    String? coordenadasGPS,
    String estado = 'cosechado',
  }) {
    return Lote(
      id: '', // Se asignará cuando se guarde en Firestore
      productor: productor,
      ubicacion: ubicacion,
      variedad: variedad,
      fechaCosecha: fechaCosecha,
      condicionesClimaticas: condicionesClimaticas,
      coordenadasGPS: coordenadasGPS,
      estado: estado,
      fechaCreacion: DateTime.now(),
    );
  }

  Lote copyWith({
    String? id,
    String? productor,
    String? ubicacion,
    String? variedad,
    DateTime? fechaCosecha,
    Map<String, dynamic>? condicionesClimaticas,
    String? coordenadasGPS,
    String? estado,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Lote(
      id: id ?? this.id,
      productor: productor ?? this.productor,
      ubicacion: ubicacion ?? this.ubicacion,
      variedad: variedad ?? this.variedad,
      fechaCosecha: fechaCosecha ?? this.fechaCosecha,
      condicionesClimaticas: condicionesClimaticas ?? this.condicionesClimaticas,
      coordenadasGPS: coordenadasGPS ?? this.coordenadasGPS,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      id: map['id'] ?? '',
      productor: map['productor'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      variedad: map['variedad'] ?? '',
      fechaCosecha: DateTime.parse(map['fechaCosecha']),
      condicionesClimaticas: Map<String, dynamic>.from(map['condicionesClimaticas'] ?? {}),
      coordenadasGPS: map['coordenadasGPS'],
      estado: map['estado'] ?? 'cosechado',
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      fechaActualizacion: map['fechaActualizacion'] != null 
          ? DateTime.parse(map['fechaActualizacion']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productor': productor,
      'ubicacion': ubicacion,
      'variedad': variedad,
      'fechaCosecha': fechaCosecha.toIso8601String(),
      'condicionesClimaticas': condicionesClimaticas,
      'coordenadasGPS': coordenadasGPS,
      'estado': estado,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }
}

class Postcosecha {
  final String id;
  final String loteId; // Referencia al lote
  final String tipoTratamiento;
  final String temperatura;
  final String duracion;
  final String gradoMadurez;
  final String? observaciones;
  final DateTime fechaTratamiento;
  final DateTime fechaCreacion;

  Postcosecha({
    required this.id,
    required this.loteId,
    required this.tipoTratamiento,
    required this.temperatura,
    required this.duracion,
    required this.gradoMadurez,
    this.observaciones,
    required this.fechaTratamiento,
    required this.fechaCreacion,
  });

  // Constructor factory para crear postcosecha nueva
  factory Postcosecha.nuevo({
    required String loteId,
    required String tipoTratamiento,
    required String temperatura,
    required String duracion,
    required String gradoMadurez,
    String? observaciones,
    DateTime? fechaTratamiento,
  }) {
    return Postcosecha(
      id: '',
      loteId: loteId,
      tipoTratamiento: tipoTratamiento,
      temperatura: temperatura,
      duracion: duracion,
      gradoMadurez: gradoMadurez,
      observaciones: observaciones,
      fechaTratamiento: fechaTratamiento ?? DateTime.now(),
      fechaCreacion: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loteId': loteId,
      'tipoTratamiento': tipoTratamiento,
      'temperatura': temperatura,
      'duracion': duracion,
      'gradoMadurez': gradoMadurez,
      'observaciones': observaciones,
      'fechaTratamiento': fechaTratamiento.toIso8601String(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Postcosecha.fromMap(Map<String, dynamic> map) {
    return Postcosecha(
      id: map['id'] ?? '',
      loteId: map['loteId'] ?? '',
      tipoTratamiento: map['tipoTratamiento'] ?? '',
      temperatura: map['temperatura'] ?? '',
      duracion: map['duracion'] ?? '',
      gradoMadurez: map['gradoMadurez'] ?? '',
      observaciones: map['observaciones'],
      fechaTratamiento: DateTime.parse(map['fechaTratamiento']),
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }
}

class Empacado {
  final String id;
  final String loteId; // Referencia al lote
  final String cantidadCajas;
  final String pesoPorCaja;
  final String tipoCaja;
  final String cantidadPallets;
  final String tipoPallet;
  final String? observaciones;
  final DateTime fechaEmpaque;
  final DateTime fechaCreacion;

  Empacado({
    required this.id,
    required this.loteId,
    required this.cantidadCajas,
    required this.pesoPorCaja,
    required this.tipoCaja,
    required this.cantidadPallets,
    required this.tipoPallet,
    this.observaciones,
    required this.fechaEmpaque,
    required this.fechaCreacion,
  });

  // Constructor factory para crear empacado nuevo
  factory Empacado.nuevo({
    required String loteId,
    required String cantidadCajas,
    required String pesoPorCaja,
    required String tipoCaja,
    required String cantidadPallets,
    required String tipoPallet,
    String? observaciones,
    DateTime? fechaEmpaque,
  }) {
    return Empacado(
      id: '',
      loteId: loteId,
      cantidadCajas: cantidadCajas,
      pesoPorCaja: pesoPorCaja,
      tipoCaja: tipoCaja,
      cantidadPallets: cantidadPallets,
      tipoPallet: tipoPallet,
      observaciones: observaciones,
      fechaEmpaque: fechaEmpaque ?? DateTime.now(),
      fechaCreacion: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loteId': loteId,
      'cantidadCajas': cantidadCajas,
      'pesoPorCaja': pesoPorCaja,
      'tipoCaja': tipoCaja,
      'cantidadPallets': cantidadPallets,
      'tipoPallet': tipoPallet,
      'observaciones': observaciones,
      'fechaEmpaque': fechaEmpaque.toIso8601String(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Empacado.fromMap(Map<String, dynamic> map) {
    return Empacado(
      id: map['id'] ?? '',
      loteId: map['loteId'] ?? '',
      cantidadCajas: map['cantidadCajas'] ?? '',
      pesoPorCaja: map['pesoPorCaja'] ?? '',
      tipoCaja: map['tipoCaja'] ?? '',
      cantidadPallets: map['cantidadPallets'] ?? '',
      tipoPallet: map['tipoPallet'] ?? '',
      observaciones: map['observaciones'],
      fechaEmpaque: DateTime.parse(map['fechaEmpaque']),
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }
}

// Modelo para Distribución
class Distribucion {
  final String id;
  final String loteId; // Referencia al lote
  final String destino;
  final String transportista;
  final String placaVehiculo;
  final String tipoTransporte; // 'refrigerado', 'normal', 'especial'
  final DateTime fechaSalida;
  final DateTime? fechaLlegada;
  final String? observaciones;
  final String estado; // 'en_transito', 'entregado', 'retrasado'
  final DateTime fechaCreacion;

  Distribucion({
    required this.id,
    required this.loteId,
    required this.destino,
    required this.transportista,
    required this.placaVehiculo,
    required this.tipoTransporte,
    required this.fechaSalida,
    this.fechaLlegada,
    this.observaciones,
    required this.estado,
    required this.fechaCreacion,
  });

  // Constructor factory para crear distribución nueva
  factory Distribucion.nuevo({
    required String loteId,
    required String destino,
    required String transportista,
    required String placaVehiculo,
    required String tipoTransporte,
    DateTime? fechaSalida,
    String? observaciones,
  }) {
    return Distribucion(
      id: '',
      loteId: loteId,
      destino: destino,
      transportista: transportista,
      placaVehiculo: placaVehiculo,
      tipoTransporte: tipoTransporte,
      fechaSalida: fechaSalida ?? DateTime.now(),
      estado: 'en_transito',
      fechaCreacion: DateTime.now(),
      observaciones: observaciones,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loteId': loteId,
      'destino': destino,
      'transportista': transportista,
      'placaVehiculo': placaVehiculo,
      'tipoTransporte': tipoTransporte,
      'fechaSalida': fechaSalida.toIso8601String(),
      'fechaLlegada': fechaLlegada?.toIso8601String(),
      'observaciones': observaciones,
      'estado': estado,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Distribucion.fromMap(Map<String, dynamic> map) {
    return Distribucion(
      id: map['id'] ?? '',
      loteId: map['loteId'] ?? '',
      destino: map['destino'] ?? '',
      transportista: map['transportista'] ?? '',
      placaVehiculo: map['placaVehiculo'] ?? '',
      tipoTransporte: map['tipoTransporte'] ?? '',
      fechaSalida: DateTime.parse(map['fechaSalida']),
      fechaLlegada: map['fechaLlegada'] != null 
          ? DateTime.parse(map['fechaLlegada']) 
          : null,
      observaciones: map['observaciones'],
      estado: map['estado'] ?? 'en_transito',
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }

  // Marcar como entregado
  Distribucion marcarEntregado() {
    return Distribucion(
      id: id,
      loteId: loteId,
      destino: destino,
      transportista: transportista,
      placaVehiculo: placaVehiculo,
      tipoTransporte: tipoTransporte,
      fechaSalida: fechaSalida,
      fechaLlegada: DateTime.now(),
      observaciones: observaciones,
      estado: 'entregado',
      fechaCreacion: fechaCreacion,
    );
  }
}

// Modelo para la recepción en el punto de venta
class RecepcionPuntoVenta {
  final String lugar;
  final DateTime fechaRecepcion;
  final String recibidoPor;

  RecepcionPuntoVenta({
    required this.lugar,
    required this.fechaRecepcion,
    required this.recibidoPor,
  });

  factory RecepcionPuntoVenta.fromMap(Map<String, dynamic> map) {
    return RecepcionPuntoVenta(
      lugar: map['lugar'] ?? '',
      fechaRecepcion: DateTime.parse(map['fechaRecepcion']),
      recibidoPor: map['recibidoPor'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lugar': lugar,
      'fechaRecepcion': fechaRecepcion.toIso8601String(),
      'recibidoPor': recibidoPor,
    };
  }
}

// Modelo completo de trazabilidad que contiene toda la información
class TrazabilidadCompleta {
  final Lote lote;
  final Postcosecha? postcosecha;
  final Empacado? empacado;
  final Distribucion? distribucion;
  final RecepcionPuntoVenta? recepcionPuntoVenta;
  final DateTime fechaCreacion;

  TrazabilidadCompleta({
    required this.lote,
    this.postcosecha,
    this.empacado,
    this.distribucion,
    this.recepcionPuntoVenta,
    required this.fechaCreacion,
  });

  // Verificar si la trazabilidad está completa
  bool get isCompleta => postcosecha != null && empacado != null && distribucion != null;
  
  // Obtener el estado actual del lote
  String get estadoActual {
    if (distribucion != null) {
      if (distribucion!.estado == 'entregado') return 'entregado';
      return 'en_distribucion';
    }
    if (empacado != null) return 'empacado';
    if (postcosecha != null) return 'postcosecha';
    return 'cosechado';
  }

  // Generar datos para QR que contengan toda la trazabilidad
  Map<String, dynamic> toQRData() {
    return {
      'tipo': 'trazabilidad_completa',
      'loteId': lote.id,
      'estado': estadoActual,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'lote': lote.toMap(),
      'postcosecha': postcosecha?.toMap(),
      'empacado': empacado?.toMap(),
      'distribucion': distribucion?.toMap(),
      'recepcionPuntoVenta': recepcionPuntoVenta?.toMap(),
    };
  }

  factory TrazabilidadCompleta.fromMap(Map<String, dynamic> map) {
    return TrazabilidadCompleta(
      lote: Lote.fromMap(map['lote']),
      postcosecha: map['postcosecha'] != null 
          ? Postcosecha.fromMap(map['postcosecha']) 
          : null,
      empacado: map['empacado'] != null 
          ? Empacado.fromMap(map['empacado']) 
          : null,
      distribucion: map['distribucion'] != null 
          ? Distribucion.fromMap(map['distribucion']) 
          : null,
      recepcionPuntoVenta: map['recepcionPuntoVenta'] != null
          ? RecepcionPuntoVenta.fromMap(map['recepcionPuntoVenta'])
          : null,
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }
}

class Caja {
  final String id;
  final String loteId;
  final double peso;
  final int calibre;
  final int cantidadMangos;
  final DateTime fechaEmpaque;
  final String? observaciones;
  final String estado; // 'empacada', 'paletizada', 'almacenada', 'transportada', 'distribuida'
  final DateTime fechaCreacion;

  Caja({
    required this.id,
    required this.loteId,
    required this.peso,
    required this.calibre,
    required this.cantidadMangos,
    required this.fechaEmpaque,
    this.observaciones,
    required this.estado,
    required this.fechaCreacion,
  });

  factory Caja.fromMap(Map<String, dynamic> map) {
    return Caja(
      id: map['id'] ?? '',
      loteId: map['loteId'] ?? '',
      peso: (map['peso'] ?? 0.0).toDouble(),
      calibre: map['calibre'] ?? 0,
      cantidadMangos: map['cantidadMangos'] ?? 0,
      fechaEmpaque: DateTime.parse(map['fechaEmpaque']),
      observaciones: map['observaciones'],
      estado: map['estado'] ?? 'empacada',
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loteId': loteId,
      'peso': peso,
      'calibre': calibre,
      'cantidadMangos': cantidadMangos,
      'fechaEmpaque': fechaEmpaque.toIso8601String(),
      'observaciones': observaciones,
      'estado': estado,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }
}

class Pallet {
  final String id;
  final List<String> cajasIds;
  final int numeroCajas;
  final double pesoTotal;
  final String destino;
  final DateTime fechaCreacion;
  final String estado; // 'creado', 'almacenado', 'transportado', 'distribuido'

  Pallet({
    required this.id,
    required this.cajasIds,
    required this.numeroCajas,
    required this.pesoTotal,
    required this.destino,
    required this.fechaCreacion,
    required this.estado,
  });

  factory Pallet.fromMap(Map<String, dynamic> map) {
    return Pallet(
      id: map['id'] ?? '',
      cajasIds: List<String>.from(map['cajasIds'] ?? []),
      numeroCajas: map['numeroCajas'] ?? 0,
      pesoTotal: (map['pesoTotal'] ?? 0.0).toDouble(),
      destino: map['destino'] ?? '',
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      estado: map['estado'] ?? 'creado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cajasIds': cajasIds,
      'numeroCajas': numeroCajas,
      'pesoTotal': pesoTotal,
      'destino': destino,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'estado': estado,
    };
  }
}

class TrazabilidadInfo {
  final Lote lote;
  final List<Caja> cajas;
  final List<Pallet> pallets;
  final Map<String, dynamic>? postcosecha;
  final Map<String, dynamic>? almacenamiento;
  final Map<String, dynamic>? transporte;
  final Map<String, dynamic>? distribucion;

  TrazabilidadInfo({
    required this.lote,
    required this.cajas,
    required this.pallets,
    this.postcosecha,
    this.almacenamiento,
    this.transporte,
    this.distribucion,
  });

  factory TrazabilidadInfo.fromMap(Map<String, dynamic> map) {
    return TrazabilidadInfo(
      lote: Lote.fromMap(map['lote'] ?? {}),
      cajas: (map['cajas'] as List? ?? [])
          .map((caja) => Caja.fromMap(caja))
          .toList(),
      pallets: (map['pallets'] as List? ?? [])
          .map((pallet) => Pallet.fromMap(pallet))
          .toList(),
      postcosecha: map['postcosecha'],
      almacenamiento: map['almacenamiento'],
      transporte: map['transporte'],
      distribucion: map['distribucion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lote': lote.toMap(),
      'cajas': cajas.map((caja) => caja.toMap()).toList(),
      'pallets': pallets.map((pallet) => pallet.toMap()).toList(),
      'postcosecha': postcosecha,
      'almacenamiento': almacenamiento,
      'transporte': transporte,
      'distribucion': distribucion,
    };
  }
} 