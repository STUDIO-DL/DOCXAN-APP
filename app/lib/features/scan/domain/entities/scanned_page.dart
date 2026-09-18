class ScannedPage {
  const ScannedPage({
    required this.id,
    required this.localPath,
    this.ocrText = '',
  });

  final String id;
  final String localPath;
  final String ocrText;
}
