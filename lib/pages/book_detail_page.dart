import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final bool inWishlist = wishlist.isInWishlist(book.id);

    return Scaffold(
      backgroundColor: const Color(0xFFEAEAF7),
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text(
          "Detalhes do Livro",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Ver Wishlist',
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Imagem
            Container(
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.1),
                  )
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book.imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.book, size: 120),
                ),
              ),
            ),

            const SizedBox(height: 20),


            Text(
              book.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              book.author,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 10),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Compartilhar',
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // TODO: implementar compartilhamento
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compartilhar em breve')),
                    );
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  tooltip: inWishlist
                      ? 'Remover da Wishlist'
                      : 'Adicionar à Wishlist',
                  icon: Icon(
                    inWishlist ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: () async {
                    await wishlist.toggleWishlist(book);
                    final msg = inWishlist
                        ? 'Removido da wishlist'
                        : 'Adicionado à wishlist';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg)),
                    );
                  },
                ),
              ],
            ),

            Text(
              'R\$ ${book.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigoAccent,
              ),
            ),

            const SizedBox(height: 16),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                book.description.isNotEmpty
                    ? book.description
                    : 'Descrição indisponível para este livro.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Insira seu CEP para obter informações sobre fretes",
              style: TextStyle(
                fontSize: 12,
                color: Colors.indigo.shade400,
              ),
            ),

            const SizedBox(height: 25),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // COMPRAR (leva para carrinho)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addBook(book);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.indigoAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "COMPRAR",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // WISHLIST (toggle)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await wishlist.toggleWishlist(book);
                        final msg = wishlist.isInWishlist(book.id)
                            ? 'Adicionado à wishlist'
                            : 'Removido da wishlist';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.indigoAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        wishlist.isInWishlist(book.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.redAccent,
                      ),
                      label: Text(
                        wishlist.isInWishlist(book.id)
                            ? "Na Wishlist"
                            : "Wishlist",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}