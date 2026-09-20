import 'package:camera/camera.dart';
import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/imaging/crop_quad.dart';
import 'package:doxan/core/imaging/edge_detect.dart';
import 'package:doxan/core/logging/app_logger.dart';
import 'package:doxan/core/storage/local_file_store.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/features/scan/data/live_edge_detector.dart';
import 'package:doxan/features/scan/presentation/controllers/scan_session_controller.dart';
import 'package:doxan/features/scan/presentation/states/scan_session_state.dart';
import 'package:doxan/features/scan/presentation/widgets/scan_tips_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({super.key});

  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage>
    with WidgetsBindingObserver {
  CameraController? _camera;
  bool _busy = false;
  String? _error;
  bool _showTips = true;
  bool _documentReady = false;
  CropQuad? _liveQuad;
  DateTime _lastDetectAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
    Future<void>.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _showTips = false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopStream();
    _camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      camera.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed) {
      _openCamera();
    }
  }

  Future<void> _openCamera() async {
    setState(() => _error = null);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'empty');
        return;
      }
      final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await _applyFlash(controller, ref.read(scanSessionProvider).flashOn);
      setState(() => _camera = controller);
      await _startStream(controller);
    } catch (error) {
      AppLogger.debug('Camera init failed: $error');
      if (mounted) {
        setState(() => _error = 'denied');
      }
    }
  }

  Future<void> _applyFlash(CameraController controller, bool on) async {
    try {
      await controller.setFlashMode(on ? FlashMode.torch : FlashMode.off);
    } catch (error) {
      AppLogger.debug('Flash unavailable: $error');
    }
  }

  Future<void> _toggleFlash() async {
    final next = !ref.read(scanSessionProvider).flashOn;
    ref.read(scanSessionProvider.notifier).setFlashOn(next);
    final camera = _camera;
    if (camera != null && camera.value.isInitialized) {
      await _applyFlash(camera, next);
    }
  }

  Future<void> _ingest(String path) async {
    final store = ref.read(localFileStoreProvider);
    final persisted = await store.copyToCache(
      path,
      'capture_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    final auto = ref.read(scanSessionProvider).captureMode == CaptureMode.auto;
    final crop = auto ? detectDocumentQuadFromFile(persisted) : CropQuad.inset;
    ref.read(scanSessionProvider.notifier).addPage(persisted, crop: crop);
    if (!mounted) return;
    context.go(AppRoutes.scanEdit);
  }

  Future<void> _startStream(CameraController controller) async {
    if (controller.value.isStreamingImages) return;
    try {
      await controller.startImageStream(_onCameraImage);
    } catch (error) {
      AppLogger.debug('Image stream skipped: $error');
    }
  }

  Future<void> _stopStream() async {
    final camera = _camera;
    if (camera == null || !camera.value.isStreamingImages) return;
    try {
      await camera.stopImageStream();
    } catch (error) {
      AppLogger.debug('Stop stream skipped: $error');
    }
  }

  void _onCameraImage(CameraImage image) {
    if (_busy || !mounted) return;
    final now = DateTime.now();
    if (now.difference(_lastDetectAt) < const Duration(milliseconds: 280)) {
      return;
    }
    _lastDetectAt = now;
    final auto = ref.read(scanSessionProvider).captureMode == CaptureMode.auto;
    if (!auto) {
      if (_documentReady || _liveQuad != null) {
        setState(() {
          _documentReady = false;
          _liveQuad = null;
        });
      }
      return;
    }
    try {
      final quad = detectDocumentQuadFromCamera(image);
      final ready = isDocumentDetected(quad);
      if (ready == _documentReady && _liveQuad == quad) return;
      if (ready && !_documentReady) {
        HapticFeedback.selectionClick();
      }
      setState(() {
        _liveQuad = ready ? quad : null;
        _documentReady = ready;
      });
    } catch (error) {
      AppLogger.debug('Live detect skipped: $error');
    }
  }

  Future<void> _takePicture() async {
    final camera = _camera;
    if (_busy || camera == null || !camera.value.isInitialized) return;
    setState(() => _busy = true);
    try {
      await _stopStream();
      final file = await camera.takePicture();
      await _ingest(file.path);
    } catch (error) {
      AppLogger.debug('Capture failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).cameraUnavailable)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickGallery() async {
    if (_busy) return;
    ref.read(sessionProvider.notifier).ignoreNextLock();
    setState(() => _busy = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (picked == null) return;
      await _ingest(picked.path);
    } catch (error) {
      AppLogger.debug('Gallery failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onAutoTap() {
    ref.read(scanSessionProvider.notifier).setCaptureMode(CaptureMode.auto);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(scanSessionProvider);
    final camera = _camera;
    final ready = camera != null && camera.value.isInitialized;

    return Scaffold(
      backgroundColor: DoxanColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      l10n.scanDocument,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: const Color(0xFFF0F0EC),
                        child: ready
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width:
                                      camera.value.previewSize?.height ?? 3,
                                  height:
                                      camera.value.previewSize?.width ?? 4,
                                  child: CameraPreview(camera),
                                ),
                              )
                            : Center(
                                child: _error == null
                                    ? const CircularProgressIndicator(
                                        color: DoxanColors.accent,
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Text(
                                          _error == 'denied'
                                              ? l10n.cameraPermissionDenied
                                              : l10n.cameraUnavailable,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ),
                      ),
                      CustomPaint(
                        painter: _documentReady
                            ? _DetectedFramePainter(_liveQuad ?? CropQuad.inset)
                            : const _ViewfinderPainter(),
                      ),
                      if (_documentReady)
                        const Align(
                          alignment: Alignment(0, -0.82),
                          child: _DetectedBadge(),
                        ),
                      Align(
                        alignment: const Alignment(0, 0.82),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xCC2A2A2A),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _documentReady
                                ? l10n.documentDetected
                                : l10n.placeDocumentInFrame,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: DoxanColors.paper,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      ScanTipsOverlay(visible: _showTips),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundAction(
                        icon: session.flashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_outlined,
                        label: l10n.flash,
                        selected: session.flashOn,
                        onTap: _toggleFlash,
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: const BoxDecoration(
                            color: DoxanColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.center_focus_strong_outlined,
                            color: DoxanColors.paper,
                            size: 34,
                          ),
                        ),
                      ),
                      _RoundAction(
                        icon: Icons.photo_outlined,
                        label: l10n.gallery,
                        onTap: _pickGallery,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ModeSwitch(
                    autoLabel: l10n.auto,
                    manualLabel: l10n.manual,
                    manual: session.captureMode == CaptureMode.manual,
                    onAuto: _onAutoTap,
                    onManual: () => ref
                        .read(scanSessionProvider.notifier)
                        .setCaptureMode(CaptureMode.manual),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? DoxanColors.accent : DoxanColors.ink,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: DoxanColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.autoLabel,
    required this.manualLabel,
    required this.manual,
    required this.onAuto,
    required this.onManual,
  });

  final String autoLabel;
  final String manualLabel;
  final bool manual;
  final VoidCallback onAuto;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DoxanColors.canvas,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeChip(label: autoLabel, selected: !manual, onTap: onAuto),
          _ModeChip(label: manualLabel, selected: manual, onTap: onManual),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? DoxanColors.paper : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? DoxanColors.ink : DoxanColors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DoxanColors.paper
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const arm = 28.0;
    const inset = 28.0;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(arm, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, arm), paint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-arm, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, arm), paint);
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(arm, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -arm),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-arm, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetectedFramePainter extends CustomPainter {
  const _DetectedFramePainter(this.quad);

  final CropQuad quad;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(quad.tlX * size.width, quad.tlY * size.height)
      ..lineTo(quad.trX * size.width, quad.trY * size.height)
      ..lineTo(quad.brX * size.width, quad.brY * size.height)
      ..lineTo(quad.blX * size.width, quad.blY * size.height)
      ..close();
    final fill = Paint()
      ..color = const Color(0x331B8A4A)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = DoxanColors.accent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _DetectedFramePainter oldDelegate) {
    return oldDelegate.quad != quad;
  }
}

class _DetectedBadge extends StatelessWidget {
  const _DetectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DoxanColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, color: DoxanColors.paper, size: 16),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).documentDetected,
            style: const TextStyle(
              color: DoxanColors.paper,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
