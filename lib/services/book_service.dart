import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String baseUrl = 'http://localhost:8080';


  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Falha ao carregar livros: ${response.statusCode}');
    }
  }

  Future<List<Book>> fetchBooksByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/books/category/$category'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar livros da categoria $category: ${response.statusCode}');
    }
  }
}
