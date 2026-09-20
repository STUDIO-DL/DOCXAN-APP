String sanitizeFileName(String name) {
  var cleaned = name.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
  cleaned = cleaned.replaceAll(RegExp(r'_+'), '_');
  cleaned = cleaned.replaceAll(RegExp(r'^[_ ]+|[_ ]+$'), '').trim();
  if (cleaned.isEmpty) return 'documento';
  if (cleaned.length > 80) {
    cleaned = cleaned.substring(0, 80).trim();
  }
  return cleaned;
}

String exportFileName(
  String documentName,
  String extension, {
  int? page,
  int pageCount = 1,
}) {
  final base = sanitizeFileName(documentName);
  final ext = extension.startsWith('.')
      ? extension.substring(1).toLowerCase()
      : extension.toLowerCase();
  if (page != null && pageCount > 1) {
    return '${base}_p$page.$ext';
  }
  return '$base.$ext';
}
