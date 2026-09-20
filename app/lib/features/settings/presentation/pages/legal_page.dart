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
    final asset = isPrivacy
        ? 'assets/legal/privacy.md'
        : 'assets/legal/terms.md';

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
