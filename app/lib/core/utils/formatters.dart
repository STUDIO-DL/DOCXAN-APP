String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.round()} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}

String greetingFor(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'morning';
  if (hour < 19) return 'afternoon';
  return 'evening';
}
