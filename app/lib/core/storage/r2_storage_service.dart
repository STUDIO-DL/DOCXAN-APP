import 'dart:convert';

import 'package:docxan/core/errors/app_failure.dart';
import 'package:docxan/core/network/docxan_supabase.dart';
import 'package:docxan/core/network/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Cliente R2 vía URLs prefirmadas. El token S3 nunca viaja en la app.
class R2StorageService {
  R2StorageService({
    required this.signedUrls,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final BackupSignedUrlClient signedUrls;
  final http.Client _http;

  bool get isConfigured => DocxanSupabase.isReady;

  Future<void> uploadDocument({
    required String userId,
    required String documentId,
    required List<int> bytes,
    String backupId = 'current',
  }) async {
    final url = await signedUrls.createUploadUrl(
      userId: userId,
      documentId: documentId,
      backupId: backupId,
    );
    final response = await _http.put(
      url,
      headers: {'Content-Type': 'application/octet-stream'},
      body: bytes,
    );
    if (response.statusCode >= 300) {
      throw StorageFailure(
        'No se pudo subir el backup (${response.statusCode}): '
        '${_r2ErrorCode(response.body)}',
      );
    }
  }

  Future<List<int>> downloadDocument({
    required String userId,
    required String documentId,
    String backupId = 'current',
    String? r2Key,
  }) async {
    final url = await signedUrls.createDownloadUrl(
      r2Key: r2Key ?? objectKey(userId, documentId, backupId),
    );
    final response = await _http.get(url);
    if (response.statusCode >= 300) {
      throw StorageFailure(
        'No se pudo descargar el backup (${response.statusCode}).',
      );
    }
    return response.bodyBytes;
  }

  Future<void> deleteDocument({
    required String userId,
    required String documentId,
    String backupId = 'current',
  }) async {
    final url = await signedUrls.createDeleteUrl(
      r2Key: objectKey(userId, documentId, backupId),
    );
    final response = await _http.delete(url);
    if (response.statusCode >= 300 && response.statusCode != 404) {
      throw StorageFailure(
        'No se pudo borrar el backup (${response.statusCode}).',
      );
    }
  }

  static String objectKey(String userId, String documentId, String backupId) {
    return '$userId/$documentId/$backupId.bin';
  }

  static String _r2ErrorCode(String body) {
    final code = RegExp('<Code>(.*?)</Code>').firstMatch(body)?.group(1);
    final message = RegExp('<Message>(.*?)</Message>').firstMatch(body)?.group(1);
    return [code, message].whereType<String>().join(' - ');
  }
}

class EdgeBackupSignedUrlClient implements BackupSignedUrlClient {
  EdgeBackupSignedUrlClient({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  @override
  Future<Uri> createUploadUrl({
    required String userId,
    required String documentId,
    required String backupId,
  }) {
    return _request(
      action: 'upload',
      documentId: documentId,
      backupId: backupId,
    );
  }

  @override
  Future<Uri> createDownloadUrl({required String r2Key}) {
    return _request(action: 'download', r2Key: r2Key);
  }

  @override
  Future<Uri> createDeleteUrl({required String r2Key}) {
    return _request(action: 'delete', r2Key: r2Key);
  }

  Future<Uri> _request({
    required String action,
    String? documentId,
    String? backupId,
    String? r2Key,
  }) async {
    if (!DocxanSupabase.isReady) {
      throw const StorageFailure(
        'Supabase no está configurado. Añade SUPABASE_URL y SUPABASE_ANON_KEY.',
      );
    }
    final session = DocxanSupabase.client.auth.currentSession;
    if (session == null) {
      throw const AuthFailure('Inicia sesión para sincronizar.');
    }
    final url = Uri.parse(
      '${DocxanSupabase.client.rest.url.replaceAll('/rest/v1', '')}'
      '/functions/v1/backup-signed-url',
    );
    final response = await _http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
        'apikey': DocxanSupabase.client.rest.headers['apikey'] ?? '',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': action,
        'documentId': ?documentId,
        'backupId': ?backupId,
        'r2Key': ?r2Key,
      }),
    );
    if (response.statusCode >= 300) {
      throw StorageFailure(
        'La Edge Function de R2 no está lista (${response.statusCode}).',
      );
    }
    final body = jsonDecode(response.body);
    if (body is! Map || body['url'] is! String) {
      throw const StorageFailure('La Edge Function no devolvió una URL.');
    }
    return Uri.parse(body['url'] as String);
  }
}

final r2StorageServiceProvider = Provider<R2StorageService>((ref) {
  return R2StorageService(signedUrls: EdgeBackupSignedUrlClient());
});
