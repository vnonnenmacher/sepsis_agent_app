import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../models/document.dart';
import '../services/document_service.dart';
import 'package:flutter/foundation.dart';


class KnowledgeBaseTab extends StatefulWidget {
  const KnowledgeBaseTab({super.key});

  @override
  State<KnowledgeBaseTab> createState() => _KnowledgeBaseTabState();
}

class _KnowledgeBaseTabState extends State<KnowledgeBaseTab> {
  String? selectedDocumentId;
  List<Document> documents = [];
  bool isLoading = true;

  final categories = [
    'Protocolos de Infecção (local)',
    'Protocolos Gerais Institucionais',
    'Protocolos Nacionais e Internacionais',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final result = await DocumentService.fetchDocuments();
      setState(() {
        documents = result;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showUploadDialog(BuildContext context, String categoryLabel) async {
    final translatedCategory = {
      'Protocolos de Infecção (local)': 'infection_protocol',
      'Protocolos Gerais Institucionais': 'institutional_protocol',
      'Protocolos Nacionais e Internacionais': 'governmental_protocol',
      'Fluxogramas': 'flowchart',
      'Outros': 'other',
    }[categoryLabel];

    final fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // ✅ required for web
    );

    if (fileResult == null) return;

    final versionController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Versão do Documento'),
        content: TextField(
          controller: versionController,
          decoration: const InputDecoration(labelText: 'Ex: v1.0'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // ✅ Correct cross-platform logic:
    dynamic fileToUpload;
    if (kIsWeb) {
      fileToUpload = fileResult.files.single; // PlatformFile with .bytes
    } else {
      final filePath = fileResult.files.single.path;
      if (filePath == null) return;
      fileToUpload = File(filePath); // dart:io File
    }

    try {
      await DocumentService.uploadDocument(
        fileSource: fileToUpload,
        category: translatedCategory ?? 'other',
        version: versionController.text,
      );
      await _loadDocuments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar o documento')),
      );
    }
  }


  String _translateCategory(String category) {
    switch (category) {
      case 'infection_protocol':
        return 'Protocolos de Infecção (local)';
      case 'institutional_protocol':
        return 'Protocolos Gerais Institucionais';
      case 'governmental_protocol':
        return 'Protocolos Nacionais e Internacionais';
      case 'flowchart':
        return 'Fluxogramas';
      default:
        return 'Outros';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    final groupedDocs = {
      for (var cat in categories)
        cat: documents
            .where((doc) => _translateCategory(doc.category) == cat)
            .toList()
    };

    Document? selectedDoc;
    if (documents.isNotEmpty) {
      selectedDoc = documents.firstWhere(
        (doc) => doc.id.toString() == selectedDocumentId,
        orElse: () => documents.first,
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                  onUploadRequested: (cat) => _showUploadDialog(context, cat),
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
                onUploadRequested: (cat) => _showUploadDialog(context, cat),
              ),
              const Divider(height: 32),
              if (selectedDoc != null) _DocumentDetails(document: selectedDoc),
            ],
          );
  }
}

class _GroupedDocumentList extends StatelessWidget {
  final Map<String, List<Document>> groupedDocs;
  final String? selectedId;
  final Function(String) onSelected;
  final Function(String) onUploadRequested;

  const _GroupedDocumentList({
    required this.groupedDocs,
    required this.selectedId,
    required this.onSelected,
    required this.onUploadRequested,
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

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (docs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 12),
                    child: Text(
                      'Nenhum documento',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                else
                  Column(
                    children: docs.map((doc) {
                      final isSelected = doc.id.toString() == selectedId;
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => onSelected(doc.id.toString()),
                          child: Container(
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4, right: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    doc.name,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.blue.shade800 : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => onUploadRequested(category),
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 24,
                    color: Colors.blueGrey.shade700,
                    tooltip: 'Adicionar documento',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocumentDetails extends StatelessWidget {
  final Document document;

  const _DocumentDetails({required this.document});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(document.uploadedAt);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          document.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(label: Text(document.category)),
            Chip(label: Text('Versão ${document.version}')),
            Chip(label: Text('Enviado em $dateFormatted')),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Descrição não disponível (virá do backend futuramente).'),
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
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Remover Documento'),
                    content: const Text('Tem certeza que deseja remover este documento?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Remover'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                try {
                  await DocumentService.deleteDocument(document.id);

                  // Find nearest state and refresh
                  final state = context.findAncestorStateOfType<_KnowledgeBaseTabState>();
                  state?.setState(() {
                    state.documents.removeWhere((d) => d.id == document.id);
                    state.selectedDocumentId = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Documento removido com sucesso')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao remover documento')),
                  );
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Remover'),
            ),
          ],
        ),
      ],
    );
  }
}
