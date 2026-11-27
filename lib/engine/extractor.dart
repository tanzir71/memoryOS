import 'rules_loader.dart';

class ExtractedEntity {
  const ExtractedEntity({
    required this.type,
    required this.canonicalValue,
    required this.display,
    this.role = 'mention',
  });

  final String type;
  final String canonicalValue;
  final String display;
  final String role;
}

class ExtractionResult {
  const ExtractionResult({
    required this.matchedPack,
    required this.kind,
    required this.fields,
    required this.entities,
    required this.unparsedTransactional,
  });

  final String? matchedPack;
  final String? kind;
  final Map<String, String> fields;
  final List<ExtractedEntity> entities;
  final bool unparsedTransactional;

  double? get amountValue {
    final raw = fields['amount'];
    if (raw == null) return null;
    return double.tryParse(raw.replaceAll(',', ''));
  }

  int? get validDaysValue {
    final raw = fields['valid_days'];
    if (raw == null) return null;
    return int.tryParse(raw);
  }
}

class ExtractionEngine {
  ExtractionEngine(this.rules);

  final EngineRules rules;

  static const _namedGroups = [
    'amount',
    'trx_id',
    'counterparty',
    'balance',
    'due_date',
    'valid_days',
    'valid_until',
    'order_id',
    'tracking_no',
    'merchant',
    'item',
  ];

  static final _moneyFallback = RegExp(
    r'(?:Tk\.?|BDT|৳)\s*(?<amount>[\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  static final _dateSlashFallback = RegExp(
    r'\b(?<date>\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4})\b',
  );
  static final _dateWordFallback = RegExp(
    r'\b(?<date>\d{1,2}\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)[a-z]*(?:\s+\d{4})?)\b',
    caseSensitive: false,
  );
  static final _relativeDateFallback = RegExp(
    r'\b(?<rel>today|tomorrow|kal|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
    caseSensitive: false,
  );
  static final _validDaysFallback = RegExp(
    r'valid\s+for\s+(?<days>\d+)\s+days?',
    caseSensitive: false,
  );
  static final _validUntilFallback = RegExp(
    r'valid\s+(?:till|until)\s+(?<until>\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}|\d{1,2}\s+[A-Za-z]{3,9}(?:\s+\d{4})?)',
    caseSensitive: false,
  );
  static final _orderIdFallback = RegExp(
    r'order\s*(?:#|id|no\.?)?:?\s*(?<id>(?=[A-Z0-9\-]*\d)[A-Z0-9\-]{5,})',
    caseSensitive: false,
  );
  static final _trackingFallback = RegExp(
    r'(?:tracking|parcel|awb)\s*(?:#|id|no\.?)?:?\s*(?<id>(?=[A-Z0-9\-]*\d)[A-Z0-9\-]{5,})',
    caseSensitive: false,
  );
  static final _trxFallback = RegExp(
    r'(?:trxid|txnid|txn\s*id):?\s*(?<id>[A-Z0-9]{8,14})',
    caseSensitive: false,
  );
  static final _balanceFallback = RegExp(
    r'Bal(?:ance)?:?\s*(?:Tk\.?|BDT|৳)\s*(?<balance>[\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  static final _transactionalHint = RegExp(
    r'\b(?:tk\.?|bdt|৳|trxid|txnid|debited|credited|payment|bill|recharge|order|parcel|invoice|balance)\b',
    caseSensitive: false,
  );

  ExtractionResult extract({
    required String pkg,
    required String senderAddress,
    required String title,
    required String body,
    String signalClass = '',
  }) {
    final fullText = '${title.trim()} ${body.trim()}'.trim();
    final fields = <String, String>{};
    String? matchedPack;
    String? matchedKind;

    // 1. Try sender packs first.
    for (final pack in rules.senders) {
      final pkgMatch = pack.pkg.isNotEmpty &&
          pkg.toLowerCase() == pack.pkg.toLowerCase();
      final addrMatch = pack.addressRegex != null &&
          (pack.addressRegex!.hasMatch(senderAddress) ||
              pack.addressRegex!.hasMatch(title));
      if (!pkgMatch && !addrMatch) continue;

      for (final pattern in pack.patterns) {
        final match = pattern.regex.firstMatch(fullText);
        if (match == null) continue;
        matchedPack = pack.name;
        matchedKind = pattern.kind;
        for (final group in _namedGroups) {
          if (match.groupNames.contains(group)) {
            final value = match.namedGroup(group)?.trim();
            if (value != null && value.isNotEmpty) {
              fields[group] = value;
            }
          }
        }
        if (!fields.containsKey('merchant') && _isMerchantPack(pack.name)) {
          fields['merchant'] = _prettyPackName(pack.name);
        }
        break;
      }
      if (matchedPack != null) break;
    }

    // 2. Generic fallbacks fill any missing fields.
    if (!fields.containsKey('amount')) {
      final m = _moneyFallback.firstMatch(fullText);
      if (m != null) fields['amount'] = m.namedGroup('amount')!;
    }
    if (!fields.containsKey('trx_id')) {
      final m = _trxFallback.firstMatch(fullText);
      if (m != null) fields['trx_id'] = m.namedGroup('id')!;
    }
    if (!fields.containsKey('balance')) {
      final m = _balanceFallback.firstMatch(fullText);
      if (m != null) fields['balance'] = m.namedGroup('balance')!;
    }
    if (!fields.containsKey('order_id')) {
      final m = _orderIdFallback.firstMatch(fullText);
      if (m != null) fields['order_id'] = m.namedGroup('id')!;
    }
    if (!fields.containsKey('tracking_no')) {
      final m = _trackingFallback.firstMatch(fullText);
      if (m != null) fields['tracking_no'] = m.namedGroup('id')!;
    }
    if (!fields.containsKey('valid_days')) {
      final m = _validDaysFallback.firstMatch(fullText);
      if (m != null) fields['valid_days'] = m.namedGroup('days')!;
    }
    if (!fields.containsKey('valid_until')) {
      final m = _validUntilFallback.firstMatch(fullText);
      if (m != null) fields['valid_until'] = m.namedGroup('until')!.trim();
    }
    if (!fields.containsKey('due_date')) {
      final slash = _dateSlashFallback.firstMatch(fullText);
      final word = _dateWordFallback.firstMatch(fullText);
      final rel = _relativeDateFallback.firstMatch(fullText);
      if (slash != null) {
        fields['date'] = slash.namedGroup('date')!;
      } else if (word != null) {
        fields['date'] = word.namedGroup('date')!;
      } else if (rel != null) {
        fields['date'] = rel.namedGroup('rel')!;
      }
    }

    // 3. Build normalised entities.
    final entities = <ExtractedEntity>[];
    if (fields['merchant'] != null) {
      entities.add(
        ExtractedEntity(
          type: 'merchant',
          canonicalValue: fields['merchant']!.toLowerCase(),
          display: fields['merchant']!,
        ),
      );
    }
    if (fields['order_id'] != null) {
      entities.add(
        ExtractedEntity(
          type: 'order',
          canonicalValue: fields['order_id']!.toUpperCase(),
          display: '#${fields['order_id']!}',
        ),
      );
    }
    if (fields['tracking_no'] != null) {
      entities.add(
        ExtractedEntity(
          type: 'parcel',
          canonicalValue: fields['tracking_no']!.toUpperCase(),
          display: fields['tracking_no']!,
        ),
      );
    }
    if (fields['trx_id'] != null) {
      entities.add(
        ExtractedEntity(
          type: 'payment',
          canonicalValue: fields['trx_id']!.toUpperCase(),
          display: fields['trx_id']!,
        ),
      );
    }
    if (fields['amount'] != null) {
      final clean = fields['amount']!.replaceAll(',', '');
      entities.add(
        ExtractedEntity(
          type: 'amount',
          canonicalValue: clean,
          display: 'Tk ${fields['amount']!}',
        ),
      );
    }
    if (fields['item'] != null) {
      entities.add(
        ExtractedEntity(
          type: 'topic',
          canonicalValue: fields['item']!.toLowerCase(),
          display: fields['item']!,
        ),
      );
    }

    final looksTransactional = signalClass == 'transaction' ||
        signalClass == 'order' ||
        _transactionalHint.hasMatch(fullText);

    return ExtractionResult(
      matchedPack: matchedPack,
      kind: matchedKind,
      fields: fields,
      entities: entities,
      unparsedTransactional: matchedPack == null && looksTransactional,
    );
  }

  bool _isMerchantPack(String name) => const {
    'daraz',
    'foodpanda',
    'pathao',
    'uber',
  }.contains(name);

  String _prettyPackName(String name) => switch (name) {
    'daraz' => 'Daraz',
    'foodpanda' => 'Foodpanda',
    'pathao' => 'Pathao',
    'uber' => 'Uber',
    _ => name,
  };
}
