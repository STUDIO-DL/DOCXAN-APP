extension DateTimeX on DateTime {
  String toShortDate() {
    final dd = day.toString().padLeft(2, '0');
    final mm = month.toString().padLeft(2, '0');
    return '$dd/$mm/$year';
  }
}
