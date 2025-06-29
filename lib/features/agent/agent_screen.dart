import 'package:flutter/material.dart';
import '../../core/widgets/app_scaffold.dart';

class AgentScreen extends StatelessWidget {
  const AgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;

          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.4,
                  child: const AgentProfile(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Container(
                    color: Colors.blue.shade50,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        AgentStatus(),
                        SizedBox(height: 32),
                        SectionTitle(title: 'Alertas'),
                        AgentAlerts(),
                        SizedBox(height: 32),
                        SectionTitle(title: 'Mensagens'),
                        AgentMessages(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                AgentProfile(),
                Divider(height: 1),
                AgentStatus(),
                SizedBox(height: 32),
                SectionTitle(title: 'Alertas'),
                AgentAlerts(),
                SizedBox(height: 32),
                SectionTitle(title: 'Mensagens'),
                AgentMessages(),
              ],
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────
// UI Components
// ─────────────────────────────

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class AgentProfile extends StatelessWidget {
  const AgentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/distress.png'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sepsis Agent',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seu assistente na gestão de casos de sepse.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SystemStatusSection(currentStatus: AgentSystemStatus.alerta),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AgentSuggestions(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ─────────────────────────────
// System Status (Alerta | Atenção | Estável)
// ─────────────────────────────

enum AgentSystemStatus { alerta, atencao, estavel }

class SystemStatusSection extends StatelessWidget {
  final AgentSystemStatus currentStatus;

  const SystemStatusSection({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SystemStatusCardData(
        label: 'Alerta',
        icon: Icons.warning_amber_rounded,
        color: Colors.red,
        status: AgentSystemStatus.alerta,
      ),
      _SystemStatusCardData(
        label: 'Atenção',
        icon: Icons.report_problem,
        color: Colors.orange,
        status: AgentSystemStatus.atencao,
      ),
      _SystemStatusCardData(
        label: 'Estável',
        icon: Icons.check_circle,
        color: Colors.green,
        status: AgentSystemStatus.estavel,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cards.map((card) {
        final isActive = card.status == currentStatus;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              elevation: isActive ? 4 : 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: isActive ? card.color : Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      card.icon,
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isActive ? Colors.white : Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SystemStatusCardData {
  final String label;
  final IconData icon;
  final Color color;
  final AgentSystemStatus status;

  const _SystemStatusCardData({
    required this.label,
    required this.icon,
    required this.color,
    required this.status,
  });
}

// ─────────────────────────────
// Status Metrics (Top Cards)
// ─────────────────────────────

class AgentStatus extends StatelessWidget {
  const AgentStatus({super.key});

  @override
  Widget build(BuildContext context) {
    const totalOpen = 12;
    const openWithoutCulture = 4;
    const openWithoutAntibiotic = 7;
    const openWithPositiveCulture = 3;

    final items = [
      _StatusItemData(label: 'Casos abertos', value: totalOpen, icon: Icons.local_hospital),
      _StatusItemData(label: 'Sem cultura coletada', value: openWithoutCulture, icon: Icons.biotech),
      _StatusItemData(label: 'Sem antibiótico', value: openWithoutAntibiotic, icon: Icons.medical_services),
      _StatusItemData(label: 'Culturas positivas', value: openWithPositiveCulture, icon: Icons.science),
      _StatusItemData(label: 'Lactato elevado', value: 5, icon: Icons.trending_up),
      _StatusItemData(label: 'Instabilidade hemodinâmica', value: 2, icon: Icons.monitor_heart),
      _StatusItemData(label: 'Sem reavaliação médica', value: 4, icon: Icons.schedule),
      _StatusItemData(label: 'Uso prolongado de antibiótico', value: 3, icon: Icons.warning_amber),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((item) {
            return SizedBox(
              width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
              child: _StatusCard(item: item),
            );
          }).toList(),
        );
      },
    );
  }
}

class _StatusItemData {
  final String label;
  final int value;
  final IconData icon;

  const _StatusItemData({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _StatusCard extends StatelessWidget {
  final _StatusItemData item;

  const _StatusCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 32, color: Colors.blue.shade600),
            const SizedBox(height: 12),
            Text(
              item.value.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────
// Alertas e Mensagens
// ─────────────────────────────

enum AlertType { info, warning, critical }

class _AlertMessage {
  final AlertType type;
  final String title;
  final String content;

  const _AlertMessage({
    required this.type,
    required this.title,
    required this.content,
  });
}

class _AlertCard extends StatelessWidget {
  final _AlertMessage msg;

  const _AlertCard({super.key, required this.msg});

  Color _backgroundColor() {
    switch (msg.type) {
      case AlertType.critical:
        return Colors.red.shade50;
      case AlertType.warning:
        return Colors.orange.shade50;
      case AlertType.info:
      default:
        return Colors.blue.shade50;
    }
  }

  IconData _iconData() {
    switch (msg.type) {
      case AlertType.critical:
        return Icons.error_outline;
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.info:
      default:
        return Icons.info_outline;
    }
  }

  Color _borderColor() {
    switch (msg.type) {
      case AlertType.critical:
        return Colors.red;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.info:
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _backgroundColor(),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _borderColor(), width: 1.4),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconData(), size: 28, color: _borderColor()),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgentAlerts extends StatelessWidget {
  const AgentAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      _AlertMessage(
        type: AlertType.critical,
        title: 'Deterioração rápida',
        content: 'Status do paciente João está piorando aceleradamente.',
      ),
      _AlertMessage(
        type: AlertType.critical,
        title: 'Protocolo violado',
        content: 'Culturas não foram coletadas antes do antibiótico.',
      ),
    ];

    return Column(
      children: alerts.map((msg) => _AlertCard(msg: msg)).toList(),
    );
  }
}

class AgentMessages extends StatelessWidget {
  const AgentMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      _AlertMessage(
        type: AlertType.info,
        title: 'Sugestão terapêutica',
        content: 'Troca de antibiótico recomendada para paciente Ana.',
      ),
      _AlertMessage(
        type: AlertType.info,
        title: 'Novo antibiograma',
        content: 'Resultado disponível para paciente Paulo.',
      ),
    ];

    return Column(
      children: messages.map((msg) => _AlertCard(msg: msg)).toList(),
    );
  }
}

// ─────────────────────────────
// IA Suggestions
// ─────────────────────────────

class AgentSuggestions extends StatelessWidget {
  const AgentSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      ('🧬', 'Revisar terapia antibiótica para o paciente Paulo.'),
      ('💊', 'Substituir antibiótico do paciente Paulo para Amoxicilina.'),
      ('💉', 'Adicionar antibiótico Meropenem para paciente Ana.'),
      ('🧪', 'Solicitar culturas para o paciente Gabriel.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.indigo, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sugestões da IA',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: suggestions.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: Colors.indigo.shade400, width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Text(s.$1, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.$2,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
