class SavedFolder {
  const SavedFolder({
    required this.id,
    required this.name,
    required this.updatedAt,
    this.isDefault = false,
    this.iconKey = 'folder',
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final bool isDefault;
  final String iconKey;

  SavedFolder copyWith({
    String? id,
    String? name,
    DateTime? updatedAt,
    bool? isDefault,
    String? iconKey,
  }) {
    return SavedFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      iconKey: iconKey ?? this.iconKey,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'isDefault': isDefault,
    'iconKey': iconKey,
  };

  factory SavedFolder.fromJson(Map<String, dynamic> json) {
    return SavedFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      isDefault: json['isDefault'] as bool? ?? false,
      iconKey: json['iconKey'] as String? ?? 'folder',
    );
  }
}
