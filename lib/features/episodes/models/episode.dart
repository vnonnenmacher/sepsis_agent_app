import 'package:json_annotation/json_annotation.dart';

part 'episode.g.dart';

@JsonSerializable()
class Episode {
  final int id;
  @JsonKey(name: 'patient_id')
  final String patientId;
  @JsonKey(name: 'patient_name')
  final String patientName;
  @JsonKey(name: 'started_at')
  final String startedAt;
  @JsonKey(name: 'ended_at')
  final String? endedAt;
  final String status;

  Episode({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.startedAt,
    this.endedAt,
    required this.status,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeToJson(this);
}
