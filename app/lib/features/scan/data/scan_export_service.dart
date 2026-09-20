import 'package:doxan/core/extensions/date_time_x.dart';
import 'package:doxan/core/imaging/page_processor.dart';
import 'package:doxan/core/imaging/pdf_builder.dart';
import 'package:doxan/core/library/library_ids.dart';
import 'package:doxan/core/logging/app_logger.dart';
import 'package:doxan/core/models/document_draft.dart';
import 'package:doxan/core/storage/local_file_store.dart';
import 'package:doxan/core/ocr/ocr_engine.dart';
import 'package:doxan/features/scan/data/ocr_service.dart';
import 'package:doxan/features/scan/presentation/states/scan_session_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SaveProgress = void Function(String phase);

class ScanExportService {
  ScanExportService({
    required this.fileStore,
    this.ocr = const OcrService(),
  });

  final LocalFileStore fileStore;
  final OcrEngine ocr;

  Future<DocumentDraft> export(
    ScanSessionState session, {
    SaveProgress? onProgress,
  }) async {
    if (session.pages.isEmpty) {
      throw StateError('empty_session');
    }

    final pageJpegs = <Uint8List>[];
    final ocrParts = <String>[];

    for (var i = 0; i < session.pages.length; i++) {
      onProgress?.call('process');
      final jpeg = await compute(
        processScanPageIsolate,
        session.pages[i].toProcessMap(),
      );
      pageJpegs.add(jpeg);

      onProgress?.call('ocr');
      var text = '';
      try {
        final ocrPath = await fileStore.writeCacheBytes('ocr_$i.jpg', jpeg);
        text = await ocr.recognize(ocrPath);
      } catch (error) {
        AppLogger.debug('OCR page $i skipped: $error');
      }
      ocrParts.add(text);
    }

    onProgress?.call('pdf');
    final pdfBytes = await compute(buildPdfIsolate, pageJpegs);
    final now = DateTime.now();

    return DocumentDraft(
      id: LibraryIds.newId(),
      name: 'Documento ${now.toShortDate()}',
      pdfBytes: pdfBytes,
      previewJpeg: pageJpegs.first,
      ocrText: ocrParts.where((part) => part.trim().isNotEmpty).join('\n\n'),
      pageCount: pageJpegs.length,
      pageJpegs: pageJpegs,
    );
  }
}

final scanExportProvider = Provider<ScanExportService>((ref) {
  return ScanExportService(
    fileStore: ref.watch(localFileStoreProvider),
    ocr: ref.watch(ocrEngineProvider),
  );
});
