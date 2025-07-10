import 'package:flutter/material.dart';
import '../services/tag_service.dart';

class TagsTab extends StatefulWidget {
  const TagsTab({super.key});

  @override
  State<TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends State<TagsTab> {
  final TagService _tagService = TagService();
  List<dynamic> tags = [];
  dynamic selectedTag;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedTags = await _tagService.fetchTags();
      setState(() {
        tags = fetchedTags;
        selectedTag = fetchedTags.isNotEmpty ? fetchedTags[0] : null;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading tags: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar as tags')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tags.isEmpty) {
      return const Center(child: Text('Nenhuma tag encontrada.'));
    }

    return Row(
      children: [
        // Left Section: List of Tags
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final isSelected = selectedTag != null && selectedTag['id'] == tag['id'];

              return Card(
                color: isSelected ? Colors.blue.shade50 : null,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    tag['display_name'] ?? 'Sem nome',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(tag['description'] ?? 'Sem descrição'),
                  onTap: () {
                    setState(() {
                      selectedTag = tag;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),

        // Right Section: Tag Details
        Expanded(
          child: selectedTag != null
              ? _TagDetails(tag: selectedTag)
              : const Center(child: Text('Nenhuma tag selecionada.')),
        ),
      ],
    );
  }
}

class _TagDetails extends StatelessWidget {
  final dynamic tag;

  const _TagDetails({required this.tag});

  @override
  Widget build(BuildContext context) {
    final conditions = tag['conditions'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag['display_name'] ?? 'Sem nome',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            tag['description'] ?? 'Sem descrição',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Condições:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: conditions.length,
              itemBuilder: (context, index) {
                final condition = conditions[index];
                final conditionType = condition['condition_type'] ?? 'Sem tipo';
                final expression = condition['expression'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      conditionType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (conditionType == 'event' || conditionType == 'tag')
                          Text('Nome: ${condition['name'] ?? 'Sem nome'}'),
                        if (condition['field_path'] != null)
                          Text('Campo: ${condition['field_path']}'),
                        if (condition['operator'] != null)
                          Text('Operador: ${condition['operator']}'),
                        if (condition['value'] != null)
                          Text('Valor: ${condition['value']}'),
                        if (expression != null)
                          Text('Expressão: $expression'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}