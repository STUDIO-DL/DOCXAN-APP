import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/models/library_models.dart';
import 'package:docxan/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class DocxanDocumentTile extends StatelessWidget {
  const DocxanDocumentTile({
    super.key,
    required this.document,
    required this.onTap,
  });

  final DocumentSummary document;
  final VoidCallback onTap;

  IconData get _icon {
    switch (document.format.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'DOCX':
      case 'DOC':
        return Icons.description_rounded;
      default:
        return Icons.image_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tint = DocxanColors.forFormat(document.format);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: tint, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${document.format} · ${formatBytes(document.sizeBytes)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              formatRelativeTime(
                document.updatedAt,
                l10n: AppLocalizations.of(context),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.more_vert, color: DocxanColors.inkMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class DocxanFolderCard extends StatelessWidget {
  const DocxanFolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    this.compact = false,
  });

  final FolderSummary folder;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = DocxanColors.forFolder(folder.id);
    if (compact) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              Icon(Icons.folder_rounded, color: color, size: 36),
              const SizedBox(height: 6),
              Text(
                folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                '${folder.documentCount} docs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DocxanColors.canvas,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.folder_rounded, color: color, size: 32),
            const Spacer(),
            Text(
              folder.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${folder.documentCount} documentos',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class DocxanAppHeader extends StatelessWidget {
  const DocxanAppHeader({super.key, required this.title, this.showBrand = false});

  final String title;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBrand) ...[
          const Icon(Icons.document_scanner_outlined, size: 22),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: showBrand ? 22 : 28,
            ),
          ),
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: DocxanColors.chip,
          child: const Icon(
            Icons.person_outline,
            size: 20,
            color: DocxanColors.ink,
          ),
        ),
      ],
    );
  }
}

class DocxanSectionHeader extends StatelessWidget {
  const DocxanSectionHeader({
    super.key,
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            action,
            style: const TextStyle(
              color: DocxanColors.inkMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
