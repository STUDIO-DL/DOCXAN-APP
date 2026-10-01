import 'package:docxan/app/l10n/app_localizations.dart';

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

String formatRelativeTime(
  DateTime date, {
  DateTime? now,
  required AppLocalizations l10n,
}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(date);
  if (diff.inMinutes < 1) return l10n.relativeNow;
  if (diff.inMinutes < 60) return l10n.relativeMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.relativeHours(diff.inHours);
  if (diff.inHours < 48) return l10n.relativeYesterday;
  return l10n.relativeDays(diff.inDays);
}
