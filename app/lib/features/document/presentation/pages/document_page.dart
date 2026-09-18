import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/demo/demo_catalog.dart';
import 'package:doxan/core/extensions/date_time_x.dart';
import 'package:doxan/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class DocumentPage extends StatelessWidget {
  const DocumentPage({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doc = DemoCatalog.documentById(documentId);
    if (doc == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Documento no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(doc.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: DoxanColors.paper,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DoxanColors.hairline),
              ),
              child: const Center(
                child: Icon(Icons.description_outlined, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('${doc.format} · ${formatBytes(doc.sizeBytes)}'),
          Text('${doc.folderName} · ${doc.updatedAt.toShortDate()}'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(label: Text(l10n.share), onPressed: () {}),
              ActionChip(label: Text(l10n.export), onPressed: () {}),
              ActionChip(label: Text(l10n.move), onPressed: () {}),
              ActionChip(label: Text(l10n.rename), onPressed: () {}),
              ActionChip(label: Text(l10n.delete), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.ocrText, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(doc.ocrText, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
