import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../models/document.dart';

class DocumentService {
  static Future<List<Document>> fetchDocuments() async {
    final uri = Uri.parse('http://localhost:8000/api/protocols/documents/');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Erro ao buscar documentos");
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => Document.fromJson(e)).toList();
  }

  static Future<void> uploadDocument({
    required dynamic fileSource,
    required String category,
    required String version,
  }) async {
    final uri = Uri.parse('http://localhost:8000/api/protocols/upload/');
    final request = http.MultipartRequest('POST', uri)
      ..fields['category'] = category
      ..fields['version'] = version;

    if (kIsWeb) {
      final platformFile = fileSource as PlatformFile;
      final stream = http.ByteStream.fromBytes(platformFile.bytes!);
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        platformFile.size,
        filename: platformFile.name,
      );
      request.files.add(multipartFile);
    } else {
      final file = fileSource as File;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final response = await request.send();
    if (response.statusCode != 202) {
      throw Exception('Erro ao enviar o documento');
    }
  }

  static Future<void> deleteDocument(int id) async {
    final uri = Uri.parse('http://localhost:8000/api/protocols/documents/$id/delete/');
    final response = await http.delete(uri);

    if (response.statusCode != 204) {
      throw Exception('Erro ao remover o documento');
    }
  }
}
