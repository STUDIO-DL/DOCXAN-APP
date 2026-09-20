import 'dart:convert';

import 'package:docxan/core/models/library_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryState {
  const LibraryState({
    this.folders = const [],
    this.documents = const [],
  });

  final List<FolderSummary> folders;
  final List<DocumentSummary> documents;

  int get usedBytes =>
      documents.fold(0, (sum, doc) => sum + doc.sizeBytes);

  DocumentSummary? documentById(String id) {
    for (final doc in documents) {
      if (doc.id == id) return doc;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'folders': folders.map((folder) => folder.toJson()).toList(),
    'documents': documents.map((doc) => doc.toJson()).toList(),
  };

  factory LibraryState.fromJson(Map<String, dynamic> json) {
    return LibraryState(
      folders: [
        for (final item in json['folders'] as List<dynamic>? ?? const [])
          FolderSummary.fromJson(item as Map<String, dynamic>),
      ],
      documents: [
        for (final item in json['documents'] as List<dynamic>? ?? const [])
          DocumentSummary.fromJson(item as Map<String, dynamic>),
      ],
    );
  }
}

enum FolderCreateResult { created, emptyName, duplicate }

class LibraryController extends Notifier<LibraryState> {
  static const _storageKey = 'docxan_library_v1';

  @override
  LibraryState build() {
    Future<void>.microtask(_restore);
    return const LibraryState();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    state = LibraryState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  FolderCreateResult createFolder(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) return FolderCreateResult.emptyName;
    final exists = state.folders.any(
      (folder) => folder.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) return FolderCreateResult.duplicate;

    final folder = FolderSummary(
      id: 'folder-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      documentCount: 0,
      updatedAt: DateTime.now(),
    );
    state = LibraryState(
      folders: [folder, ...state.folders],
      documents: state.documents,
    );
    _persist();
    return FolderCreateResult.created;
  }
}

final libraryProvider =
    NotifierProvider<LibraryController, LibraryState>(LibraryController.new);
