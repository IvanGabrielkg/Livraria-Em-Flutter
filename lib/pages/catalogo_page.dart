import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/book.dart';
import 'book_detail_page.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({Key? key}) : super(key: key);

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  Future<List<Book>> fetchBooks() async {
    // AJUSTE: se estiver no Android Emulator substitua localhost por 10.0.2.2
    // iOS Simulator -> 127.0.0.1
    // Dispositivo físico -> IP da máquina na rede (ex: 192.168.0.10)
    final uri = Uri.parse('http://localhost:8080/books');

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .map((e) => Book.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Formato inválido: esperado lista.');
      }
    } else {
      throw Exception('Erro ao carregar livros: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catálogo")),
      body: FutureBuilder<List<Book>>(
        future: fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final livros = snapshot.data ?? [];
          if (livros.isEmpty) {
            return const Center(child: Text('Nenhum livro disponível.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: livros.length,
            itemBuilder: (context, index) {
              final livro = livros[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(book: livro),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: livro.imgUrl.isNotEmpty
                            ? Image.network(
                          livro.imgUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.book, size: 60),
                        )
                            : const Icon(Icons.book, size: 60),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          livro.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "R\$ ${livro.price.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}