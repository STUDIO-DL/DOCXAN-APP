import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/imaging/crop_quad.dart';
import 'package:flutter/material.dart';

class CropOverlay extends StatelessWidget {
  const CropOverlay({
    super.key,
    required this.quad,
    required this.onChanged,
  });

  final CropQuad quad;
  final ValueChanged<CropQuad> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          children: [
            CustomPaint(
              size: size,
              painter: _CropBorderPainter(quad: quad),
            ),
            _Handle(
              left: quad.tlX * size.width,
              top: quad.tlY * size.height,
              onDrag: (delta) {
                onChanged(
                  quad.copyWith(
                    tlX: quad.tlX + delta.dx / size.width,
                    tlY: quad.tlY + delta.dy / size.height,
                  ),
                );
              },
            ),
            _Handle(
              left: quad.trX * size.width,
              top: quad.trY * size.height,
              onDrag: (delta) {
                onChanged(
                  quad.copyWith(
                    trX: quad.trX + delta.dx / size.width,
                    trY: quad.trY + delta.dy / size.height,
                  ),
                );
              },
            ),
            _Handle(
              left: quad.brX * size.width,
              top: quad.brY * size.height,
              onDrag: (delta) {
                onChanged(
                  quad.copyWith(
                    brX: quad.brX + delta.dx / size.width,
                    brY: quad.brY + delta.dy / size.height,
                  ),
                );
              },
            ),
            _Handle(
              left: quad.blX * size.width,
              top: quad.blY * size.height,
              onDrag: (delta) {
                onChanged(
                  quad.copyWith(
                    blX: quad.blX + delta.dx / size.width,
                    blY: quad.blY + delta.dy / size.height,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({
    required this.left,
    required this.top,
    required this.onDrag,
  });

  final double left;
  final double top;
  final ValueChanged<Offset> onDrag;

  @override
  Widget build(BuildContext context) {
    const visual = 14.0;
    const hit = 44.0;
    return Positioned(
      left: left - hit / 2,
      top: top - hit / 2,
      width: hit,
      height: hit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onDrag(details.delta),
        child: Center(
          child: Container(
            width: visual,
            height: visual,
            decoration: BoxDecoration(
              color: DoxanColors.paper,
              shape: BoxShape.circle,
              border: Border.all(color: DoxanColors.accent, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropBorderPainter extends CustomPainter {
  const _CropBorderPainter({required this.quad});

  final CropQuad quad;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(quad.tlX * size.width, quad.tlY * size.height)
      ..lineTo(quad.trX * size.width, quad.trY * size.height)
      ..lineTo(quad.brX * size.width, quad.brY * size.height)
      ..lineTo(quad.blX * size.width, quad.blY * size.height)
      ..close();
    final paint = Paint()
      ..color = DoxanColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CropBorderPainter oldDelegate) {
    return oldDelegate.quad != quad;
  }
}
