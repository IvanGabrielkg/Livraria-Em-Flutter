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
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      imgUrl: json['imgUrl'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      release: json['release'] ?? '',
    );
  }

  /// Apenas se ainda estiver usando campos customizados (ex: desconto local)
  double get discountedPrice => price; // placeholder até integrar promoções
  String get imageUrl => imgUrl;
}

