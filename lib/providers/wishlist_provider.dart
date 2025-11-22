import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class WishlistProvider extends ChangeNotifier {
  final BookService _bookService = BookService();

  List<Book> _wishlist = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wishlist = await _bookService.fetchWishlist();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isInWishlist(int bookId) {
    return _wishlist.any((b) => b.id == bookId);
  }

  Future<void> addToWishlist(int bookId) async {
    try {
      await _bookService.addToWishlist(bookId);
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(int bookId) async {
    try {
      await _bookService.removeFromWishlist(bookId);
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(Book book) async {
    if (isInWishlist(book.id)) {
      await removeFromWishlist(book.id);
    } else {
      await addToWishlist(book.id);
    }
  }
}