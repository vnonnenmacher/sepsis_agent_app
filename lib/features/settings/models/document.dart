class Document {
  final int id;
  final String name;
  final String category;
  final String version;
  final String minioPath;
  final DateTime uploadedAt;

  Document({
    required this.id,
    required this.name,
    required this.category,
    required this.version,
    required this.minioPath,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      version: json['version'],
      minioPath: json['minio_path'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}
