import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookProvider extends ChangeNotifier {
  final BookService _bookService = BookService();

  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _bookService.fetchBooks();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadBooksByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _bookService.fetchBooksByCategory(category);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}