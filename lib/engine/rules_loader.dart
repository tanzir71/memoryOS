import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class AppRuleSpec {
  const AppRuleSpec({required this.appClass, required this.keepPolicy});

  final String appClass;
  final String keepPolicy;
}

class SenderPatternSpec {
  const SenderPatternSpec({required this.kind, required this.regex});

  final String kind;
  final RegExp regex;
}

class SenderPack {
  const SenderPack({
    required this.name,
    required this.verified,
    required this.pkg,
    required this.addressRegex,
    required this.patterns,
  });

  final String name;
  final bool verified;
  final String pkg;
  final RegExp? addressRegex;
  final List<SenderPatternSpec> patterns;
}

class IntentRules {
  const IntentRules({
    required this.asksYou,
    required this.youSaid,
    required this.plan,
    required this.confirms,
  });

  final List<String> asksYou;
  final List<String> youSaid;
  final List<String> plan;
  final List<String> confirms;
}

class PriorSpec {
  const PriorSpec({
    required this.days,
    required this.monthly,
    required this.label,
  });

  final int days;
  final bool monthly;
  final String label;
}

class EngineRules {
  const EngineRules({
    required this.apps,
    required this.intents,
    required this.senders,
    required this.priors,
    required this.headlineConfig,
  });

  final Map<String, AppRuleSpec> apps;
  final IntentRules intents;
  final List<SenderPack> senders;
  final Map<String, PriorSpec> priors;
  final Map<String, dynamic> headlineConfig;

  static const senderPackFiles = [
    'bkash.json',
    'nagad.json',
    'mobile_operator.json',
    'bank_alert.json',
    'utility_bill.json',
    'daraz.json',
    'foodpanda.json',
    'pathao.json',
    'uber.json',
    'courier.json',
  ];

  static Future<EngineRules> loadFromAssets([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    final appsRaw = await b.loadString('assets/rules/apps.json');
    final intentsRaw = await b.loadString('assets/rules/intents.json');
    final priorsRaw = await b.loadString('assets/rules/priors.json');
    final headlineRaw = await b.loadString('assets/rules/headline.json');
    final senderRaws = <String>[];
    for (final file in senderPackFiles) {
      senderRaws.add(await b.loadString('assets/rules/senders/$file'));
    }
    return parse(
      appsRaw: appsRaw,
      intentsRaw: intentsRaw,
      priorsRaw: priorsRaw,
      headlineRaw: headlineRaw,
      senderRaws: senderRaws,
    );
  }

  static EngineRules loadFromDirectory(String rulesDirPath) {
    final appsRaw = File('$rulesDirPath/apps.json').readAsStringSync();
    final intentsRaw = File('$rulesDirPath/intents.json').readAsStringSync();
    final priorsRaw = File('$rulesDirPath/priors.json').readAsStringSync();
    final headlineRaw = File('$rulesDirPath/headline.json').readAsStringSync();
    final senderRaws = senderPackFiles
        .map((f) => File('$rulesDirPath/senders/$f').readAsStringSync())
        .toList();
    return parse(
      appsRaw: appsRaw,
      intentsRaw: intentsRaw,
      priorsRaw: priorsRaw,
      headlineRaw: headlineRaw,
      senderRaws: senderRaws,
    );
  }

  static EngineRules parse({
    required String appsRaw,
    required String intentsRaw,
    required String priorsRaw,
    required String headlineRaw,
    required List<String> senderRaws,
  }) {
    final appsJson = jsonDecode(appsRaw) as Map<String, dynamic>;
    final appsMap = <String, AppRuleSpec>{};
    final rawApps = appsJson['apps'] as Map<String, dynamic>? ?? const {};
    for (final entry in rawApps.entries) {
      final v = entry.value as Map<String, dynamic>;
      appsMap[entry.key] = AppRuleSpec(
        appClass: v['class']?.toString() ?? 'system',
        keepPolicy: v['keep_policy']?.toString() ?? 'default',
      );
    }

    final intentsJson = jsonDecode(intentsRaw) as Map<String, dynamic>;
    List<String> strList(String key) =>
        (intentsJson[key] as List<dynamic>? ?? const [])
            .map((e) => e.toString().toLowerCase())
            .toList();
    final intents = IntentRules(
      asksYou: strList('asks_you'),
      youSaid: strList('you_said'),
      plan: strList('plan'),
      confirms: strList('confirms'),
    );

    final priorsJson = jsonDecode(priorsRaw) as Map<String, dynamic>;
    final rawPriors = priorsJson['priors'] as Map<String, dynamic>? ?? const {};
    final priors = <String, PriorSpec>{};
    for (final entry in rawPriors.entries) {
      final v = entry.value as Map<String, dynamic>;
      priors[entry.key] = PriorSpec(
        days: (v['days'] as num?)?.toInt() ?? 30,
        monthly: v['monthly'] == true,
        label: v['label']?.toString() ?? entry.key,
      );
    }

    final senders = <SenderPack>[];
    for (final raw in senderRaws) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final match = map['match'] as Map<String, dynamic>? ?? const {};
      final addrPattern = match['address']?.toString() ?? '';
      final patterns = <SenderPatternSpec>[];
      for (final p in (map['patterns'] as List<dynamic>? ?? const [])) {
        final pm = p as Map<String, dynamic>;
        patterns.add(
          SenderPatternSpec(
            kind: pm['kind']?.toString() ?? 'other',
            regex: _compileRegex(pm['regex']?.toString() ?? ''),
          ),
        );
      }
      senders.add(
        SenderPack(
          name: map['name']?.toString() ?? 'unknown',
          verified: map['verified'] == true,
          pkg: match['pkg']?.toString() ?? '',
          addressRegex: addrPattern.isNotEmpty ? _compileRegex(addrPattern) : null,
          patterns: patterns,
        ),
      );
    }

    return EngineRules(
      apps: appsMap,
      intents: intents,
      senders: senders,
      priors: priors,
      headlineConfig: jsonDecode(headlineRaw) as Map<String, dynamic>,
    );
  }

  static RegExp _compileRegex(String raw) {
    var pattern = raw;
    var caseSensitive = true;
    if (pattern.startsWith('(?i)')) {
      caseSensitive = false;
      pattern = pattern.substring(4);
    }
    return RegExp(pattern, caseSensitive: caseSensitive);
  }
}
