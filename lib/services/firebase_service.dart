import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/trazability_models.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Colecciones
  static const String _lotesCollection = 'lotes';
  static const String _postcosechaCollection = 'postcosecha';
  static const String _empacadoCollection = 'empacado';
  static const String _trazabilidadCollection = 'trazabilidad';

  // Autenticación
  static Future<UserCredential?> signInAnonymously() async {
    try {
      // Verificar si ya hay un usuario autenticado
      if (_auth.currentUser != null) {
        return null; // Ya está autenticado
      }
      
      return await _auth.signInAnonymously();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error en autenticación anónima: $e');
      }
      return null;
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Asegurar autenticación antes de operaciones
  static Future<void> ensureAuthenticated() async {
    print('🔐 ensureAuthenticated: Verificando autenticación...');
    final currentUser = getCurrentUser();
    print('🔐 ensureAuthenticated: Usuario actual = ${currentUser?.uid}');
    
    if (currentUser == null) {
      print('🔐 ensureAuthenticated: No hay usuario, iniciando autenticación anónima...');
      await signInAnonymously();
      print('🔐 ensureAuthenticated: Autenticación anónima completada');
    } else {
      print('🔐 ensureAuthenticated: Usuario ya autenticado');
    }
  }

  // CRUD para Lotes
  static Future<String> createLote(Lote lote) async {
    try {
      final docRef = await _firestore.collection(_lotesCollection).add({
        'productor': lote.productor,
        'ubicacion': lote.ubicacion,
        'variedad': lote.variedad,
        'fechaCosecha': lote.fechaCosecha.toIso8601String(),
        'condicionesClimaticas': lote.condicionesClimaticas,
        'coordenadasGPS': lote.coordenadasGPS,
        'estado': lote.estado,
        'fechaCreacion': lote.fechaCreacion.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': getCurrentUser()?.uid,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear lote: $e');
    }
  }

  static Future<List<Lote>> getLotes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_lotesCollection)
          .where('userId', isEqualTo: getCurrentUser()?.uid)
          .get();

      final lotes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Lote(
          id: doc.id,
          productor: data['productor'] ?? '',
          ubicacion: data['ubicacion'] ?? '',
          variedad: data['variedad'] ?? '',
          fechaCosecha: DateTime.parse(data['fechaCosecha']),
          condicionesClimaticas: Map<String, dynamic>.from(data['condicionesClimaticas'] ?? {}),
          coordenadasGPS: data['coordenadasGPS'],
          estado: data['estado'] ?? 'cosechado',
          fechaCreacion: DateTime.parse(data['fechaCreacion']),
        );
      }).toList();

      // Ordenar localmente por fecha de creación (más reciente primero)
      lotes.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      
      return lotes;
    } catch (e) {
      throw Exception('Error al obtener lotes: $e');
    }
  }

  static Future<Lote?> getLoteById(String loteId) async {
    try {
      final doc = await _firestore.collection(_lotesCollection).doc(loteId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Lote(
        id: doc.id,
        productor: data['productor'] ?? '',
        ubicacion: data['ubicacion'] ?? '',
        variedad: data['variedad'] ?? '',
        fechaCosecha: DateTime.parse(data['fechaCosecha']),
        condicionesClimaticas: Map<String, dynamic>.from(data['condicionesClimaticas'] ?? {}),
        coordenadasGPS: data['coordenadasGPS'],
        estado: data['estado'] ?? 'cosechado',
        fechaCreacion: DateTime.parse(data['fechaCreacion']),
      );
    } catch (e) {
      throw Exception('Error al obtener lote: $e');
    }
  }

  // CRUD para Postcosecha
  static Future<String> createPostcosecha(Postcosecha postcosecha) async {
    try {
      // Verificar que el lote existe
      final lote = await getLoteById(postcosecha.loteId);
      if (lote == null) {
        throw Exception('El lote especificado no existe');
      }

      final docRef = await _firestore.collection(_postcosechaCollection).add({
        'loteId': postcosecha.loteId,
        'tipoTratamiento': postcosecha.tipoTratamiento,
        'temperatura': postcosecha.temperatura,
        'duracion': postcosecha.duracion,
        'gradoMadurez': postcosecha.gradoMadurez,
        'observaciones': postcosecha.observaciones,
        'fechaTratamiento': postcosecha.fechaTratamiento.toIso8601String(),
        'fechaCreacion': postcosecha.fechaCreacion.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': getCurrentUser()?.uid,
      });

      // Actualizar estado del lote
      await _firestore.collection(_lotesCollection).doc(postcosecha.loteId).update({
        'estado': 'postcosecha',
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear postcosecha: $e');
    }
  }

  static Future<Postcosecha?> getPostcosechaByLoteId(String loteId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_postcosechaCollection)
          .where('loteId', isEqualTo: loteId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      return Postcosecha(
        id: doc.id,
        loteId: data['loteId'] ?? '',
        tipoTratamiento: data['tipoTratamiento'] ?? '',
        temperatura: data['temperatura'] ?? '',
        duracion: data['duracion'] ?? '',
        gradoMadurez: data['gradoMadurez'] ?? '',
        observaciones: data['observaciones'],
        fechaTratamiento: DateTime.parse(data['fechaTratamiento']),
        fechaCreacion: DateTime.parse(data['fechaCreacion']),
      );
    } catch (e) {
      throw Exception('Error al obtener postcosecha: $e');
    }
  }

  // CRUD para Empacado
  static Future<String> createEmpacado(Empacado empacado) async {
    try {
      // Verificar que el lote existe
      final lote = await getLoteById(empacado.loteId);
      if (lote == null) {
        throw Exception('El lote especificado no existe');
      }

      // Verificar que existe postcosecha
      final postcosecha = await getPostcosechaByLoteId(empacado.loteId);
      if (postcosecha == null) {
        throw Exception('Debe registrar postcosecha antes del empacado');
      }

      final docRef = await _firestore.collection(_empacadoCollection).add({
        'loteId': empacado.loteId,
        'cantidadCajas': empacado.cantidadCajas,
        'pesoPorCaja': empacado.pesoPorCaja,
        'tipoCaja': empacado.tipoCaja,
        'cantidadPallets': empacado.cantidadPallets,
        'tipoPallet': empacado.tipoPallet,
        'observaciones': empacado.observaciones,
        'fechaEmpaque': empacado.fechaEmpaque.toIso8601String(),
        'fechaCreacion': empacado.fechaCreacion.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': getCurrentUser()?.uid,
      });

      // Actualizar estado del lote
      await _firestore.collection(_lotesCollection).doc(empacado.loteId).update({
        'estado': 'empacado',
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear empacado: $e');
    }
  }

  static Future<Empacado?> getEmpacadoByLoteId(String loteId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_empacadoCollection)
          .where('loteId', isEqualTo: loteId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      return Empacado(
        id: doc.id,
        loteId: data['loteId'] ?? '',
        cantidadCajas: data['cantidadCajas'] ?? '',
        pesoPorCaja: data['pesoPorCaja'] ?? '',
        tipoCaja: data['tipoCaja'] ?? '',
        cantidadPallets: data['cantidadPallets'] ?? '',
        tipoPallet: data['tipoPallet'] ?? '',
        observaciones: data['observaciones'],
        fechaEmpaque: DateTime.parse(data['fechaEmpaque']),
        fechaCreacion: DateTime.parse(data['fechaCreacion']),
      );
    } catch (e) {
      throw Exception('Error al obtener empacado: $e');
    }
  }

  // CRUD para Distribución
  static Future<String> createDistribucion(Distribucion distribucion) async {
    try {
      // Verificar que el lote existe
      final lote = await getLoteById(distribucion.loteId);
      if (lote == null) {
        throw Exception('El lote especificado no existe');
      }

      // Verificar que existe empacado
      final empacado = await getEmpacadoByLoteId(distribucion.loteId);
      if (empacado == null) {
        throw Exception('Debe registrar empacado antes de la distribución');
      }

      final docRef = await _firestore.collection('distribucion').add({
        'loteId': distribucion.loteId,
        'destino': distribucion.destino,
        'transportista': distribucion.transportista,
        'placaVehiculo': distribucion.placaVehiculo,
        'tipoTransporte': distribucion.tipoTransporte,
        'fechaSalida': distribucion.fechaSalida.toIso8601String(),
        'fechaLlegada': distribucion.fechaLlegada?.toIso8601String(),
        'observaciones': distribucion.observaciones,
        'estado': distribucion.estado,
        'fechaCreacion': distribucion.fechaCreacion.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': getCurrentUser()?.uid,
      });

      // Actualizar estado del lote
      await _firestore.collection(_lotesCollection).doc(distribucion.loteId).update({
        'estado': 'en_distribucion',
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear distribución: $e');
    }
  }

  static Future<Distribucion?> getDistribucionByLoteId(String loteId) async {
    try {
      final querySnapshot = await _firestore
          .collection('distribucion')
          .where('loteId', isEqualTo: loteId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      return Distribucion(
        id: doc.id,
        loteId: data['loteId'] ?? '',
        destino: data['destino'] ?? '',
        transportista: data['transportista'] ?? '',
        placaVehiculo: data['placaVehiculo'] ?? '',
        tipoTransporte: data['tipoTransporte'] ?? '',
        fechaSalida: DateTime.parse(data['fechaSalida']),
        fechaLlegada: data['fechaLlegada'] != null 
            ? DateTime.parse(data['fechaLlegada']) 
            : null,
        observaciones: data['observaciones'],
        estado: data['estado'] ?? 'en_transito',
        fechaCreacion: DateTime.parse(data['fechaCreacion']),
      );
    } catch (e) {
      throw Exception('Error al obtener distribución: $e');
    }
  }

  static Future<void> marcarDistribucionEntregada(String loteId) async {
    try {
      final distribucion = await getDistribucionByLoteId(loteId);
      if (distribucion == null) {
        throw Exception('No se encontró distribución para este lote');
      }

      final distribucionEntregada = distribucion.marcarEntregado();
      
      await _firestore.collection('distribucion').doc(distribucion.id).update({
        'estado': 'entregado',
        'fechaLlegada': distribucionEntregada.fechaLlegada!.toIso8601String(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      // Actualizar estado del lote
      await _firestore.collection(_lotesCollection).doc(loteId).update({
        'estado': 'entregado',
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al marcar distribución como entregada: $e');
    }
  }

  // Trazabilidad completa
  static Future<TrazabilidadCompleta> getTrazabilidadCompleta(String loteId) async {
    try {
      // Obtener lote
      final lote = await getLoteById(loteId);
      if (lote == null) {
        throw Exception('Lote no encontrado');
      }

      // Obtener postcosecha
      final postcosecha = await getPostcosechaByLoteId(loteId);

      // Obtener empacado
      final empacado = await getEmpacadoByLoteId(loteId);

      // Obtener distribución
      final distribucion = await getDistribucionByLoteId(loteId);

      return TrazabilidadCompleta(
        lote: lote,
        postcosecha: postcosecha,
        empacado: empacado,
        distribucion: distribucion,
        fechaCreacion: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error al obtener trazabilidad: $e');
    }
  }

  static Future<TrazabilidadCompleta?> getTrazabilidadByQR(String qrData) async {
    try {
      // Buscar por ID del lote en el QR
      final querySnapshot = await _firestore
          .collection(_trazabilidadCollection)
          .where('loteId', isEqualTo: qrData)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Si no existe en trazabilidad, intentar obtener por loteId
        return await getTrazabilidadCompleta(qrData);
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      final lote = Lote(
        id: data['loteId'] ?? '',
        productor: data['productor'] ?? '',
        ubicacion: data['ubicacion'] ?? '',
        variedad: data['variedad'] ?? '',
        fechaCosecha: DateTime.parse(data['fechaCosecha']),
        condicionesClimaticas: Map<String, dynamic>.from(data['condicionesClimaticas'] ?? {}),
        coordenadasGPS: data['coordenadasGPS'],
        estado: data['estado'] ?? 'cosechado',
        fechaCreacion: DateTime.parse(data['fechaCreacion']),
      );

      Postcosecha? postcosecha;
      if (data['postcosecha'] != null) {
        final postData = data['postcosecha'];
        postcosecha = Postcosecha(
          id: postData['id'] ?? '',
          loteId: postData['loteId'] ?? '',
          tipoTratamiento: postData['tipoTratamiento'] ?? '',
          temperatura: postData['temperatura'] ?? '',
          duracion: postData['duracion'] ?? '',
          gradoMadurez: postData['gradoMadurez'] ?? '',
          observaciones: postData['observaciones'],
          fechaTratamiento: DateTime.parse(postData['fechaTratamiento']),
          fechaCreacion: DateTime.parse(postData['fechaCreacion']),
        );
      }

      Empacado? empacado;
      if (data['empacado'] != null) {
        final empData = data['empacado'];
        empacado = Empacado(
          id: empData['id'] ?? '',
          loteId: empData['loteId'] ?? '',
          cantidadCajas: empData['cantidadCajas'] ?? '',
          pesoPorCaja: empData['pesoPorCaja'] ?? '',
          tipoCaja: empData['tipoCaja'] ?? '',
          cantidadPallets: empData['cantidadPallets'] ?? '',
          tipoPallet: empData['tipoPallet'] ?? '',
          observaciones: empData['observaciones'],
          fechaEmpaque: DateTime.parse(empData['fechaEmpaque']),
          fechaCreacion: DateTime.parse(empData['fechaCreacion']),
        );
      }

      return TrazabilidadCompleta(
        lote: lote,
        postcosecha: postcosecha,
        empacado: empacado,
        fechaCreacion: DateTime.parse(data['fechaCreacion']),
      );
    } catch (e) {
      throw Exception('Error al obtener trazabilidad: $e');
    }
  }

  // Generar QR con datos completos
  static String generateQRData(String loteId) {
    return loteId; // Por ahora solo el ID del lote
  }

  // Gestión de QR en Firestore
  // Guardar QR en Firestore (solo referencia, sin imagen)
  static Future<String> saveQRCode(String loteId, String qrData) async {
    try {
      // Asegurar autenticación
      await ensureAuthenticated();
      
      final userId = getCurrentUser()?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Guardar solo la referencia del QR en Firestore
      final docRef = await _firestore.collection('qr_codes').add({
        'loteId': loteId,
        'qrData': qrData,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      return docRef.id; // Retornar el ID del documento
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al guardar QR: $e');
      }
      throw Exception('Error al guardar QR: $e');
    }
  }

  // Obtener datos del QR por loteId
  static Future<String?> getQRCodeData(String loteId) async {
    try {
      final userId = getCurrentUser()?.uid;
      if (userId == null) return null;

      final querySnapshot = await _firestore
          .collection('qr_codes')
          .where('userId', isEqualTo: userId)
          .where('loteId', isEqualTo: loteId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      return data['qrData'] as String?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al obtener datos del QR: $e');
      }
      return null;
    }
  }

  // Obtener todos los QR del usuario
  static Future<List<Map<String, dynamic>>> getAllQRCodes() async {
    try {
      print('🔍 getAllQRCodes: Iniciando...');
      
      final userId = getCurrentUser()?.uid;
      print('🔍 getAllQRCodes: userId = $userId');
      
      if (userId == null) {
        print('❌ getAllQRCodes: Usuario no autenticado');
        return [];
      }

      print('🔍 getAllQRCodes: Consultando Firestore...');
      final querySnapshot = await _firestore
          .collection('qr_codes')
          .where('userId', isEqualTo: userId)
          .get();

      print('🔍 getAllQRCodes: Documentos encontrados: ${querySnapshot.docs.length}');

      final qrCodes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('🔍 getAllQRCodes: Procesando documento ${doc.id}');
        return {
          'id': doc.id,
          'loteId': data['loteId'],
          'qrData': data['qrData'],
          'fechaCreacion': data['fechaCreacion'],
        };
      }).toList();

      print('🔍 getAllQRCodes: QR codes procesados: ${qrCodes.length}');

      // Ordenar localmente por fecha de creación (más reciente primero)
      qrCodes.sort((a, b) {
        final aDate = a['fechaCreacion'] as Timestamp?;
        final bDate = b['fechaCreacion'] as Timestamp?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      print('✅ getAllQRCodes: Retornando ${qrCodes.length} QR codes');
      return qrCodes;
    } catch (e) {
      print('❌ getAllQRCodes: Error = $e');
      throw Exception('Error al obtener QR codes: $e');
    }
  }

  // Buscar QR por loteId
  static Future<List<Map<String, dynamic>>> searchQRCodes(String searchTerm) async {
    try {
      final userId = getCurrentUser()?.uid;
      if (userId == null) return [];

      final querySnapshot = await _firestore
          .collection('qr_codes')
          .where('userId', isEqualTo: userId)
          .get();

      final qrCodes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'loteId': data['loteId'],
          'qrData': data['qrData'],
          'fechaCreacion': data['fechaCreacion'],
        };
      }).toList();

      // Filtrar localmente por término de búsqueda
      final filteredQRCodes = qrCodes.where((qr) {
        final loteId = qr['loteId'].toString().toLowerCase();
        return loteId.contains(searchTerm.toLowerCase());
      }).toList();

      // Ordenar por fecha de creación
      filteredQRCodes.sort((a, b) {
        final aDate = a['fechaCreacion'] as Timestamp?;
        final bDate = b['fechaCreacion'] as Timestamp?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return filteredQRCodes;
    } catch (e) {
      throw Exception('Error al buscar QR codes: $e');
    }
  }

  // Eliminar QR
  static Future<void> deleteQRCode(String qrId) async {
    try {
      final userId = getCurrentUser()?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener datos del QR
      final doc = await _firestore.collection('qr_codes').doc(qrId).get();
      if (!doc.exists) {
        throw Exception('QR no encontrado');
      }

      final data = doc.data()!;
      if (data['userId'] != userId) {
        throw Exception('No tienes permisos para eliminar este QR');
      }

      // Eliminar de Firestore
      await _firestore.collection('qr_codes').doc(qrId).delete();
    } catch (e) {
      throw Exception('Error al eliminar QR: $e');
    }
  }
} 