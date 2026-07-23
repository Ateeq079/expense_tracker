# Project Context

## pubspec.yaml
``text
name: expensetracker
description: "Track income and expenses with category breakdowns, charts and CSV export. Offline, no account needed."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.11.5

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^3.3.2
  sqflite: ^2.4.2+1
  path: ^1.9.1
  path_provider: ^2.1.6
  fl_chart: ^1.2.0
  intl: ^0.20.2
  csv: ^8.0.0
  share_plus: ^13.1.0
  uuid: ^4.5.3
  shared_preferences: ^2.5.5

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.7

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#FAF7F0"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
  remove_alpha_ios: true
  min_sdk_android: 23

flutter_native_splash:
  color: "#2E7D5B"
  color_dark: "#16432E"
  image: assets/icon/splash_logo.png
  android_12:
    color: "#2E7D5B"
    color_dark: "#16432E"
    image: assets/icon/splash_logo.png
  android: true
  ios: true

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package

``

## README.md
``text
# Expense Tracker

A clean, offline expense tracker built with Flutter. Add income and expenses,
see category-wise breakdowns with pie charts, and export everything to CSV. No
account, no login, no network — all data lives on the device.

## Features

- **Add income & expenses** with category, date, optional title and note.
- **Category-wise breakdown** with percentages and entry counts.
- **Pie chart & summaries** per period (This Month / Last Month / This Year / All Time).
- **CSV export** via the system share sheet (UTF‑8 BOM, opens cleanly in Excel/Sheets).
- **Multi-currency display** (USD default; 10 currencies) and light/dark/system theme.
- **Swipe to delete**, edit on tap, and a one-tap "clear all data".
- **100% offline** — SQLite on device, no permissions requested.

## Architecture

```
lib/
  core/            theme, currency model, money/date formatters
  data/
    models/        ExpenseTransaction, Category, TransactionType
    db/            AppDatabase (sqflite + migrations)
    repositories/  TransactionRepository (all SQL lives here)
  state/           Riverpod controllers + pure analytics (summarize)
  services/        CsvExportService
  features/        dashboard, stats, add_edit, settings, home shell, shared widgets
```

- **State management:** Riverpod 3 (`Notifier` / `AsyncNotifier`).
- **Persistence:** sqflite (indexed on date) for transactions; SharedPreferences for settings.
- **Charts:** fl_chart.
- The aggregation logic (`summarize`) is a pure function, unit-tested independently of the UI.

## Getting started

```bash
flutter pub get
flutter run                  # debug on a connected device/emulator
flutter test                 # run the unit + widget test suite
flutter analyze              # static analysis (lints clean)
```

## Building for release / Play Store

### Signing

The release build is signed with an **upload key** at `android/upload-keystore.jks`,
referenced by `android/key.properties`. Both are git-ignored.

> ⚠️ **Before publishing:** the keystore in this repo was generated for local
> builds. Generate your own and keep it (and its passwords) safe — losing the
> upload key means you can't push updates. With **Play App Signing** enabled
> (recommended), Google manages the actual app-signing key and this is your
> upload key.

Regenerate your own:

```bash
keytool -genkeypair -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then update `android/key.properties` with your passwords/alias.

### Build artifacts

```bash
flutter build appbundle --release   # -> build/app/outputs/bundle/release/app-release.aab  (upload this to Play)
flutter build apk --release         # -> build/app/outputs/flutter-apk/app-release.apk     (sideload/testing)
```

The release build enables R8 minification and resource shrinking.

### Bumping the version

Edit `version:` in `pubspec.yaml` (`versionName+versionCode`, e.g. `1.0.1+2`).
The `versionCode` (number after `+`) must increase for every Play upload.

## Regenerating icons / splash

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Play Store checklist

- [x] Unique application ID: `com.ateeq.expensetracker`
- [x] Release signing configured (upload keystore, not debug keys)
- [x] R8 minification + resource shrinking enabled
- [x] Adaptive launcher icon + native splash
- [x] `targetSdk` follows Flutter's latest (meets Play's target-API requirement)
- [x] No runtime permissions requested (offline app)
- [ ] Privacy policy URL — host `PRIVACY_POLICY.md` and link it in the Play listing
- [ ] Store listing: title, short/long description, feature graphic, ≥2 screenshots
- [ ] Complete the **Data safety** form: "No data collected / no data shared"
- [ ] Set content rating and target audience in Play Console

``

## lib\app.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/home/home_shell.dart';
import 'state/settings_controller.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(settingsControllerProvider.select((s) => s.themeMode));
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const HomeShell(),
    );
  }
}

``

## lib\main.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

``

## lib\core\currency.dart
``text
import 'package:flutter/foundation.dart';

/// A supported display currency. The app is fully offline and does no FX
/// conversion — changing the currency only changes the symbol/formatting used
/// to display the numbers the user enters.
@immutable
class Currency {
  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  final String code;
  final String symbol;
  final String name;

  static const List<Currency> supported = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    Currency(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    Currency(code: 'CNY', symbol: 'CN¥', name: 'Chinese Yuan'),
    Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    Currency(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee'),
  ];

  static const Currency fallback =
      Currency(code: 'USD', symbol: '\$', name: 'US Dollar');

  static Currency fromCode(String code) {
    return supported.firstWhere(
      (c) => c.code == code,
      orElse: () => fallback,
    );
  }
}

``

## lib\core\formatters.dart
``text
import 'package:intl/intl.dart';

import 'currency.dart';

/// Formats monetary amounts using the user's selected [Currency].
///
/// Cheap to construct; built fresh whenever the currency changes.
class MoneyFormatter {
  MoneyFormatter(this.currency)
      : _format = NumberFormat.currency(
          symbol: currency.symbol,
          decimalDigits: _decimalDigitsFor(currency.code),
        );

  final Currency currency;
  final NumberFormat _format;

  /// Currencies with no minor unit shouldn't show cents.
  static int _decimalDigitsFor(String code) {
    const zeroDecimal = {'JPY', 'CNY'};
    return zeroDecimal.contains(code) ? 0 : 2;
  }

  String format(double amount) => _format.format(amount);

  /// Signed display, e.g. "+$10.00" / "-$4.50", for transaction rows.
  String formatSigned(double signedAmount) {
    final sign = signedAmount > 0 ? '+' : signedAmount < 0 ? '-' : '';
    return '$sign${_format.format(signedAmount.abs())}';
  }
}

/// Shared date formatting helpers.
class DateFormats {
  DateFormats._();

  static final DateFormat dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat monthYear = DateFormat('MMMM yyyy');
  static final DateFormat weekday = DateFormat('EEE, d MMM');
  static final DateFormat csvTimestamp = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat fileStamp = DateFormat('yyyyMMdd_HHmmss');
}

``

## lib\core\theme.dart
``text
import 'package:flutter/material.dart';

/// App-wide Material 3 theming, seeded from a single brand color so light and
/// dark variants stay consistent.
class AppTheme {
  AppTheme._();

  static const Color seed = Color(0xFF2E7D5B);

  static const Color income = Color(0xFF2E9E5B);
  static const Color expense = Color(0xFFD64545);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

``

## lib\data\db\app_database.dart
``text
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Owns the SQLite connection and schema migrations.
///
/// A single instance is shared app-wide via the repository. Opening is lazy and
/// idempotent.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'expense_tracker.db';
  static const int _dbVersion = 1;

  static const String tableTransactions = 'transactions';

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_transactions_date ON $tableTransactions(date)',
    );
  }

  /// Migration hook. As the schema evolves, branch on [oldVersion] here and
  /// keep [_dbVersion] in sync. Kept intentionally empty at v1.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

``

## lib\data\models\category.dart
``text
import 'package:flutter/material.dart';

import 'transaction_type.dart';

/// A fixed spending/earning category. Categories are predefined (not user
/// editable) so the breakdown and charts stay meaningful and stable across
/// app versions.
@immutable
class Category {
  const Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });

  /// Stable key persisted with each transaction. Never change these strings.
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final TransactionType type;
}

/// Central catalog of categories. Looked up by [id] everywhere else.
class Categories {
  Categories._();

  static const Category _uncategorized = Category(
    id: 'uncategorized',
    label: 'Uncategorized',
    icon: Icons.help_outline,
    color: Color(0xFF9E9E9E),
    type: TransactionType.expense,
  );

  static const List<Category> expense = [
    Category(
      id: 'food',
      label: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFEF5350),
      type: TransactionType.expense,
    ),
    Category(
      id: 'groceries',
      label: 'Groceries',
      icon: Icons.local_grocery_store,
      color: Color(0xFF66BB6A),
      type: TransactionType.expense,
    ),
    Category(
      id: 'transport',
      label: 'Transport',
      icon: Icons.directions_car,
      color: Color(0xFF42A5F5),
      type: TransactionType.expense,
    ),
    Category(
      id: 'shopping',
      label: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFAB47BC),
      type: TransactionType.expense,
    ),
    Category(
      id: 'bills',
      label: 'Bills & Utilities',
      icon: Icons.receipt_long,
      color: Color(0xFFFFA726),
      type: TransactionType.expense,
    ),
    Category(
      id: 'entertainment',
      label: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFEC407A),
      type: TransactionType.expense,
    ),
    Category(
      id: 'health',
      label: 'Health',
      icon: Icons.favorite,
      color: Color(0xFF26A69A),
      type: TransactionType.expense,
    ),
    Category(
      id: 'education',
      label: 'Education',
      icon: Icons.school,
      color: Color(0xFF5C6BC0),
      type: TransactionType.expense,
    ),
    Category(
      id: 'travel',
      label: 'Travel',
      icon: Icons.flight,
      color: Color(0xFF29B6F6),
      type: TransactionType.expense,
    ),
    Category(
      id: 'other_expense',
      label: 'Other',
      icon: Icons.category,
      color: Color(0xFF78909C),
      type: TransactionType.expense,
    ),
  ];

  static const List<Category> income = [
    Category(
      id: 'salary',
      label: 'Salary',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF66BB6A),
      type: TransactionType.income,
    ),
    Category(
      id: 'business',
      label: 'Business',
      icon: Icons.business_center,
      color: Color(0xFF26A69A),
      type: TransactionType.income,
    ),
    Category(
      id: 'investments',
      label: 'Investments',
      icon: Icons.trending_up,
      color: Color(0xFF42A5F5),
      type: TransactionType.income,
    ),
    Category(
      id: 'gifts',
      label: 'Gifts',
      icon: Icons.card_giftcard,
      color: Color(0xFFEC407A),
      type: TransactionType.income,
    ),
    Category(
      id: 'other_income',
      label: 'Other',
      icon: Icons.attach_money,
      color: Color(0xFF78909C),
      type: TransactionType.income,
    ),
  ];

  static List<Category> forType(TransactionType type) =>
      type == TransactionType.income ? income : expense;

  static final Map<String, Category> _byId = {
    for (final c in [...expense, ...income]) c.id: c,
  };

  /// Resolves a category by id, falling back to a safe placeholder so the UI
  /// never crashes on unknown/legacy data.
  static Category byId(String id) => _byId[id] ?? _uncategorized;
}

``

## lib\data\models\expense_transaction.dart
``text
import 'package:flutter/foundation.dart';

import 'transaction_type.dart';

/// A single income or expense entry.
///
/// [amount] is always stored as a positive magnitude; the sign is derived from
/// [type] when computing balances. This keeps validation and display simple.
@immutable
class ExpenseTransaction {
  const ExpenseTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;

  /// Signed contribution to the running balance (income positive, expense
  /// negative).
  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;

  ExpenseTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.storageValue,
      'category': categoryId,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      type: TransactionType.fromStorage(map['type'] as String? ?? 'expense'),
      categoryId: map['category'] as String? ?? 'other_expense',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int? ?? 0),
      note: map['note'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ExpenseTransaction &&
      other.id == id &&
      other.title == title &&
      other.amount == amount &&
      other.type == type &&
      other.categoryId == categoryId &&
      other.date == date &&
      other.note == note;

  @override
  int get hashCode =>
      Object.hash(id, title, amount, type, categoryId, date, note);
}

``

## lib\data\models\transaction_type.dart
``text
/// Whether a transaction adds to (income) or subtracts from (expense) balance.
enum TransactionType {
  income,
  expense;

  String get label => switch (this) {
        TransactionType.income => 'Income',
        TransactionType.expense => 'Expense',
      };

  /// Stable value persisted in the database. Never change these strings.
  String get storageValue => name;

  static TransactionType fromStorage(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}

``

## lib\data\repositories\transaction_repository.dart
``text
import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/expense_transaction.dart';

/// Data-access layer for transactions. All persistence goes through here so the
/// rest of the app never touches SQL directly.
class TransactionRepository {
  TransactionRepository({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// All transactions, newest first.
  Future<List<ExpenseTransaction>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      AppDatabase.tableTransactions,
      orderBy: 'date DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList(growable: false);
  }

  Future<void> add(ExpenseTransaction transaction) async {
    final db = await _db;
    await db.insert(
      AppDatabase.tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(ExpenseTransaction transaction) async {
    final db = await _db;
    await db.update(
      AppDatabase.tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      AppDatabase.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete(AppDatabase.tableTransactions);
  }
}

``

## lib\features\add_edit\add_edit_transaction_screen.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/formatters.dart';
import '../../data/models/category.dart';
import '../../data/models/expense_transaction.dart';
import '../../data/models/transaction_type.dart';
import '../../state/settings_controller.dart';
import '../../state/transactions_controller.dart';

/// Form to create a new transaction or edit an existing one.
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({super.key, this.existing});

  final ExpenseTransaction? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  late String _categoryId;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _type = existing?.type ?? TransactionType.expense;
    _categoryId =
        existing?.categoryId ?? Categories.forType(_type).first.id;
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      // Reset to a valid category for the new type.
      _categoryId = Categories.forType(type).first.id;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amount =
        double.parse(_amountController.text.trim().replaceAll(',', ''));
    final controller = ref.read(transactionsControllerProvider.notifier);
    final existing = widget.existing;

    final transaction = ExpenseTransaction(
      id: existing?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      categoryId: _categoryId,
      date: _date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      if (existing == null) {
        await controller.add(transaction);
      } else {
        await controller.edit(transaction);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyFormatterProvider);
    final categories = Categories.forType(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.south_west),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.north_east),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => _onTypeChanged(s.first),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                autofocus: !widget.isEditing,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${money.currency.symbol} ',
                ),
                validator: _validateAmount,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Category',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categories)
                    ChoiceChip(
                      avatar: Icon(
                        c.icon,
                        size: 18,
                        color: _categoryId == c.id ? null : c.color,
                      ),
                      label: Text(c.label),
                      selected: _categoryId == c.id,
                      onSelected: (_) => setState(() => _categoryId = c.id),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date'),
                subtitle: Text(DateFormats.dayMonthYear.format(_date)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(widget.isEditing ? 'Save changes' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    final text = value?.trim().replaceAll(',', '') ?? '';
    if (text.isEmpty) return 'Enter an amount';
    final parsed = double.tryParse(text);
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than zero';
    if (parsed > 1000000000) return 'Amount is too large';
    return null;
  }
}

``

## lib\features\common\empty_state.dart
``text
import 'package:flutter/material.dart';

/// Friendly placeholder shown when a list has no data yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

``

## lib\features\common\period_selector.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/analytics.dart';

/// Horizontal chip row to pick the active [StatsPeriod].
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPeriodProvider);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: StatsPeriod.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final period = StatsPeriod.values[i];
          return ChoiceChip(
            label: Text(period.label),
            selected: selected == period,
            onSelected: (_) =>
                ref.read(selectedPeriodProvider.notifier).set(period),
          );
        },
      ),
    );
  }
}

``

## lib\features\dashboard\dashboard_screen.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/models/expense_transaction.dart';
import '../../state/analytics.dart';
import '../../state/transactions_controller.dart';
import '../add_edit/add_edit_transaction_screen.dart';
import '../common/empty_state.dart';
import '../common/period_selector.dart';
import '../transactions/transaction_tile.dart';
import 'summary_card.dart';

/// Home tab: balance overview, period filter and the transaction feed.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SummaryCard(),
            const PeriodSelector(),
            const SizedBox(height: 4),
            Expanded(
              child: filtered.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Something went wrong:\n$e')),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const EmptyState(
                      icon: Icons.receipt_long,
                      title: 'No transactions yet',
                      message:
                          'Tap the Add button to record your first income or expense.',
                    );
                  }
                  return _TransactionList(transactions: transactions);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  const _TransactionList({required this.transactions});

  final List<ExpenseTransaction> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by calendar day, preserving the newest-first order.
    final groups = <DateTime, List<ExpenseTransaction>>{};
    for (final t in transactions) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(day, () => []).add(t);
    }
    final days = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final items = groups[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                _dayLabel(day),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            for (final t in items)
              Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.only(right: 24),
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) async {
                  await ref
                      .read(transactionsControllerProvider.notifier)
                      .delete(t.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction deleted')),
                    );
                  }
                },
                child: TransactionTile(
                  transaction: t,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          AddEditTransactionScreen(existing: t),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormats.weekday.format(day);
  }
}

``

## lib\features\dashboard\summary_card.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/analytics.dart';
import '../../state/settings_controller.dart';

/// Top-of-dashboard card showing balance plus income/expense totals for the
/// selected period.
class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final money = ref.watch(moneyFormatterProvider);
    final summary = ref.watch(summaryProvider);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              money.format(summary.balance),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    icon: Icons.south_west,
                    label: 'Income',
                    value: money.format(summary.income),
                    color: AppTheme.income,
                  ),
                ),
                Expanded(
                  child: _Metric(
                    icon: Icons.north_east,
                    label: 'Expense',
                    value: money.format(summary.expense),
                    color: AppTheme.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onContainer = theme.colorScheme.onPrimaryContainer;
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.18),
          foregroundColor: color,
          child: Icon(icon, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onContainer.withValues(alpha: 0.8),
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: onContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

``

## lib\features\home\home_shell.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add_edit/add_edit_transaction_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';

/// Root scaffold with bottom navigation between the three main destinations
/// and a central action to add a transaction.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _pages = [
    DashboardScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  Future<void> _addTransaction() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddEditTransactionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

``

## lib\features\settings\settings_screen.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/currency.dart';
import '../../services/csv_export_service.dart';
import '../../state/settings_controller.dart';
import '../../state/transactions_controller.dart';

/// Settings tab: currency, appearance, data export and reset.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            _sectionHeader(context, 'Preferences'),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Currency'),
              subtitle: Text(
                '${settings.currency.name} (${settings.currency.symbol})',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickCurrency(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Appearance'),
              subtitle: Text(_themeLabel(settings.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickTheme(context, ref),
            ),
            const Divider(height: 32),
            _sectionHeader(context, 'Data'),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('Export as CSV'),
              subtitle: const Text('Share all transactions as a spreadsheet'),
              onTap: () => _exportCsv(context, ref),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              title: Text(
                'Clear all data',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              subtitle: const Text('Permanently delete every transaction'),
              onTap: () => _clearAll(context, ref),
            ),
            const Divider(height: 32),
            _sectionHeader(context, 'About'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              subtitle: Text(_appVersion),
            ),
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Your data stays on this device'),
              subtitle: Text(
                'No account, no tracking. Everything is stored locally.',
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System default',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final current = ref.read(settingsControllerProvider).currency;
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: RadioGroup<Currency>(
            groupValue: current,
            onChanged: (value) => Navigator.pop(context, value),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in Currency.supported)
                  RadioListTile<Currency>(
                    value: c,
                    title: Text(c.name),
                    secondary: Text(
                      c.symbol,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(settingsControllerProvider.notifier).setCurrency(selected);
    }
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final current = ref.read(settingsControllerProvider).themeMode;
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(_themeLabel(mode)),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(settingsControllerProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final transactions =
        ref.read(transactionsControllerProvider).value ?? const [];
    if (transactions.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }
    try {
      await const CsvExportService().exportAndShare(transactions);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This permanently deletes every transaction. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(transactionsControllerProvider.notifier).deleteAll();
      messenger.showSnackBar(
        const SnackBar(content: Text('All transactions deleted')),
      );
    }
  }
}

``

## lib\features\stats\stats_screen.dart
``text
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/models/transaction_type.dart';
import '../../state/analytics.dart';
import '../../state/settings_controller.dart';
import '../common/empty_state.dart';
import '../common/period_selector.dart';

/// Stats tab: category-wise pie chart and breakdown for the selected period.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  TransactionType _view = TransactionType.expense;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(summaryProvider);
    final money = ref.watch(moneyFormatterProvider);

    final isExpense = _view == TransactionType.expense;
    final items =
        isExpense ? summary.expenseByCategory : summary.incomeByCategory;
    final total = isExpense ? summary.expense : summary.income;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SafeArea(
        child: Column(
          children: [
            const PeriodSelector(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expenses'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (s) => setState(() {
                  _view = s.first;
                  _touchedIndex = null;
                }),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? EmptyState(
                      icon: Icons.pie_chart_outline,
                      title: 'Nothing to show',
                      message:
                          'No ${isExpense ? 'expenses' : 'income'} recorded for this period.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      children: [
                        _Chart(
                          items: items,
                          total: total,
                          money: money,
                          touchedIndex: _touchedIndex,
                          onTouch: (i) => setState(() => _touchedIndex = i),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Total  ${money.format(total)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final cs in items)
                          _CategoryRow(summary: cs, money: money),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({
    required this.items,
    required this.total,
    required this.money,
    required this.touchedIndex,
    required this.onTouch,
  });

  final List<CategorySummary> items;
  final double total;
  final MoneyFormatter money;
  final int? touchedIndex;
  final ValueChanged<int?> onTouch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 56,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response?.touchedSection == null) {
                onTouch(null);
                return;
              }
              onTouch(response!.touchedSection!.touchedSectionIndex);
            },
          ),
          sections: [
            for (var i = 0; i < items.length; i++)
              _section(items[i], i == touchedIndex),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(CategorySummary cs, bool touched) {
    final pct = (cs.share * 100);
    return PieChartSectionData(
      value: cs.total,
      color: cs.category.color,
      title: pct >= 6 ? '${pct.toStringAsFixed(0)}%' : '',
      radius: touched ? 72 : 62,
      titleStyle: TextStyle(
        fontSize: touched ? 16 : 13,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: touched
          ? _Badge(icon: cs.category.icon, color: cs.category.color)
          : null,
      badgePositionPercentageOffset: 1.05,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.summary, required this.money});

  final CategorySummary summary;
  final MoneyFormatter money;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = summary.category;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cat.color.withValues(alpha: 0.15),
            foregroundColor: cat.color,
            child: Icon(cat.icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat.label, style: theme.textTheme.titleSmall),
                    Text(
                      money.format(summary.total),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: summary.share.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: cat.color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(cat.color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(summary.share * 100).toStringAsFixed(1)}%  ·  ${summary.count} ${summary.count == 1 ? 'entry' : 'entries'}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

``

## lib\features\transactions\transaction_tile.dart
``text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/category.dart';
import '../../data/models/expense_transaction.dart';
import '../../data/models/transaction_type.dart';
import '../../state/settings_controller.dart';

/// A single row in the transaction list.
class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final ExpenseTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final category = Categories.byId(transaction.categoryId);
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppTheme.income : AppTheme.expense;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: category.color.withValues(alpha: 0.15),
        foregroundColor: category.color,
        child: Icon(category.icon),
      ),
      title: Text(
        transaction.title.isEmpty ? category.label : transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(category.label),
      trailing: Text(
        money.formatSigned(transaction.signedAmount),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

``

## lib\services\csv_export_service.dart
``text
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/formatters.dart';
import '../data/models/category.dart';
import '../data/models/expense_transaction.dart';

/// Builds a CSV of transactions and hands it to the system share sheet.
class CsvExportService {
  const CsvExportService();

  static const _headers = [
    'Date',
    'Type',
    'Category',
    'Title',
    'Amount',
    'Signed Amount',
    'Note',
  ];

  /// Serializes [transactions] (newest first) to CSV text.
  String buildCsv(List<ExpenseTransaction> transactions) {
    final rows = <List<Object?>>[_headers];
    for (final t in transactions) {
      rows.add([
        DateFormats.csvTimestamp.format(t.date),
        t.type.label,
        Categories.byId(t.categoryId).label,
        t.title,
        t.amount.toStringAsFixed(2),
        t.signedAmount.toStringAsFixed(2),
        t.note ?? '',
      ]);
    }
    // BOM so spreadsheet apps render currency symbols / unicode correctly.
    return Csv(addBom: true).encode(rows);
  }

  /// Writes the CSV to a temporary file and opens the share sheet.
  /// Returns the number of transactions exported.
  Future<int> exportAndShare(List<ExpenseTransaction> transactions) async {
    final csv = buildCsv(transactions);
    final dir = await getTemporaryDirectory();
    final stamp = DateFormats.fileStamp.format(DateTime.now());
    final file = File(p.join(dir.path, 'expenses_$stamp.csv'));
    await file.writeAsString(csv, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Expense Tracker export',
        text: 'My transactions exported from Expense Tracker.',
      ),
    );
    return transactions.length;
  }
}

``

## lib\state\analytics.dart
``text
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category.dart';
import '../data/models/expense_transaction.dart';
import '../data/models/transaction_type.dart';
import 'transactions_controller.dart';

/// Time window used to scope the dashboard and stats.
enum StatsPeriod {
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisYear('This Year'),
  all('All Time');

  const StatsPeriod(this.label);
  final String label;

  /// Returns true if [date] falls inside this period, relative to [now].
  bool contains(DateTime date, DateTime now) {
    switch (this) {
      case StatsPeriod.thisMonth:
        return date.year == now.year && date.month == now.month;
      case StatsPeriod.lastMonth:
        final lm = DateTime(now.year, now.month - 1);
        return date.year == lm.year && date.month == lm.month;
      case StatsPeriod.thisYear:
        return date.year == now.year;
      case StatsPeriod.all:
        return true;
    }
  }
}

/// Holds the period the user is currently viewing.
class SelectedPeriodController extends Notifier<StatsPeriod> {
  @override
  StatsPeriod build() => StatsPeriod.thisMonth;

  void set(StatsPeriod period) => state = period;
}

final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodController, StatsPeriod>(
  SelectedPeriodController.new,
);

/// Per-category aggregation within a period.
@immutable
class CategorySummary {
  const CategorySummary({
    required this.category,
    required this.total,
    required this.share,
    required this.count,
  });

  final Category category;
  final double total;

  /// Fraction of the period's total for this category's type, 0..1.
  final double share;
  final int count;
}

/// Rolled-up figures for a period.
@immutable
class FinanceSummary {
  const FinanceSummary({
    required this.income,
    required this.expense,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.transactionCount,
  });

  final double income;
  final double expense;
  final List<CategorySummary> expenseByCategory;
  final List<CategorySummary> incomeByCategory;
  final int transactionCount;

  double get balance => income - expense;

  static const empty = FinanceSummary(
    income: 0,
    expense: 0,
    expenseByCategory: [],
    incomeByCategory: [],
    transactionCount: 0,
  );
}

/// Pure aggregation — broken out from providers so it can be unit-tested.
FinanceSummary summarize(List<ExpenseTransaction> transactions) {
  double income = 0;
  double expense = 0;
  final expenseTotals = <String, double>{};
  final expenseCounts = <String, int>{};
  final incomeTotals = <String, double>{};
  final incomeCounts = <String, int>{};

  for (final t in transactions) {
    if (t.type == TransactionType.income) {
      income += t.amount;
      incomeTotals.update(t.categoryId, (v) => v + t.amount,
          ifAbsent: () => t.amount);
      incomeCounts.update(t.categoryId, (v) => v + 1, ifAbsent: () => 1);
    } else {
      expense += t.amount;
      expenseTotals.update(t.categoryId, (v) => v + t.amount,
          ifAbsent: () => t.amount);
      expenseCounts.update(t.categoryId, (v) => v + 1, ifAbsent: () => 1);
    }
  }

  List<CategorySummary> build(
    Map<String, double> totals,
    Map<String, int> counts,
    double grandTotal,
  ) {
    final list = totals.entries.map((e) {
      return CategorySummary(
        category: Categories.byId(e.key),
        total: e.value,
        share: grandTotal > 0 ? e.value / grandTotal : 0,
        count: counts[e.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return list;
  }

  return FinanceSummary(
    income: income,
    expense: expense,
    expenseByCategory: build(expenseTotals, expenseCounts, expense),
    incomeByCategory: build(incomeTotals, incomeCounts, income),
    transactionCount: transactions.length,
  );
}

/// Transactions filtered to the currently selected period, newest first.
final filteredTransactionsProvider =
    Provider<AsyncValue<List<ExpenseTransaction>>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final async = ref.watch(transactionsControllerProvider);
  final now = DateTime.now();
  return async.whenData(
    (list) => list.where((t) => period.contains(t.date, now)).toList(),
  );
});

/// Summary for the selected period.
final summaryProvider = Provider<FinanceSummary>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  return filtered.maybeWhen(
    data: summarize,
    orElse: () => FinanceSummary.empty,
  );
});

``

## lib\state\providers.dart
``text
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/transaction_repository.dart';

/// Overridden in `main()` once the instance has been loaded asynchronously, so
/// the rest of the app can read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

``

## lib\state\settings_controller.dart
``text
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

``

## lib\state\transactions_controller.dart
``text
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/expense_transaction.dart';
import 'providers.dart';

/// Loads and mutates the full transaction list, keeping the in-memory state in
/// sync with the database. Exposed as an [AsyncValue] so the UI can show
/// loading/error states cleanly.
class TransactionsController
    extends AsyncNotifier<List<ExpenseTransaction>> {
  @override
  Future<List<ExpenseTransaction>> build() {
    return ref.watch(transactionRepositoryProvider).getAll();
  }

  Future<void> _reload() async {
    final repo = ref.read(transactionRepositoryProvider);
    state = await AsyncValue.guard(repo.getAll);
  }

  Future<void> add(ExpenseTransaction transaction) async {
    await ref.read(transactionRepositoryProvider).add(transaction);
    await _reload();
  }

  Future<void> edit(ExpenseTransaction transaction) async {
    await ref.read(transactionRepositoryProvider).update(transaction);
    await _reload();
  }

  Future<void> delete(String id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    await _reload();
  }

  Future<void> deleteAll() async {
    await ref.read(transactionRepositoryProvider).deleteAll();
    await _reload();
  }
}

final transactionsControllerProvider =
    AsyncNotifierProvider<TransactionsController, List<ExpenseTransaction>>(
  TransactionsController.new,
);

``


