import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../patient/patient_screen.dart';

import '../../core/widgets/app_scaffold.dart';
import './providers/episoders_provider.dart';
import 'models/episode.dart';

class EpisodesListScreen extends ConsumerStatefulWidget {
  const EpisodesListScreen({super.key});

  @override
  ConsumerState<EpisodesListScreen> createState() => _EpisodesListScreenState();
}

class _EpisodesListScreenState extends ConsumerState<EpisodesListScreen> {
  String searchQuery = '';
  String selectedTag = 'Todos';

  final allTags = [
    'Todos',
    'Revisão terapêutica necessária',
    'Sugestão de antibiótico',
    'Não conformidade ao protocolo'
  ];

  @override
  Widget build(BuildContext context) {
    final episodesAsync = ref.watch(episodesProvider);

    return AppScaffold(
      child: Container(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: episodesAsync.when(
            data: (episodes) {
              final filtered = episodes.where((ep) {
                final matchesSearch =
                    ep.patientName.toLowerCase().contains(searchQuery.toLowerCase());
                final mockTags = _mockTagsFor(ep);
                final matchesTag = selectedTag == 'Todos' ||
                    mockTags.any((t) => t.$2 == selectedTag);
                return matchesSearch && matchesTag;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Painel de Pacientes',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por paciente...',
                      prefixIcon: const Icon(Icons.search),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children: allTags.map((tag) {
                      final selected = tag == selectedTag;
                      return ChoiceChip(
                        label: Text(tag, style: const TextStyle(fontSize: 13)),
                        selected: selected,
                        onSelected: (_) => setState(() => selectedTag = tag),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  Expanded(child: _buildGrid(context, filtered)),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erro: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Episode> episodes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(context, constraints);

        return GridView.builder(
          itemCount: episodes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final episode = episodes[index];
            return EpisodeCard(
              episode: episode,
              tags: _mockTagsFor(episode),
            );
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (width >= 900) {
      return isPortrait ? 2 : 4;
    }
    return 1;
  }

  List<(String, String, bool)> _mockTagsFor(Episode episode) {
    final rng = Random(episode.patientName.hashCode);
    final tagPool = [
      ('🩺', 'Revisão terapêutica necessária', false),
      ('💊', 'Sugestão de antibiótico', false),
      ('⚠️', 'Não conformidade ao protocolo', true),
    ];
    return tagPool.where((_) => rng.nextBool()).toList();
  }
}

class EpisodeCard extends StatelessWidget {
  final Episode episode;
  final List<(String, String, bool)> tags;

  const EpisodeCard({super.key, required this.episode, required this.tags});

  int _calculateDaysSinceStart(String startedAt) {
    final startDate = DateTime.parse(startedAt);
    return DateTime.now().difference(startDate).inDays;
  }

  String _mockGender(String seed) {
    final rng = Random(seed.hashCode);
    return rng.nextBool() ? 'male' : 'female';
  }

  int _mockAge(String seed) {
    final rng = Random(seed.hashCode + 42);
    return rng.nextInt(80); // age 0 to 79
  }

  Icon _getIcon(String gender, int age) {
    if (gender == 'female' && age < 12) {
      return const Icon(Icons.girl, size: 28, color: Colors.pink);
    } else if (gender == 'female' && age >= 60) {
      return const Icon(Icons.elderly_woman, size: 28, color: Colors.pink);
    } else if (gender == 'female') {
      return const Icon(Icons.female, size: 28, color: Colors.pink);
    } else if (gender == 'male' && age < 12) {
      return const Icon(Icons.boy, size: 28, color: Colors.blue);
    } else if (gender == 'male' && age >= 60) {
      return const Icon(Icons.elderly, size: 28, color: Colors.blue);
    } else {
      return const Icon(Icons.male, size: 28, color: Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _calculateDaysSinceStart(episode.startedAt);
    final gender = _mockGender(episode.patientName);
    final age = _mockAge(episode.patientName);
    final icon = _getIcon(gender, age);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PatientScreen(episode: episode),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      episode.patientName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                'Início: ${episode.startedAt.substring(0, 10)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Internado há $days dias',
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final isAlert = tag.$3;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAlert ? Colors.red.shade50 : Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAlert ? Colors.red : Colors.indigo.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag.$1),
                        const SizedBox(width: 4),
                        Text(
                          tag.$2,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isAlert ? Colors.red.shade800 : Colors.black87,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
