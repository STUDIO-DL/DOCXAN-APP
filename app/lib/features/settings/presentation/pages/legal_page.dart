import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.kind});

  final String kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPrivacy = kind != 'terms';
    final title = isPrivacy ? l10n.privacyPolicy : l10n.termsOfUse;
    final languageCode = Localizations.localeOf(context).languageCode;
    final asset = legalMarkdownAsset(
      kind: kind,
      languageCode: languageCode,
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(asset),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SelectableText(snapshot.data!),
          );
        },
      ),
    );
  }
}

String legalMarkdownAsset({
  required String kind,
  required String languageCode,
}) {
  final base = kind == 'terms' ? 'terms' : 'privacy';
  return switch (languageCode) {
    'en' => 'assets/legal/${base}_en.md',
    'fr' => 'assets/legal/${base}_fr.md',
    _ => 'assets/legal/$base.md',
  };
}
