import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/dio_client.dart';
import '../models/episode.dart';
import '../services/episodes_services.dart';

final dioProvider = Provider<Dio>((ref) => DioClient.create());

final episodesServiceProvider = Provider<EpisodesService>((ref) {
  final dio = ref.watch(dioProvider);
  return EpisodesService(dio: dio);
});

final episodesProvider = FutureProvider<List<Episode>>((ref) async {
  final service = ref.watch(episodesServiceProvider);
  return service.fetchEpisodes();
});
