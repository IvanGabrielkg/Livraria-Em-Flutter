import 'package:flutter/material.dart';
import '../models/book.dart';

class CartProvider with ChangeNotifier {
  final List<Book> _items = [];

  List<Book> get items => List.unmodifiable(_items);

  void addBook(Book book) {
    _items.add(book);
    notifyListeners();
  }

  void removeBook(Book book) {
    _items.remove(book);
    notifyListeners();
  }

  double get totalPrice =>
      _items.fold(0, (sum, book) => sum + book.discountedPrice);
}
