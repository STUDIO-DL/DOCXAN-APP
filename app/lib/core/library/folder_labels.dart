import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/core/library/library_collections.dart';
import 'package:docxan/core/models/saved_folder.dart';

String localizedFolderName(
  AppLocalizations l10n, {
  required String? folderId,
  String? storedName,
}) {
  if (folderId == null || folderId.isEmpty) return l10n.myFiles;
  final key = DefaultFolders.iconKeyFor(folderId);
  return switch (key) {
    'personal' => l10n.folderPersonal,
    'universidad' => l10n.folderUniversity,
    'trabajo' => l10n.folderWork,
    'otros' => l10n.otherFolder,
    _ => storedName ?? l10n.myFiles,
  };
}

String localizedSavedFolderName(AppLocalizations l10n, SavedFolder folder) {
  return localizedFolderName(
    l10n,
    folderId: folder.id,
    storedName: folder.name,
  );
}
