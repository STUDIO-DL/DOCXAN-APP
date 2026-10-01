import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/locale/app_locale_controller.dart';
import 'package:docxan/core/locale/app_locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showLanguagePickerSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: DocxanColors.paper,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const LanguageChoiceList(),
            ],
          ),
        ),
      );
    },
  );
}

class LanguageChoiceList extends ConsumerWidget {
  const LanguageChoiceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = Localizations.localeOf(context).languageCode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final code in AppLocales.codes)
          ListTile(
            title: Text(AppLocales.displayName(l10n, code)),
            trailing: selected == code
                ? const Icon(Icons.check, color: DocxanColors.accent)
                : null,
            onTap: () {
              ref.read(appLocaleProvider.notifier).setLocale(code);
              if (context.mounted) Navigator.of(context).maybePop();
            },
          ),
      ],
    );
  }
}

class LanguagePickerButton extends StatelessWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = Localizations.localeOf(context).languageCode;
    return Center(
      child: TextButton.icon(
        onPressed: () => showLanguagePickerSheet(context),
        icon: const Icon(Icons.language),
        label: Text(AppLocales.displayName(l10n, code)),
      ),
    );
  }
}
