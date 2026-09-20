class UserSettings {
  const UserSettings({
    this.compressionProfile = 'balanced',
    this.backupEnabled = false,
    this.updatedAt,
  });

  final String compressionProfile;
  final bool backupEnabled;
  final DateTime? updatedAt;

  UserSettings copyWith({
    String? compressionProfile,
    bool? backupEnabled,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      compressionProfile: compressionProfile ?? this.compressionProfile,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'compression_profile': compressionProfile,
    'backup_enabled': backupEnabled,
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      compressionProfile:
          json['compression_profile'] as String? ??
          json['compressionProfile'] as String? ??
          'balanced',
      backupEnabled:
          json['backup_enabled'] as bool? ??
          json['backupEnabled'] as bool? ??
          false,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}
