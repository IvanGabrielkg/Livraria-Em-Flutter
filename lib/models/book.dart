class Book {
  final int id;
  final String title;
  final String author;
  final String publisher;
  final double price;
  final int stock;
  final String imgUrl;
  final String description;
  final String category;
  final String release;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.price,
    required this.stock,
    required this.imgUrl,
    required this.description,
    required this.category,
    required this.release,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Título indisponível',
      author: json['author'] ?? 'Autor desconhecido',
      publisher: json['publisher'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      imgUrl: json['imgUrl'] ?? '',
      description: json['description'] ?? 'Sem descrição',
      category: json['category'] ?? 'Sem categoria',
      release: json['release'] ?? '',
    );
  }

  // Getter para manter compatibilidade com código antigo que usava imageUrl
  double get discountedPrice => price;
  String get imageUrl => imgUrl;
}

