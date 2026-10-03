// #region agent log
import 'dart:convert';
import 'dart:io';

Future<void> agentLog(String hypothesisId, String location, String message, [Map<String, Object?> data = const {}]) async {
  try {
    final req = await HttpClient().postUrl(Uri.parse('http://127.0.0.1:7708/ingest/8630e27d-8b8e-4258-9c68-3238bdf39ea4'));
    req.headers.contentType = ContentType.json;
    req.headers.set('X-Debug-Session-Id', '3f7c4a');
    req.write(jsonEncode({'sessionId': '3f7c4a', 'runId': 'post-fix', 'hypothesisId': hypothesisId, 'location': location, 'message': message, 'data': data, 'timestamp': DateTime.now().millisecondsSinceEpoch}));
    await req.close();
  } catch (_) {}
}
// #endregion
