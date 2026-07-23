import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/books_controller.dart';
import '../../state/providers.dart';

class BookSwitcherSheet extends ConsumerWidget {
  const BookSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksControllerProvider);
    final activeBookId = ref.watch(activeBookIdProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Books',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () => _showAddBookDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Book'),
                ),
              ],
            ),
          ),
          const Divider(),
          booksAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (books) {
              if (books.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No books available.')),
                );
              }
              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final isActive = book.id == activeBookId;
                    return ListTile(
                      leading: Icon(
                        isActive ? Icons.book : Icons.book_outlined,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(
                        book.name,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showRenameBookDialog(context, ref, book.id, book.name),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: books.length > 1
                                ? () => _confirmDeleteBook(context, ref, book.id, book.name)
                                : null, // Disable delete if it's the last book
                          ),
                        ],
                      ),
                      onTap: () {
                        ref.read(activeBookIdProvider.notifier).setBookId(book.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBookDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Book'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Book Name',
            hintText: 'e.g., Personal, Business',
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(booksControllerProvider.notifier).add(result);
    }
  }

  Future<void> _showRenameBookDialog(
      BuildContext context, WidgetRef ref, String id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Book'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Book Name',
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty &&
                  controller.text.trim() != currentName) {
                Navigator.pop(context, controller.text.trim());
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(booksControllerProvider.notifier).rename(id, result);
    }
  }

  Future<void> _confirmDeleteBook(
      BuildContext context, WidgetRef ref, String id, String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text(
            'Are you sure you want to delete this book? All transactions in this book will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(booksControllerProvider.notifier).delete(id);
    }
  }
}
