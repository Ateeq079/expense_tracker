import 'package:flutter/foundation.dart';

/// A ledger or book for organizing transactions.
@immutable
class Book {
  const Book({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;

  Book copyWith({
    String? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Book.fromMap(Map<String, Object?> map) {
    return Book(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Untitled Book',
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Book &&
      other.id == id &&
      other.name == name &&
      other.sortOrder == sortOrder &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, name, sortOrder, createdAt);
}
