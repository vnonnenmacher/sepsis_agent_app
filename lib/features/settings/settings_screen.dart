import 'package:flutter/material.dart';
import 'package:sepsis_agent_app/features/settings/tabs/tags_tab.dart';
import '../../core/widgets/app_scaffold.dart';
import 'tabs/knowledge_base_tab.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Updated length to 4
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações do Agente',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                Material(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    tabs: const [
                      Tab(text: '📚 Base de Conhecimento'),
                      Tab(text: '🏷️ Tags'),
                      Tab(text: '⚙️ Gerais'),
                      Tab(text: '💬 Comunicações'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      KnowledgeBaseTab(),
                      TagsTab(),
                      _GeneralSettingsTab(),
                      _CommunicationTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


// ─────────────────────────────
// ⚙️ TAB 2: Configurações Gerais
// ─────────────────────────────

class _GeneralSettingsTab extends StatefulWidget {
  const _GeneralSettingsTab();

  @override
  State<_GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}

class _GeneralSettingsTabState extends State<_GeneralSettingsTab> {
  bool enableAi = true;
  bool enableAutoAlert = false;
  String language = 'Português';
  int maxAlerts = 3;
  String protocolVersion = 'Protocolo_Sepse_v1.pdf';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Ativar sugestões da IA'),
          value: enableAi,
          onChanged: (v) => setState(() => enableAi = v),
        ),
        SwitchListTile(
          title: const Text('Alertas automáticos para suspeita de sepse'),
          value: enableAutoAlert,
          onChanged: (v) => setState(() => enableAutoAlert = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: language,
          decoration: const InputDecoration(labelText: 'Idioma padrão'),
          items: ['Português', 'English']
              .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
              .toList(),
          onChanged: (v) => setState(() => language = v!),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: maxAlerts.toString(),
          decoration: const InputDecoration(labelText: 'Máx. alertas por paciente'),
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() => maxAlerts = int.tryParse(v) ?? 3),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: protocolVersion,
          decoration: const InputDecoration(labelText: 'Versão do protocolo'),
          items: [
            'Protocolo_Sepse_v1.pdf',
            'Protocolo_Sepse_v2.pdf',
          ].map((file) => DropdownMenuItem(value: file, child: Text(file))).toList(),
          onChanged: (v) => setState(() => protocolVersion = v!),
        ),
      ],
    );
  }
}

// ─────────────────────────────
// 💬 TAB 3: Comunicações (Webhook HIS)
// ─────────────────────────────

class _CommunicationTab extends StatefulWidget {
  const _CommunicationTab();

  @override
  State<_CommunicationTab> createState() => _CommunicationTabState();
}

class _CommunicationTabState extends State<_CommunicationTab> {
  final _webhookController = TextEditingController();
  bool escalate = false;
  int escalationDelay = 15;
  final selectedChannels = <String>{};

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: _webhookController,
          decoration: const InputDecoration(
            labelText: 'URL do Webhook HIS',
            hintText: 'https://his.example.com/webhook',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Canais a notificar', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['CCIH', 'Enfermagem', 'Médicos'].map((channel) {
            return FilterChip(
              label: Text(channel),
              selected: selectedChannels.contains(channel),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedChannels.add(channel);
                  } else {
                    selectedChannels.remove(channel);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Escalonar alertas de emergência'),
          value: escalate,
          onChanged: (v) => setState(() => escalate = v),
        ),
        if (escalate)
          TextFormField(
            initialValue: escalationDelay.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minutos até escalonamento'),
            onChanged: (v) => setState(() => escalationDelay = int.tryParse(v) ?? 15),
          ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: test webhook logic
          },
          icon: const Icon(Icons.check),
          label: const Text('Testar Webhook'),
        ),
      ],
    );
  }
}
