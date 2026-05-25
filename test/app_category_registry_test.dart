import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/app_category_registry.dart';

void main() {
  test(
    'default registry recognizes global health and messaging app families',
    () {
      const registry = AppCategoryRegistry();

      expect(
        registry.matches(
          AppCategory.food,
          packageName: 'com.talabat',
          appName: 'Talabat',
        ),
        isTrue,
      );
      expect(
        registry.matches(
          AppCategory.grocery,
          packageName: 'com.zepto.customer',
          appName: 'Zepto',
        ),
        isTrue,
      );
      expect(
        registry.matches(
          AppCategory.fitness,
          packageName: 'com.strava',
          appName: 'Strava',
        ),
        isTrue,
      );
      expect(
        registry.matches(
          AppCategory.messaging,
          packageName: 'com.slack',
          appName: 'Slack',
        ),
        isTrue,
      );
      expect(
        registry.matches(
          AppCategory.email,
          packageName: 'com.google.android.gm',
          appName: 'Gmail',
        ),
        isTrue,
      );
    },
  );

  test('default registry includes Bangladesh food and grocery apps', () {
    const registry = AppCategoryRegistry();

    final foodApps = {
      'Foodpanda': 'com.global.foodpanda.android',
      'Pathao Food': 'com.pathao.food',
      'Foodi': 'com.foodi.customer',
      'HungryNaki': 'com.hungrynaki.customer',
      'Pandamart': 'com.foodpanda.pandamart',
    };
    for (final entry in foodApps.entries) {
      expect(
        registry.matches(
          AppCategory.food,
          packageName: entry.value,
          appName: entry.key,
        ),
        isTrue,
        reason: entry.key,
      );
    }

    final groceryApps = {
      'Chaldal': 'com.chaldal.poached',
      'Shwapno': 'com.shwapno',
      'MeenaClick': 'com.meenaclick.app',
      'Daraz Mart': 'com.daraz.android',
      'Agora': 'com.agora.app',
    };
    for (final entry in groceryApps.entries) {
      expect(
        registry.matches(
          AppCategory.grocery,
          packageName: entry.value,
          appName: entry.key,
        ),
        isTrue,
        reason: entry.key,
      );
    }
  });

  test('default registry includes representative regional market apps', () {
    const registry = AppCategoryRegistry();

    expect(
      registry.matches(
        AppCategory.food,
        packageName: 'com.hungerstation.android.web',
        appName: 'HungerStation',
      ),
      isTrue,
    );
    expect(
      registry.matches(
        AppCategory.food,
        packageName: 'com.coupang.mobile.eats',
        appName: 'Coupang Eats',
      ),
      isTrue,
    );
    expect(
      registry.matches(
        AppCategory.food,
        packageName: 'com.mcdo.mcdelivery',
        appName: 'PedidosYa',
      ),
      isTrue,
    );
    expect(
      registry.matches(
        AppCategory.grocery,
        packageName: 'com.fairprice.mcomapp',
        appName: 'FairPrice',
      ),
      isTrue,
    );
    expect(
      registry.matches(
        AppCategory.fitness,
        packageName: 'fit.cure.android',
        appName: 'Cult.fit',
      ),
      isTrue,
    );
    expect(
      registry.matches(
        AppCategory.messaging,
        packageName: 'com.imo.android.imoim',
        appName: 'imo',
      ),
      isTrue,
    );
    expect(
      registry.matches(
        AppCategory.email,
        packageName: 'ru.mail.mailapp',
        appName: 'Mail.ru',
      ),
      isTrue,
    );
  });

  test(
    'displayLabelForAlias returns canonical labels for registry aliases',
    () {
      const registry = AppCategoryRegistry();

      expect(registry.displayLabelForAlias('com.pathao.food'), 'Pathao Food');
      expect(registry.displayLabelForAlias('chaldal'), 'Chaldal');
      expect(
        registry.displayLabelForAlias('com.global.foodpanda.android'),
        'Foodpanda',
      );
    },
  );

  test('default registry blocks common non-health notification surfaces', () {
    const registry = AppCategoryRegistry();

    for (final packageName in const [
      'com.google.android.youtube',
      'com.truecaller',
      'com.samsung.android.dialer',
      'com.android.systemui',
      'com.digibites.accubattery',
    ]) {
      expect(
        registry.isDenied(packageName: packageName),
        isTrue,
        reason: packageName,
      );
    }
  });

  test('user aliases merge with defaults and can be serialized', () {
    final registry = const AppCategoryRegistry().copyWithUserAlias(
      AppCategory.food,
      'com.local.tiffinbox',
    );

    expect(
      registry.matches(AppCategory.food, packageName: 'com.local.tiffinbox'),
      isTrue,
    );

    final restored = AppCategoryRegistry.fromJson(registry.toJson());
    expect(
      restored.matches(AppCategory.food, packageName: 'com.local.tiffinbox'),
      isTrue,
    );
  });

  test('user deny aliases override category matches and persist', () {
    final registry = const AppCategoryRegistry()
        .copyWithUserAlias(AppCategory.messaging, 'com.local.chat')
        .copyWithDeniedAlias('com.local.chat');

    expect(
      registry.isDenied(packageName: 'com.local.chat', appName: 'Local Chat'),
      isTrue,
    );
    expect(
      registry.matches(
        AppCategory.messaging,
        packageName: 'com.local.chat',
        appName: 'Local Chat',
      ),
      isFalse,
    );
    expect(registry.userDeniedAliases, ['com.local.chat']);

    final restored = AppCategoryRegistry.fromJson(registry.toJson());
    expect(
      restored.isDenied(packageName: 'com.local.chat', appName: 'Local Chat'),
      isTrue,
    );
    expect(restored.userDeniedAliases, ['com.local.chat']);
  });

  test(
    'reset clears user aliases and user deny aliases but keeps defaults',
    () {
      final registry = const AppCategoryRegistry()
          .copyWithUserAlias(AppCategory.food, 'com.local.tiffinbox')
          .copyWithDeniedAlias('com.local.chat')
          .resetUserAliases();

      expect(registry.userAliasesFor(AppCategory.food), isEmpty);
      expect(registry.userDeniedAliases, isEmpty);
      expect(registry.isDenied(packageName: 'com.local.chat'), isFalse);
      expect(
        registry.isDenied(packageName: 'com.google.android.youtube'),
        isTrue,
      );
    },
  );

  test('removing a default category alias disables matching', () {
    final registry = const AppCategoryRegistry().removeAlias(
      AppCategory.food,
      'talabat',
    );

    expect(registry.aliasesFor(AppCategory.food), isNot(contains('talabat')));
    expect(
      registry.defaultAliasesFor(AppCategory.food),
      isNot(contains('talabat')),
    );
    expect(registry.disabledDefaultAliasesFor(AppCategory.food), ['talabat']);
    expect(
      registry.matches(
        AppCategory.food,
        packageName: 'com.talabat',
        appName: 'Talabat',
      ),
      isFalse,
    );
  });

  test('disabled default category aliases serialize and restore', () {
    final registry = const AppCategoryRegistry().removeAlias(
      AppCategory.food,
      'talabat',
    );

    final restored = AppCategoryRegistry.fromJson(registry.toJson());

    expect(restored.aliasesFor(AppCategory.food), isNot(contains('talabat')));
    expect(restored.disabledDefaultAliasesFor(AppCategory.food), ['talabat']);
  });

  test(
    'adding a disabled default restores it instead of duplicating custom aliases',
    () {
      final registry = const AppCategoryRegistry()
          .removeAlias(AppCategory.food, 'talabat')
          .copyWithUserAlias(AppCategory.food, 'talabat');

      expect(registry.disabledDefaultAliasesFor(AppCategory.food), isEmpty);
      expect(registry.userAliasesFor(AppCategory.food), isEmpty);
      expect(registry.aliasesFor(AppCategory.food), contains('talabat'));
    },
  );

  test("removing a default Don't Log alias disables the built-in block", () {
    final registry = const AppCategoryRegistry().removeDeniedAlias('youtube');

    expect(registry.deniedAliases, isNot(contains('youtube')));
    expect(registry.disabledDefaultDeniedAliases, ['youtube']);
    expect(registry.isDenied(packageName: 'youtube'), isFalse);
  });

  test('reset restores disabled defaults and clears custom aliases', () {
    final registry = const AppCategoryRegistry()
        .removeAlias(AppCategory.food, 'talabat')
        .removeDeniedAlias('youtube')
        .copyWithUserAlias(AppCategory.food, 'com.local.tiffinbox')
        .copyWithDeniedAlias('com.local.noisy')
        .resetUserAliases();

    expect(registry.disabledDefaultAliasesFor(AppCategory.food), isEmpty);
    expect(registry.disabledDefaultDeniedAliases, isEmpty);
    expect(registry.userAliasesFor(AppCategory.food), isEmpty);
    expect(registry.userDeniedAliases, isEmpty);
    expect(registry.aliasesFor(AppCategory.food), contains('talabat'));
    expect(registry.deniedAliases, contains('youtube'));
  });
}
