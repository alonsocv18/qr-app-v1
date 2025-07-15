import 'package:flutter/material.dart';
import '../models/trazability_models.dart';

class TrazabilityInfoScreen extends StatelessWidget {
  final TrazabilidadCompleta trazabilidad;

  const TrazabilityInfoScreen({
    super.key,
    required this.trazabilidad,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información de Trazabilidad'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildLoteInfo(),
            const SizedBox(height: 20),
            if (trazabilidad.postcosecha != null) ...[
              _buildPostcosechaInfo(),
              const SizedBox(height: 20),
            ],
            if (trazabilidad.empacado != null) ...[
              _buildEmpacadoInfo(),
              const SizedBox(height: 20),
            ],
            if (trazabilidad.distribucion != null) ...[
              _buildDistribucionInfo(),
              const SizedBox(height: 20),
            ],
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            'Mango ${trazabilidad.lote.variedad}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'ID: ${trazabilidad.lote.id}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoteInfo() {
    return _buildInfoCard(
      title: 'Información del Lote',
      icon: Icons.agriculture,
      color: Colors.green,
      children: [
        _buildInfoRow('Productor', trazabilidad.lote.productor),
        _buildInfoRow('Ubicación', trazabilidad.lote.ubicacion),
        _buildInfoRow('Variedad', trazabilidad.lote.variedad),
        _buildInfoRow('Fecha de Cosecha', 
          '${trazabilidad.lote.fechaCosecha.day}/${trazabilidad.lote.fechaCosecha.month}/${trazabilidad.lote.fechaCosecha.year}'),
        if (trazabilidad.lote.coordenadasGPS != null)
          _buildInfoRow('Coordenadas GPS', trazabilidad.lote.coordenadasGPS!),
        _buildInfoRow('Estado', _getEstadoText(trazabilidad.lote.estado)),
      ],
    );
  }

  Widget _buildPostcosechaInfo() {
    final postcosecha = trazabilidad.postcosecha!;
    return _buildInfoCard(
      title: 'Información de Postcosecha',
      icon: Icons.water_drop,
      color: Colors.blue,
      children: [
        _buildInfoRow('Tratamiento', postcosecha.tipoTratamiento),
        _buildInfoRow('Temperatura', postcosecha.temperatura),
        _buildInfoRow('Duración', postcosecha.duracion),
        _buildInfoRow('Grado de Madurez', postcosecha.gradoMadurez),
        if (postcosecha.observaciones != null && postcosecha.observaciones!.isNotEmpty)
          _buildInfoRow('Observaciones', postcosecha.observaciones!),
      ],
    );
  }

  Widget _buildEmpacadoInfo() {
    final empacado = trazabilidad.empacado!;
    return _buildInfoCard(
      title: 'Información de Empacado',
      icon: Icons.inventory_2,
      color: Colors.orange,
      children: [
        _buildInfoRow('Cantidad de Cajas', empacado.cantidadCajas),
        _buildInfoRow('Peso por Caja', empacado.pesoPorCaja),
        _buildInfoRow('Tipo de Caja', empacado.tipoCaja),
        _buildInfoRow('Cantidad de Pallets', empacado.cantidadPallets),
        _buildInfoRow('Tipo de Pallet', empacado.tipoPallet),
        if (empacado.observaciones != null && empacado.observaciones!.isNotEmpty)
          _buildInfoRow('Observaciones', empacado.observaciones!),
      ],
    );
  }

  Widget _buildDistribucionInfo() {
    final distribucion = trazabilidad.distribucion!;
    return _buildInfoCard(
      title: 'Información de Distribución',
      icon: Icons.local_shipping,
      color: Colors.red,
      children: [
        _buildInfoRow('Destino', distribucion.destino),
        _buildInfoRow('Transportista', distribucion.transportista),
        _buildInfoRow('Placa del Vehículo', distribucion.placaVehiculo),
        _buildInfoRow('Tipo de Transporte', _getTipoTransporteText(distribucion.tipoTransporte)),
        _buildInfoRow('Fecha de Salida', 
          '${distribucion.fechaSalida.day}/${distribucion.fechaSalida.month}/${distribucion.fechaSalida.year}'),
        if (distribucion.fechaLlegada != null)
          _buildInfoRow('Fecha de Llegada', 
            '${distribucion.fechaLlegada!.day}/${distribucion.fechaLlegada!.month}/${distribucion.fechaLlegada!.year}'),
        _buildInfoRow('Estado', _getEstadoDistribucionText(distribucion.estado)),
        if (distribucion.observaciones != null && distribucion.observaciones!.isNotEmpty)
          _buildInfoRow('Observaciones', distribucion.observaciones!),
      ],
    );
  }

  Widget _buildTimeline() {
    return _buildInfoCard(
      title: 'Cronología del Proceso',
      icon: Icons.timeline,
      color: Colors.purple,
      children: [
        _buildTimelineStep(
          'Cosecha',
          '${trazabilidad.lote.fechaCosecha.day}/${trazabilidad.lote.fechaCosecha.month}/${trazabilidad.lote.fechaCosecha.year}',
          Icons.agriculture,
          Colors.green,
          isCompleted: true,
        ),
        _buildTimelineStep(
          'Postcosecha',
          trazabilidad.postcosecha != null ? 'Completado' : 'Pendiente',
          Icons.water_drop,
          Colors.blue,
          isCompleted: trazabilidad.postcosecha != null,
        ),
        _buildTimelineStep(
          'Empacado',
          trazabilidad.empacado != null ? 'Completado' : 'Pendiente',
          Icons.inventory_2,
          Colors.orange,
          isCompleted: trazabilidad.empacado != null,
        ),
        _buildTimelineStep(
          'Distribución',
          trazabilidad.distribucion != null 
              ? (trazabilidad.distribucion!.estado == 'entregado' ? 'Entregado' : 'En tránsito')
              : 'Pendiente',
          Icons.local_shipping,
          Colors.red,
          isCompleted: trazabilidad.distribucion != null,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String date,
    IconData icon,
    Color color,
    {required bool isCompleted}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: isCompleted ? color : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: color,
              size: 20,
            ),
        ],
      ),
    );
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'cosechado':
        return 'Cosechado';
      case 'postcosecha':
        return 'En Postcosecha';
      case 'empacado':
        return 'Empacado';
      case 'paletizado':
        return 'Paletizado';
      case 'almacenado':
        return 'Almacenado';
      case 'transportado':
        return 'En Transporte';
      case 'distribuido':
        return 'Distribuido';
      default:
        return estado;
    }
  }

  String _getTipoTransporteText(String tipoTransporte) {
    switch (tipoTransporte) {
      case 'refrigerado':
        return 'Refrigerado';
      case 'normal':
        return 'Normal';
      case 'especial':
        return 'Especial';
      default:
        return tipoTransporte;
    }
  }

  String _getEstadoDistribucionText(String estado) {
    switch (estado) {
      case 'en_transito':
        return 'En tránsito';
      case 'entregado':
        return 'Entregado';
      case 'retrasado':
        return 'Retrasado';
      default:
        return estado;
    }
  }
} 