import 'package:flutter/material.dart';
import '../episodes/models/episode.dart';
import 'dart:math';

class PatientScreen extends StatelessWidget {
  final Episode episode;

  const PatientScreen({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.parse(episode.startedAt);
    final days = DateTime.now().difference(startDate).inDays;
    final gender = _mockGender(episode.patientName);
    final age = _mockAge(episode.patientName);
    final icon = _getIcon(gender, age);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text('Paciente: ${episode.patientName}'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _infoCard([
                    Row(
                      children: [
                        icon,
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              episode.patientName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Sexo: ${gender == 'male' ? 'Masculino' : 'Feminino'} · Idade: $age anos',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ],
                    )
                  ]),

                  _sectionTitle('Dados do Paciente'),
                  _infoCard([
                    _rowData('Status', 'Internado'),
                    _rowData('Local', 'Ala Norte'),
                    _rowData('Leito', '12B'),
                    _rowData('Dias internado', '$days dias'),
                  ]),

                  _sectionTitle('Culturas'),
                  _horizontalScroll([
                    _squareCard('Cultura 1', 'Aguardando resultado', height: 130, icon: Icons.biotech),
                    _squareCard('Cultura 2', 'Positiva para Klebsiella\nAntibiograma disponível', height: 130, icon: Icons.biotech),
                  ]),

                  _sectionTitle('Organismos Detectados'),
                  _horizontalScroll([
                    _squareCard('', 'Klebsiella pneumoniaiae', bold: true, icon: Icons.bug_report),
                  ]),

                  _sectionTitle('Antibióticos Ministrados'),
                  _horizontalScroll([
                    _squareCard('Meropenem', 'Início hoje às 14:00', bold: true, subtitleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal), icon: Icons.medication),
                  ]),

                  _sectionTitle('Eventos Clínicos'),
                  _horizontalScroll([
                    _squareCard('Febre persistente', '', alert: true, backgroundColor: const Color(0xFFFFEBEE), borderColor: Color(0xFFE53935)),
                    _squareCard('Alteração no exame pulmonar', '', backgroundColor: const Color(0xFFFFF8E1), borderColor: Color(0xFFFFB300)),
                    _squareCard('Leucocitose progressiva', '', backgroundColor: const Color(0xFFFFF8E1), borderColor: Color(0xFFFFB300)),
                    _squareCard('PCR elevado nas últimas 24h', '', backgroundColor: const Color(0xFFFFF8E1), borderColor: Color(0xFFFFB300)),
                  ]),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: ListView(
                children: [
                  _sectionWithIcon('Status Geral', Icons.monitor_heart),
                  _statusCard('Alerta', Icons.warning_amber_rounded, Colors.red),

                  _sectionWithIcon('Protocolos Ativos', Icons.library_books),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip('Protocolo de Sepse'),
                      _chip('Protocolo Cirurgia Ortopédica'),
                    ],
                  ),

                  _sectionWithIcon('Antibiótico Profilático', Icons.medical_services_outlined),
                  _highlightCard('Meropenem',
                      'Recomendado pela CCIH por sua eficácia contra Gram-negativos multirresistentes.'),

                  _sectionWithIcon('Recomendação Terapêutica', Icons.recommend_outlined),
                  _highlightCard('Aguardar resultado da cultura 2',
                      'Ajustes terapêuticos devem considerar o resultado definitivo para garantir efetividade e reduzir resistência.'),

                  _sectionWithIcon('Problemas e Alertas', Icons.warning_amber_outlined),
                  _alert('Antibiótico ministrado não corresponde à diretriz do protocolo'),
                  _alert('Paciente sem reavaliação médica há mais de 48h'),

                  _sectionWithIcon('Sugestões da IA', Icons.psychology_alt_outlined),
                  _aiSuggestion('💊 Considerar troca para Cefepime com base no antibiograma parcial'),
                  _aiSuggestion('🧪 Solicitar nova hemocultura em 24h'),
                  _aiSuggestion('📊 Avaliar função renal devido ao uso prolongado de Meropenem'),

                  _sectionWithIcon('Disclaimer', Icons.info_outline),
                  _infoCard([
                    Text(
                      'Este caso exige contato com a CCIH para tomada de decisão. A presença de multirresistência e discrepância com o protocolo institucional indicam necessidade de revisão clínica.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String _mockGender(String seed) => 'male';
  int _mockAge(String seed) => 10 + seed.hashCode.abs() % 80;

  Icon _getIcon(String gender, int age) {
    if (gender == 'female' && age < 12) return const Icon(Icons.child_care, size: 36, color: Colors.pink);
    if (gender == 'female' && age >= 60) return const Icon(Icons.elderly_woman, size: 36, color: Colors.pink);
    if (gender == 'female') return const Icon(Icons.female, size: 36, color: Colors.pink);
    if (gender == 'male' && age < 12) return const Icon(Icons.child_care, size: 36, color: Colors.blue);
    if (gender == 'male' && age >= 60) return const Icon(Icons.elderly, size: 36, color: Colors.blue);
    return const Icon(Icons.male, size: 36, color: Colors.blue);
  }

  Widget _squareCard(String title, String subtitle, {
    bool alert = false,
    Color? backgroundColor,
    Color? borderColor,
    bool bold = false,
    double height = 120,
    TextStyle? subtitleStyle,
    IconData? icon,
  }) {
    final titleStyle = const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87);
    final subStyle = subtitleStyle ?? TextStyle(
      fontSize: 13,
      fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
      color: Colors.grey.shade900,
    );

    return Container(
      width: 180,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? (alert ? const Color(0xFFFFF3E0) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? (alert ? const Color(0xFFFFA726) : Colors.grey.shade300),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: Colors.grey.shade700),
            const SizedBox(height: 6),
          ],
          if (title.isNotEmpty)
            Text(title, textAlign: TextAlign.center, style: titleStyle),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: subStyle, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _horizontalScroll(List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: children),
        ),
      );

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _sectionWithIcon(String title, IconData icon) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.indigo),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      );

  Widget _rowData(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            Expanded(child: Text(value)),
          ],
        ),
      );

  Widget _chip(String text) => Chip(label: Text(text));

  Widget _statusCard(String title, IconData icon, Color color) => Card(
        color: color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

  Widget _highlightCard(String title, String explanation) => Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 6),
              Text(explanation, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      );

  Widget _alert(String text) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border(left: BorderSide(color: Colors.red.shade300, width: 4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.red))),
          ],
        ),
      );

  Widget _aiSuggestion(String text) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          border: Border(left: BorderSide(color: Colors.indigo.shade300, width: 4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: const TextStyle(color: Colors.black87)),
      );

  Widget _infoCard(List<Widget> children) => Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
}
