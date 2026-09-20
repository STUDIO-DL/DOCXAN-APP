import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class DoxanPinDots extends StatelessWidget {
  const DoxanPinDots({super.key, required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(AppConstants.pinLength, (index) {
        final filled = index < length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? DoxanColors.ink : DoxanColors.hairline,
          ),
        );
      }),
    );
  }
}

class DoxanPinPad extends StatelessWidget {
  const DoxanPinPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final key in keys)
            if (key.isEmpty)
              const SizedBox.shrink()
            else
              TextButton(
                onPressed: () => key == '⌫' ? onBackspace() : onDigit(key),
                child: Text(
                  key,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
        ],
      ),
    );
  }
}
