import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../models/book.dart';
import 'book_detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishlistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Desejos"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text("Erro: ${provider.error}"))
          : provider.wishlist.isEmpty
          ? const Center(
        child: Text(
          'Sua wishlist está vazia.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: provider.wishlist.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final book = provider.wishlist[index];
          return _WishlistItem(
            book: book,
            onRemove: () async {
              await provider.removeFromWishlist(book.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${book.title}" removido'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailPage(book: book),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => provider.loadWishlist(),
        backgroundColor: Colors.indigoAccent,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _WishlistItem extends StatelessWidget {
  final Book book;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _WishlistItem({
    required this.book,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.imageUrl,
                  width: 55,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.book, size: 55),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${book.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.indigoAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remover da wishlist',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}