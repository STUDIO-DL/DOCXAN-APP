import 'dart:io';
import 'dart:typed_data';

/// Smoke test de R2 con URLs prefirmadas (sin token S3 en el cliente).
///
/// dart run tool/r2_smoke_test.dart --put-url URL --get-url URL
Future<void> main(List<String> args) async {
  String? putUrl;
  String? getUrl;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--put-url' && i + 1 < args.length) putUrl = args[++i];
    if (args[i] == '--get-url' && i + 1 < args.length) getUrl = args[++i];
  }

  if (putUrl == null || getUrl == null) {
    stderr.writeln(
      'Uso: dart run tool/r2_smoke_test.dart --put-url URL --get-url URL',
    );
    stderr.writeln(
      'Crea primero la cuenta Cloudflare y la Edge Function backup-signed-url.',
    );
    exit(64);
  }

  final payload = Uint8List.fromList(List<int>.generate(32, (i) => i));
  final client = HttpClient();

  final put = await client.putUrl(Uri.parse(putUrl));
  put.headers.contentType = ContentType.binary;
  put.add(payload);
  final putResponse = await put.close();
  if (putResponse.statusCode < 200 || putResponse.statusCode >= 300) {
    stderr.writeln('PUT falló: ${putResponse.statusCode}');
    exit(1);
  }

  final get = await client.getUrl(Uri.parse(getUrl));
  final getResponse = await get.close();
  final bytes = await getResponse.fold<List<int>>(<int>[], (p, e) => p..addAll(e));
  client.close(force: true);

  if (bytes.length != payload.length) {
    stderr.writeln('GET tamaño inesperado: ${bytes.length}');
    exit(1);
  }
  stdout.writeln('R2 OK: ${bytes.length} bytes ida y vuelta');
}
