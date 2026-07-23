import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/book_repository.dart';
import '../data/repositories/transaction_repository.dart';

/// Overridden in `main()` once the instance has been loaded asynchronously, so
/// the rest of the app can read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => BookRepository(),
);

class ActiveBookIdNotifier extends Notifier<String> {
  static const _key = 'active_book_id';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_key) ?? 'default_book_id';
  }

  Future<void> setBookId(String id) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, id);
    state = id;
  }
}

final activeBookIdProvider = NotifierProvider<ActiveBookIdNotifier, String>(
  ActiveBookIdNotifier.new,
);
