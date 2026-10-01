class CompressionProfile {
  const CompressionProfile({
    required this.id,
    required this.maxSide,
    required this.maxBytes,
  });

  final String id;
  final int maxSide;
  final int maxBytes;

  static const small = CompressionProfile(
    id: 'small',
    maxSide: 2000,
    maxBytes: 400 * 1024,
  );

  static const balanced = CompressionProfile(
    id: 'balanced',
    maxSide: 2800,
    maxBytes: 800 * 1024,
  );

  static const high = CompressionProfile(
    id: 'high',
    maxSide: 3500,
    maxBytes: 1500 * 1024,
  );

  static const values = [small, balanced, high];

  static CompressionProfile of(String? id) {
    return switch (id) {
      'small' => small,
      'high' => high,
      _ => balanced,
    };
  }
}
