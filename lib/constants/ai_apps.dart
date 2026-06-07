/// Curated list of AI apps the user can choose to put behind the pause screen.
///
/// Package names verified against the Play Store at build time (June 2026):
///  - ChatGPT   com.openai.chatgpt
///  - Claude    com.anthropic.claude
///  - Gemini    com.google.android.apps.bard   (still the "bard" package post-rebrand)
///  - Perplexity ai.perplexity.app.android
///  - Copilot   com.microsoft.copilot
///
/// Keep this list in one place so it is easy to extend. The Settings screen
/// installed-checks each entry via [NativeBridge.queryInstalledAiApps].
class AiApp {
  const AiApp({required this.name, required this.packageName});

  final String name;
  final String packageName;
}

const List<AiApp> kCuratedAiApps = <AiApp>[
  AiApp(name: 'ChatGPT', packageName: 'com.openai.chatgpt'),
  AiApp(name: 'Claude', packageName: 'com.anthropic.claude'),
  AiApp(name: 'Gemini', packageName: 'com.google.android.apps.bard'),
  AiApp(name: 'Perplexity', packageName: 'ai.perplexity.app.android'),
  AiApp(name: 'Copilot', packageName: 'com.microsoft.copilot'),
];

/// Human-readable name for a package, falling back to the raw id.
String displayNameForPackage(String packageName) {
  for (final app in kCuratedAiApps) {
    if (app.packageName == packageName) return app.name;
  }
  return packageName;
}
