import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class BookService {

  static String resolveBaseUrl() {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      }
      return 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  static final String baseUrl = resolveBaseUrl();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Book>> fetchBooks() async {
    final uri = Uri.parse('$baseUrl/books');
    final response = await http
        .get(uri, headers: _headers(token: await _getToken()))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Book.fromJson(e)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Falha ao carregar livros: ${response.statusCode}');
    }
  }

  Future<List<Book>> fetchBooksByCategory(String category) async {
    final uri = Uri.parse('$baseUrl/category/$category');
    final response = await http
        .get(uri, headers: _headers(token: await _getToken()))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Book.fromJson(e)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception(
        'Erro ao buscar livros da categoria $category: ${response.statusCode}',
      );
    }
  }

  Future<List<Book>> fetchWishlist() async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/wishlist');
    final response = await http
        .get(uri, headers: _headers(token: token))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Book.fromJson(e)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Acesso negado à wishlist (status ${response.statusCode}).');
    } else {
      throw Exception('Erro ao carregar wishlist: ${response.statusCode}');
    }
  }

  Future<void> addToWishlist(int bookId) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/addwishlist/$bookId');
    final response = await http
        .post(uri, headers: _headers(token: token))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sem autorização para adicionar à wishlist.');
      }
      throw Exception('Erro ao adicionar livro à wishlist (status ${response.statusCode}).');
    }
  }

  Future<void> removeFromWishlist(int bookId) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/wishlist/$bookId');
    final response = await http
        .delete(uri, headers: _headers(token: token))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sem autorização para remover da wishlist.');
      }
      throw Exception('Falha ao remover da wishlist (status ${response.statusCode}).');
    }
  }

  Future<bool> isInWishlist(int bookId) async {
    final list = await fetchWishlist();
    return list.any((b) => b.id == bookId);
  }
}