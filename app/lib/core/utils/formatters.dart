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

String formatRelativeTime(DateTime date, [DateTime? now]) {
  final current = now ?? DateTime.now();
  final diff = current.difference(date);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  if (diff.inHours < 48) return 'Ayer';
  return 'Hace ${diff.inDays} d';
}
