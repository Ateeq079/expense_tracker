import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/currency.dart';
import '../core/formatters.dart';
import 'providers.dart';

@immutable
class SettingsState {
  const SettingsState({required this.currency, required this.themeMode});

  final Currency currency;
  final ThemeMode themeMode;

  SettingsState copyWith({Currency? currency, ThemeMode? themeMode}) {
    return SettingsState(
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// Persists user preferences (currency, theme) to [SharedPreferences] and
/// exposes them synchronously to the UI.
class SettingsController extends Notifier<SettingsState> {
  static const _kCurrency = 'pref_currency_code';
  static const _kThemeMode = 'pref_theme_mode';

  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final currency = Currency.fromCode(
      prefs.getString(_kCurrency) ?? Currency.fallback.code,
    );
    final themeMode = _themeModeFromString(prefs.getString(_kThemeMode));
    return SettingsState(currency: currency, themeMode: themeMode);
  }

  Future<void> setCurrency(Currency currency) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kCurrency, currency.code);
    state = state.copyWith(currency: currency);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kThemeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  static ThemeMode _themeModeFromString(String? value) {
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

/// Convenience: the active money formatter, rebuilt when the currency changes.
final moneyFormatterProvider = Provider<MoneyFormatter>((ref) {
  final currency = ref.watch(
    settingsControllerProvider.select((s) => s.currency),
  );
  return MoneyFormatter(currency);
});
