import 'package:flutter/material.dart';

class KnowledgeBaseTab extends StatefulWidget {
  const KnowledgeBaseTab({super.key});

  @override
  State<KnowledgeBaseTab> createState() => _KnowledgeBaseTabState();
}

class _KnowledgeBaseTabState extends State<KnowledgeBaseTab> {
  String? selectedDocumentId;

  final List<Map<String, dynamic>> documents = [
    {
      'id': 'doc1',
      'name': 'Protocolo_Sepse_v1.pdf',
      'category': 'Protocolos de Infecção (local)',
      'description': 'Conduta inicial para casos suspeitos de sepse.',
      'version': '1.0',
      'uploaded': DateTime(2025, 6, 20),
    },
    {
      'id': 'doc2',
      'name': 'Fluxo_Sepse_UnidadeX.pdf',
      'category': 'Protocolos de Infecção (local)',
      'description': 'Fluxograma para atendimento de sepse na unidade X.',
      'version': '1.2',
      'uploaded': DateTime(2025, 6, 18),
    },
    {
      'id': 'doc3',
      'name': 'Diretrizes_CCIH.pdf',
      'category': 'Protocolos Gerais Institucionais',
      'description': 'Diretrizes gerais de controle de infecção.',
      'version': '3.0',
      'uploaded': DateTime(2025, 6, 10),
    },
    {
      'id': 'doc4',
      'name': 'Guia_Antibiotico_2025.pdf',
      'category': 'Outros',
      'description': 'Tabela atualizada de antibióticos e espectros.',
      'version': '2.1',
      'uploaded': DateTime(2025, 6, 12),
    },
  ];

  final categories = [
    'Protocolos de Infecção (local)',
    'Protocolos Gerais Institucionais',
    'Protocolos Nacionais e Internacionais',
    'Outros',
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    final groupedDocs = {
      for (var cat in categories)
        cat: documents.where((doc) => doc['category'] == cat).toList()
    };

    Map<String, dynamic>? selectedDoc;
    if (documents.isNotEmpty) {
      selectedDoc = documents.firstWhere(
        (doc) => doc['id'] == selectedDocumentId,
        orElse: () => documents.first,
      );
    }

    return isWide
        ? Row(
            children: [
              SizedBox(
                width: 320,
                child: _GroupedDocumentList(
                  groupedDocs: groupedDocs,
                  selectedId: selectedDocumentId,
                  onSelected: (id) => setState(() => selectedDocumentId = id),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: selectedDoc != null
                    ? _DocumentDetails(document: selectedDoc)
                    : const Center(child: Text('Nenhum documento selecionado')),
              ),
            ],
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GroupedDocumentList(
                groupedDocs: groupedDocs,
                selectedId: selectedDocumentId,
                onSelected: (id) => setState(() => selectedDocumentId = id),
              ),
              const Divider(height: 32),
              if (selectedDoc != null) _DocumentDetails(document: selectedDoc),
            ],
          );
  }
}

// ─────────────────────────────
// 📁 Left Pane – Categorized Document List
// ─────────────────────────────

class _GroupedDocumentList extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> groupedDocs;
  final String? selectedId;
  final Function(String) onSelected;

  const _GroupedDocumentList({
    required this.groupedDocs,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final entries = groupedDocs.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final category = entry.key;
        final docs = entry.value;
        final isLast = index == entries.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              title: Row(
                children: [
                  const Icon(Icons.menu_book_outlined, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                ],
              ),
              children: docs.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Nenhum documento nesta categoria.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ]
                  : docs.map((doc) {
                      final isSelected = doc['id'] == selectedId;
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => onSelected(doc['id']),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.blue, width: 1.2)
                                  : Border.all(color: Colors.transparent),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Image.asset(
                                    'assets/icons/pdf_icon.png',
                                    width: 28,
                                    height: 28,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc['name'],
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected ? Colors.blue.shade900 : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Versão ${doc['version']}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected
                                              ? Colors.blueGrey.shade700
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
            ),

            // 🧼 Only add a divider between categories — not after last
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 0.8,
                  height: 0,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────
// 📄 Right Pane – Document Details
// ─────────────────────────────

class _DocumentDetails extends StatelessWidget {
  final Map<String, dynamic> document;

  const _DocumentDetails({required this.document});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          document['name'],
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(label: Text(document['category'])),
            Chip(label: Text('Versão ${document['version']}')),
            Chip(
              label: Text(
                'Enviado em ${document['uploaded'].day}/${document['uploaded'].month}/${document['uploaded'].year}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          document['description'],
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: const Center(
            child: Text('🔍 Pré-visualização do PDF (1ª página)'),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('Baixar'),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Remover'),
            ),
          ],
        ),
      ],
    );
  }
}
