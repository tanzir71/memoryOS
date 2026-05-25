import 'dart:convert';

enum AppCategory {
  food('Food'),
  grocery('Grocery'),
  fitness('Fitness'),
  messaging('Messaging'),
  email('Email');

  const AppCategory(this.label);

  final String label;

  String get storageKey => name;
}

class AppCategoryRegistry {
  const AppCategoryRegistry({
    Map<AppCategory, Set<String>> userAliases = const {},
    Set<String> deniedAliases = const {},
    Map<AppCategory, Set<String>> disabledDefaultAliases = const {},
    Set<String> disabledDefaultDeniedAliases = const {},
  }) : this._(
         userAliases,
         deniedAliases,
         disabledDefaultAliases,
         disabledDefaultDeniedAliases,
       );

  const AppCategoryRegistry._(
    this._userAliases,
    this._userDeniedAliases,
    this._disabledDefaultAliases,
    this._disabledDefaultDeniedAliases,
  );

  static const settingsKey = 'app_category_registry_overrides';
  static AppCategoryRegistry active = AppCategoryRegistry();
  static const _deniedAliasesStorageKey = 'deniedAliases';
  static const _disabledDefaultAliasesStorageKey = 'disabledDefaultAliases';
  static const _disabledDefaultDeniedAliasesStorageKey =
      'disabledDefaultDeniedAliases';

  final Map<AppCategory, Set<String>> _userAliases;
  final Set<String> _userDeniedAliases;
  final Map<AppCategory, Set<String>> _disabledDefaultAliases;
  final Set<String> _disabledDefaultDeniedAliases;

  List<String> userAliasesFor(AppCategory category) {
    return (_userAliases[category] ?? const <String>{}).toList()..sort();
  }

  List<String> get userDeniedAliases {
    return _userDeniedAliases.toList()..sort();
  }

  List<String> disabledDefaultAliasesFor(AppCategory category) {
    return (_disabledDefaultAliases[category] ?? const <String>{}).toList()
      ..sort();
  }

  List<String> get disabledDefaultDeniedAliases {
    return _disabledDefaultDeniedAliases.toList()..sort();
  }

  List<String> defaultAliasesFor(AppCategory category) {
    return _activeDefaultAliasesFor(category).toList()..sort();
  }

  List<String> get defaultDeniedAliases {
    return _activeDefaultDeniedAliases.toList()..sort();
  }

  Set<String> get deniedAliases {
    return {..._activeDefaultDeniedAliases, ..._userDeniedAliases};
  }

  Set<String> aliasesFor(AppCategory category) {
    return {
      ..._activeDefaultAliasesFor(category),
      ...(_userAliases[category] ?? const <String>{}),
    };
  }

  bool matches(
    AppCategory category, {
    required String packageName,
    String appName = '',
  }) {
    if (isDenied(packageName: packageName, appName: appName)) return false;
    return aliasesFor(category).any(
      (alias) => _matchesAlias(
        alias: alias,
        packageName: packageName,
        appName: appName,
      ),
    );
  }

  AppCategory? firstMatch({
    required String packageName,
    String appName = '',
    List<AppCategory> categories = AppCategory.values,
  }) {
    if (isDenied(packageName: packageName, appName: appName)) return null;
    for (final category in categories) {
      if (matches(category, packageName: packageName, appName: appName)) {
        return category;
      }
    }
    return null;
  }

  bool isDenied({required String packageName, String appName = ''}) {
    return deniedAliases.any(
      (alias) => _matchesAlias(
        alias: alias,
        packageName: packageName,
        appName: appName,
      ),
    );
  }

  bool isUserDenied({required String packageName, String appName = ''}) {
    return _userDeniedAliases.any(
      (alias) => _matchesAlias(
        alias: alias,
        packageName: packageName,
        appName: appName,
      ),
    );
  }

  String displayNameFor({required String packageName, String appName = ''}) {
    final explicit = appName.trim();
    if (explicit.isNotEmpty) return explicit;

    for (final entry in _displayLabels.entries) {
      if (_matchesAlias(
        alias: entry.key,
        packageName: packageName,
        appName: appName,
      )) {
        return entry.value;
      }
    }

    final parts = packageName.split('.').where((part) => part.isNotEmpty);
    return parts.isEmpty ? 'Unknown app' : _titleCase(parts.last);
  }

  String displayLabelForAlias(String alias) {
    final normalized = alias.trim().toLowerCase();
    if (normalized.isEmpty) return '';

    for (final entry in _displayLabels.entries) {
      if (_matchesAlias(
        alias: entry.key,
        packageName: normalized,
        appName: normalized,
      )) {
        return entry.value;
      }
    }

    final words = _normalizeWords(normalized);
    if (words.isEmpty) return alias.trim();
    return words.map(_titleCase).join(' ');
  }

  AppCategoryRegistry copyWithUserAlias(AppCategory category, String alias) {
    final normalized = alias.trim().toLowerCase();
    if (normalized.isEmpty) return this;
    final next = _copyUserAliases();
    final nextDisabled = _copyDisabledDefaultAliases();
    if ((_defaultAliases[category] ?? const <String>{}).contains(normalized)) {
      nextDisabled[category]?.remove(normalized);
      if (nextDisabled[category]?.isEmpty ?? false) {
        nextDisabled.remove(category);
      }
      next[category]?.remove(normalized);
      if (next[category]?.isEmpty ?? false) next.remove(category);
    } else {
      next.putIfAbsent(category, () => <String>{}).add(normalized);
    }
    return AppCategoryRegistry(
      userAliases: next,
      deniedAliases: _userDeniedAliases,
      disabledDefaultAliases: nextDisabled,
      disabledDefaultDeniedAliases: _disabledDefaultDeniedAliases,
    );
  }

  AppCategoryRegistry removeUserAlias(AppCategory category, String alias) {
    final normalized = alias.trim().toLowerCase();
    final next = _copyUserAliases();
    next[category]?.remove(normalized);
    if (next[category]?.isEmpty ?? false) next.remove(category);
    return AppCategoryRegistry(
      userAliases: next,
      deniedAliases: _userDeniedAliases,
      disabledDefaultAliases: _copyDisabledDefaultAliases(),
      disabledDefaultDeniedAliases: _disabledDefaultDeniedAliases,
    );
  }

  AppCategoryRegistry removeAlias(AppCategory category, String alias) {
    final normalized = alias.trim().toLowerCase();
    if (normalized.isEmpty) return this;
    final next = _copyUserAliases();
    final nextDisabled = _copyDisabledDefaultAliases();
    if ((_defaultAliases[category] ?? const <String>{}).contains(normalized)) {
      nextDisabled.putIfAbsent(category, () => <String>{}).add(normalized);
      next[category]?.remove(normalized);
      if (next[category]?.isEmpty ?? false) next.remove(category);
      return AppCategoryRegistry(
        userAliases: next,
        deniedAliases: _userDeniedAliases,
        disabledDefaultAliases: nextDisabled,
        disabledDefaultDeniedAliases: _disabledDefaultDeniedAliases,
      );
    }
    return removeUserAlias(category, alias);
  }

  AppCategoryRegistry copyWithDeniedAlias(String alias) {
    final normalized = alias.trim().toLowerCase();
    if (normalized.isEmpty) return this;
    final nextDenied = {..._userDeniedAliases};
    final nextDisabledDenied = {..._disabledDefaultDeniedAliases};
    if (_defaultDeniedAliases.contains(normalized)) {
      nextDisabledDenied.remove(normalized);
      nextDenied.remove(normalized);
    } else {
      nextDenied.add(normalized);
    }
    return AppCategoryRegistry(
      userAliases: _copyUserAliases(),
      deniedAliases: nextDenied,
      disabledDefaultAliases: _copyDisabledDefaultAliases(),
      disabledDefaultDeniedAliases: nextDisabledDenied,
    );
  }

  AppCategoryRegistry removeDeniedAlias(String alias) {
    final normalized = alias.trim().toLowerCase();
    final nextDenied = {..._userDeniedAliases}..remove(normalized);
    final nextDisabledDenied = {..._disabledDefaultDeniedAliases};
    if (_defaultDeniedAliases.contains(normalized)) {
      nextDisabledDenied.add(normalized);
    }
    return AppCategoryRegistry(
      userAliases: _copyUserAliases(),
      deniedAliases: nextDenied,
      disabledDefaultAliases: _copyDisabledDefaultAliases(),
      disabledDefaultDeniedAliases: nextDisabledDenied,
    );
  }

  AppCategoryRegistry resetUserAliases() {
    return const AppCategoryRegistry();
  }

  Map<String, dynamic> toJson() {
    return {
      for (final entry in _userAliases.entries)
        entry.key.storageKey: (entry.value.toList()..sort()),
      if (_userDeniedAliases.isNotEmpty)
        _deniedAliasesStorageKey: (_userDeniedAliases.toList()..sort()),
      if (_disabledDefaultAliases.isNotEmpty)
        _disabledDefaultAliasesStorageKey: {
          for (final entry in _disabledDefaultAliases.entries)
            entry.key.storageKey: (entry.value.toList()..sort()),
        },
      if (_disabledDefaultDeniedAliases.isNotEmpty)
        _disabledDefaultDeniedAliasesStorageKey:
            (_disabledDefaultDeniedAliases.toList()..sort()),
    };
  }

  String toSettingsValue() => jsonEncode(toJson());

  static AppCategoryRegistry fromSettingsValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const AppCategoryRegistry();
    }
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return AppCategoryRegistry.fromJson(decoded);
      }
    } catch (_) {}
    return const AppCategoryRegistry();
  }

  factory AppCategoryRegistry.fromJson(Map<String, dynamic> json) {
    final aliases = <AppCategory, Set<String>>{};
    for (final category in AppCategory.values) {
      final raw = json[category.storageKey];
      if (raw is List) {
        final values = raw
            .map((value) => value.toString().trim().toLowerCase())
            .where((value) => value.isNotEmpty)
            .toSet();
        if (values.isNotEmpty) aliases[category] = values;
      }
    }

    final rawDeniedAliases = json[_deniedAliasesStorageKey];
    final deniedAliases = rawDeniedAliases is List
        ? rawDeniedAliases
              .map((value) => value.toString().trim().toLowerCase())
              .where((value) => value.isNotEmpty)
              .toSet()
        : <String>{};

    final disabledDefaultAliases = <AppCategory, Set<String>>{};
    final rawDisabledDefaults = json[_disabledDefaultAliasesStorageKey];
    if (rawDisabledDefaults is Map) {
      for (final category in AppCategory.values) {
        final raw = rawDisabledDefaults[category.storageKey];
        if (raw is List) {
          final defaults = _defaultAliases[category] ?? const <String>{};
          final values = raw
              .map((value) => value.toString().trim().toLowerCase())
              .where((value) => value.isNotEmpty && defaults.contains(value))
              .toSet();
          if (values.isNotEmpty) disabledDefaultAliases[category] = values;
        }
      }
    }

    final rawDisabledDefaultDeniedAliases =
        json[_disabledDefaultDeniedAliasesStorageKey];
    final disabledDefaultDeniedAliases = rawDisabledDefaultDeniedAliases is List
        ? rawDisabledDefaultDeniedAliases
              .map((value) => value.toString().trim().toLowerCase())
              .where(
                (value) =>
                    value.isNotEmpty && _defaultDeniedAliases.contains(value),
              )
              .toSet()
        : <String>{};

    return AppCategoryRegistry(
      userAliases: aliases,
      deniedAliases: deniedAliases,
      disabledDefaultAliases: disabledDefaultAliases,
      disabledDefaultDeniedAliases: disabledDefaultDeniedAliases,
    );
  }

  Map<AppCategory, Set<String>> _copyUserAliases() {
    return {
      for (final entry in _userAliases.entries) entry.key: {...entry.value},
    };
  }

  Map<AppCategory, Set<String>> _copyDisabledDefaultAliases() {
    return {
      for (final entry in _disabledDefaultAliases.entries)
        entry.key: {...entry.value},
    };
  }

  Set<String> _activeDefaultAliasesFor(AppCategory category) {
    final defaults = _defaultAliases[category] ?? const <String>{};
    final disabled = _disabledDefaultAliases[category] ?? const <String>{};
    return defaults.difference(disabled);
  }

  Set<String> get _activeDefaultDeniedAliases {
    return _defaultDeniedAliases.difference(_disabledDefaultDeniedAliases);
  }
}

bool _matchesAlias({
  required String alias,
  required String packageName,
  required String appName,
}) {
  final normalizedAlias = alias.trim().toLowerCase();
  if (normalizedAlias.isEmpty) return false;

  final packageLower = packageName.toLowerCase();
  final appLower = appName.toLowerCase();
  if (packageLower == normalizedAlias || appLower == normalizedAlias) {
    return true;
  }
  if (normalizedAlias.contains('.') && packageLower.contains(normalizedAlias)) {
    return true;
  }

  final aliasWords = _normalizeWords(normalizedAlias);
  if (aliasWords.isEmpty) return false;
  return _containsWordPhrase(_normalizeWords(packageLower), aliasWords) ||
      _containsWordPhrase(_normalizeWords(appLower), aliasWords);
}

List<String> _normalizeWords(String value) {
  return value
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((part) => part.isNotEmpty)
      .toList();
}

bool _containsWordPhrase(List<String> words, List<String> phrase) {
  if (phrase.isEmpty || words.length < phrase.length) return false;
  for (var index = 0; index <= words.length - phrase.length; index += 1) {
    final slice = words.sublist(index, index + phrase.length);
    var matches = true;
    for (var offset = 0; offset < phrase.length; offset += 1) {
      if (slice[offset] != phrase[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

const _defaultDeniedAliases = {
  'youtube',
  'com.google.android.youtube',
  'truecaller',
  'com.truecaller',
  'phone',
  'dialer',
  'contacts',
  'com.samsung.android.dialer',
  'com.google.android.dialer',
  'com.android.dialer',
  'systemui',
  'com.android.systemui',
  'android system',
  'battery',
  'battery life',
  'accubattery',
  'com.digibites.accubattery',
};

const _defaultAliases = {
  AppCategory.food: {
    'uber eats',
    'ubereats',
    'com.ubercab.eats',
    'doordash',
    'com.dd.doordash',
    'deliveroo',
    'just eat',
    'takeaway',
    'grubhub',
    'glovo',
    'wolt',
    'talabat',
    'zomato',
    'swiggy',
    'foodpanda',
    'grab',
    'gofood',
    'shopeefood',
    'rappi',
    'ifood',
    'careem food',
    'deliveroo rider',
    'yemeksepeti',
    'bolt food',
    'skip the dishes',
    'menulog',
    'mr d food',
    'pathao food',
    'pathao foods',
    'pathao',
    'com.pathao.food',
    'com.pathao.user',
    'foodi',
    'com.foodi',
    'hungrynaki',
    'hungry naki',
    'com.hungrynaki',
    'pandamart',
    'panda mart',
    'com.foodpanda.pandamart',
    'shohoz food',
    'sohoz food',
    'cookups',
    'hungerstation',
    'jahez',
    'mrsool',
    'the chefz',
    'noon food',
    'elmenus',
    'demae can',
    'demaecan',
    'menu japan',
    'coupang eats',
    'baemin',
    'baedal minjok',
    'yogiyo',
    'meituan',
    'eleme',
    'ele me',
    'jd daojia',
    'didifood',
    'didi food',
    'line man',
    'pickaroo',
    'airasia food',
    'be food',
    'pyszne',
    'lieferando',
    'thuisbezorgd',
    'dame jidlo',
    'efood',
    'box food',
    'foodora',
    'pedidosya',
    'pedidos ya',
    'chowdeck',
    'yassir express',
  },
  AppCategory.grocery: {
    'instacart',
    'walmart grocery',
    'amazon fresh',
    'whole foods',
    'carrefour',
    'tesco',
    'sainsburys',
    'asda',
    'aldi',
    'lidl',
    'kroger',
    'target grocery',
    'bigbasket',
    'blinkit',
    'zepto',
    'dunzo',
    'grofers',
    'freshdirect',
    'coles',
    'woolworths',
    'ocado',
    'migros',
    'rewe',
    'kaufland',
    'jio mart',
    'jumia food',
    'chaldal',
    'com.chaldal.poached',
    'shwapno',
    'swapno',
    'meenaclick',
    'meena click',
    'meena bazaar',
    'daraz mart',
    'daraz',
    'com.daraz.android',
    'pandamart',
    'panda mart',
    'agora',
    'unimart',
    'othoba',
    'pathao shop',
    'swiggy instamart',
    'jiomart',
    'milkbasket',
    'fairprice',
    'redmart',
    'happyfresh',
    'grabmart',
    'coupang',
    'emart',
    'lotte mart',
    'dingdong',
    'freshippo',
    'hema fresh',
    'noon minutes',
    'talabat mart',
    'getir',
    'getirbuyuk',
    'flink',
    'gorillas',
    'picnic',
    'jumbo',
    'rappi turbo',
    'cornershop',
    'mercado libre supermercado',
  },
  AppCategory.fitness: {
    'samsung health',
    'shealth',
    'google fit',
    'fitbit',
    'garmin',
    'strava',
    'nike run club',
    'adidas running',
    'runkeeper',
    'myfitnesspal',
    'oura',
    'whoop',
    'huawei health',
    'mi fitness',
    'xiaomi wear',
    'peloton',
    'zwift',
    'map my run',
    'mapmyrun',
    'endomondo',
    'withings',
    'health mate',
    'polar flow',
    'suunto',
    'cult fit',
    'cult.fit',
    'fit.cure',
    'healthifyme',
    'fittr',
    'fiton',
    'freeletics',
    'sweat',
    'fitbod',
    'jefit',
    'strong workout tracker',
    'seven workout',
    'apple fitness',
    'garmin connect',
    'zepp',
    'amazfit',
    'wellhub',
    'gympass',
    'les mills',
    'komoot',
    'alltrails',
    'trainingpeaks',
    'hevy',
    'classpass',
  },
  AppCategory.messaging: {
    'whatsapp',
    'messenger',
    'facebook orca',
    'com.facebook.orca',
    'instagram',
    'telegram',
    'signal',
    'messages',
    'com.google.android.apps.messaging',
    'com.samsung.android.messaging',
    'google messages',
    'samsung messages',
    'slack',
    'teams',
    'discord',
    'line',
    'wechat',
    'kakaotalk',
    'viber',
    'skype',
    'snapchat',
    'linkedin',
    'reddit',
    'element',
    'matrix',
    'wire',
    'threema',
    'mattermost',
    'zulip',
    'rocket chat',
    'rocket.chat',
    'whatsapp business',
    'imo',
    'com.imo.android.imoim',
    'botim',
    'bip',
    'zalo',
    'google chat',
    'chatwork',
    'workplace chat',
    'wechat work',
    'wecom',
    'dingtalk',
    'ding talk',
    'lark',
    'feishu',
    'qq',
    'vk messenger',
    'tam tam',
    'tamtam',
    'session',
    'briar',
    'jami',
    'band',
    'guilded',
  },
  AppCategory.email: {
    'gmail',
    'com.google.android.gm',
    'outlook',
    'microsoft outlook',
    'yahoo mail',
    'proton mail',
    'protonmail',
    'apple mail',
    'samsung email',
    'spark mail',
    'fastmail',
    'aol mail',
    'zoho mail',
    'hey email',
    'thunderbird',
    'mail.ru',
    'mail ru',
    'ru.mail.mailapp',
    'yandex mail',
    'naver mail',
    'qq mail',
    '163 mail',
    'tutanota',
    'gmx mail',
    'web.de mail',
    'mail.com',
    'icloud mail',
    'k-9 mail',
    'fair email',
    'fairemail',
    'edison mail',
    'blue mail',
    'bluemail',
    'canary mail',
    'newton mail',
  },
};

const _displayLabels = {
  'com.google.android.gm': 'Gmail',
  'gmail': 'Gmail',
  'ru.mail.mailapp': 'Mail.ru',
  'mail.ru': 'Mail.ru',
  'yandex mail': 'Yandex Mail',
  'naver mail': 'Naver Mail',
  'com.slack': 'Slack',
  'slack': 'Slack',
  'com.microsoft.teams': 'Teams',
  'teams': 'Teams',
  'com.whatsapp': 'WhatsApp',
  'whatsapp': 'WhatsApp',
  'whatsapp business': 'WhatsApp Business',
  'com.facebook.orca': 'Messenger',
  'messenger': 'Messenger',
  'com.imo.android.imoim': 'imo',
  'imo': 'imo',
  'botim': 'BOTIM',
  'zalo': 'Zalo',
  'com.discord': 'Discord',
  'discord': 'Discord',
  'telegram': 'Telegram',
  'signal': 'Signal',
  'line': 'LINE',
  'wechat': 'WeChat',
  'kakaotalk': 'KakaoTalk',
  'viber': 'Viber',
  'com.strava': 'Strava',
  'strava': 'Strava',
  'fit.cure': 'Cult.fit',
  'cult fit': 'Cult.fit',
  'cult.fit': 'Cult.fit',
  'healthifyme': 'HealthifyMe',
  'garmin connect': 'Garmin Connect',
  'com.talabat': 'Talabat',
  'talabat': 'Talabat',
  'hungerstation': 'HungerStation',
  'jahez': 'Jahez',
  'coupang eats': 'Coupang Eats',
  'baemin': 'Baemin',
  'yogiyo': 'Yogiyo',
  'meituan': 'Meituan',
  'eleme': 'Ele.me',
  'line man': 'LINE MAN',
  'pedidosya': 'PedidosYa',
  'chowdeck': 'Chowdeck',
  'foodpanda': 'Foodpanda',
  'com.global.foodpanda.android': 'Foodpanda',
  'pathao food': 'Pathao Food',
  'pathao foods': 'Pathao Food',
  'com.pathao.food': 'Pathao Food',
  'foodi': 'Foodi',
  'com.foodi': 'Foodi',
  'hungrynaki': 'HungryNaki',
  'hungry naki': 'HungryNaki',
  'pandamart': 'Pandamart',
  'panda mart': 'Pandamart',
  'instacart': 'Instacart',
  'chaldal': 'Chaldal',
  'com.chaldal.poached': 'Chaldal',
  'shwapno': 'Shwapno',
  'swapno': 'Shwapno',
  'meenaclick': 'MeenaClick',
  'meena click': 'MeenaClick',
  'meena bazaar': 'MeenaClick',
  'daraz mart': 'Daraz Mart',
  'com.daraz.android': 'Daraz Mart',
  'agora': 'Agora',
  'fairprice': 'FairPrice',
  'redmart': 'RedMart',
  'grabmart': 'GrabMart',
  'noon minutes': 'Noon Minutes',
  'rappi turbo': 'Rappi Turbo',
  'zepto': 'Zepto',
};
