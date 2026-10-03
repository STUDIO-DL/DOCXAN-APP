import 'package:docxan/core/extensions/date_time_x.dart';
import 'package:docxan/core/imaging/compression_profile.dart';
import 'package:docxan/core/imaging/page_processor.dart';
import 'package:docxan/core/imaging/pdf_builder.dart';
import 'package:docxan/core/library/library_ids.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/core/models/document_draft.dart';
import 'package:docxan/core/storage/local_file_store.dart';
import 'package:docxan/core/ocr/ocr_engine.dart';
import 'package:docxan/features/scan/data/ocr_service.dart';
import 'package:docxan/features/scan/presentation/states/scan_session_state.dart';
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
    String? documentName,
    CompressionProfile? profile,
  }) async {
    if (session.pages.isEmpty) {
      throw StateError('empty_session');
    }

    final quality = profile ?? CompressionProfile.balanced;
    final pageJpegs = <Uint8List>[];
    final ocrParts = <String>[];

    for (var i = 0; i < session.pages.length; i++) {
      onProgress?.call('process');
      final jpeg = await compute(
        processScanPageIsolate,
        session.pages[i].toProcessMap(
          maxSide: quality.maxSide,
          maxBytes: quality.maxBytes,
        ),
      );
      pageJpegs.add(jpeg);

      onProgress?.call('ocr');
      var text = '';
      String? ocrPath;
      try {
        ocrPath = await fileStore.writeCacheBytes('ocr_$i.jpg', jpeg);
        text = await ocr.recognize(ocrPath);
      } catch (error) {
        AppLogger.debug('OCR page $i skipped: $error');
      } finally {
        if (ocrPath != null) await fileStore.deleteTempFile(ocrPath);
      }
      ocrParts.add(text);
    }

    onProgress?.call('pdf');
    final pdfBytes = await compute(buildPdfIsolate, pageJpegs);
    final now = DateTime.now();

    return DocumentDraft(
      id: LibraryIds.newId(),
      name: documentName ?? 'Documento ${now.toShortDate()}',
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
