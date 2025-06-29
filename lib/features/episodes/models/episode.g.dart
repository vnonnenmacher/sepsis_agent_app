// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
  id: (json['id'] as num).toInt(),
  patientId: json['patient_id'] as String,
  patientName: json['patient_name'] as String,
  startedAt: json['started_at'] as String,
  endedAt: json['ended_at'] as String?,
  status: json['status'] as String,
);

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
  'id': instance.id,
  'patient_id': instance.patientId,
  'patient_name': instance.patientName,
  'started_at': instance.startedAt,
  'ended_at': instance.endedAt,
  'status': instance.status,
};
