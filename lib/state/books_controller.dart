import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/book.dart';
import 'providers.dart';

class BooksController extends AsyncNotifier<List<Book>> {
  static const _uuid = Uuid();

  @override
  Future<List<Book>> build() {
    return ref.watch(bookRepositoryProvider).getAll();
  }

  Future<void> _reload() async {
    final repo = ref.read(bookRepositoryProvider);
    state = await AsyncValue.guard(repo.getAll);
  }

  Future<void> add(String name) async {
    final List<Book> books = state.value ?? <Book>[];
    final maxSortOrder = books.isEmpty 
        ? 0 
        : books.map((b) => b.sortOrder).reduce((a, b) => a > b ? a : b);

    final book = Book(
      id: _uuid.v4(),
      name: name,
      sortOrder: maxSortOrder + 1,
      createdAt: DateTime.now(),
    );
    await ref.read(bookRepositoryProvider).add(book);
    await ref.read(activeBookIdProvider.notifier).setBookId(book.id);
    await _reload();
  }

  Future<void> rename(String id, String newName) async {
    final List<Book> books = state.value ?? <Book>[];
    final book = books.firstWhere((b) => b.id == id);
    final updated = book.copyWith(name: newName);
    
    await ref.read(bookRepositoryProvider).update(updated);
    await _reload();
  }

  Future<void> delete(String id) async {
    await ref.read(bookRepositoryProvider).delete(id);
    
    // If we deleted the active book, switch to another one
    final activeBookId = ref.read(activeBookIdProvider);
    if (activeBookId == id) {
      await _reload();
      final List<Book> books = state.value ?? <Book>[];
      if (books.isNotEmpty) {
        await ref.read(activeBookIdProvider.notifier).setBookId(books.first.id);
      }
    } else {
      await _reload();
    }
  }
}

final booksControllerProvider =
    AsyncNotifierProvider<BooksController, List<Book>>(
  BooksController.new,
);
