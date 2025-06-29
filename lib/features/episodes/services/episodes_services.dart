import 'package:dio/dio.dart';
import '../models/episode.dart';

class EpisodesService {
  final Dio dio;

  EpisodesService({required this.dio});

  Future<List<Episode>> fetchEpisodes() async {
    try {
      final response = await dio.get('/api/sepsis/episodes/');
      final data = response.data as List;

      return data.map((e) => Episode.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load episodes: $e');
    }
  }
}
