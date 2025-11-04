import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/cart_provider.dart';
import '../pages/book_detail_page.dart';
import '../pages/cart_page.dart';
import '../pages/login_page.dart';
import '../pages/profile_page.dart'; // Certifique-se de criar

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variável simulada de login (substituir pela lógica real)
  bool isLoggedIn = false;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.menu_book, 'label': 'Ficção'},
    {'icon': Icons.auto_awesome, 'label': 'Fantasia'},
    {'icon': Icons.favorite, 'label': 'Romance'},
    {'icon': Icons.nightlight_round, 'label': 'Terror'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
        title: const Text('Book Store', style: TextStyle(color: Colors.white)),
        actions: [
          // Botão de login
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: isLoggedIn ? 'Perfil' : 'Fazer login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  isLoggedIn ? const ProfilePage() : const LoginPage(),
                ),
              );
            },
          ),
          // Botão do carrinho
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            ),
          ),
        ],
      ),
      body: _buildBody(bookProvider),
      bottomNavigationBar: _buildBottomNav(cart.items.length),
    );
  }

  Widget _buildBody(BookProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Erro: ${provider.error}'));
    }

    final books = provider.books;
    if (books.isEmpty) {
      return const Center(child: Text('Nenhum livro disponível.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearch(),
          const SizedBox(height: 20),
          _buildCategories(),
          const SizedBox(height: 20),
          _buildBookSections(books),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Pesquisar...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Por Categoria:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final c = categories[index];
              return Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Icon(c['icon'], color: Colors.indigo, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(c['label'], style: const TextStyle(fontSize: 13)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookSections(List<Book> books) {
    final categoriesSet = books.map((b) => b.category).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoriesSet.map((category) {
        final categoryBooks =
        books.where((book) => book.category == category).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryBooks.length,
                itemBuilder: (context, index) {
                  final book = categoryBooks[index];
                  return _buildBookCard(context, book);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    final cart = context.read<CartProvider>();

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailPage(book: book),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(book.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
          Text(book.author,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text('R\$ ${book.discountedPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 15, color: Colors.indigoAccent)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              cart.addBook(book);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigoAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('COMPRAR'),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNav(int cartCount) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (i) {
        setState(() => selectedIndex = i);

        switch (i) {
          case 0: // Início
            break;
          case 1: // Carrinho
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
            break;
          case 2: // Menu
            _scaffoldKey.currentState!.openDrawer();
            break;

          case 3: // Perfil
            if (isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
            break;
        }
      },
      selectedItemColor: Colors.indigoAccent,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart),
              if (cartCount > 0)
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                    child: Text('$cartCount',
                        style:
                        const TextStyle(fontSize: 8, color: Colors.white)),
                  ),
                ),
            ],
          ),
          label: 'Carrinho',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigoAccent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: Colors.white, size: 50),
                const SizedBox(height: 10),
                Text(
                  isLoggedIn ? 'Bem-vindo, Usuário!' : 'Usuário sem conta',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {}),
          ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Todos os livros'),
              onTap: () {}),
          ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Ofertas'),
              onTap: () {}),

          // Botões de login e cadastro se não estiver logado
          if (!isLoggedIn) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Cadastro'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()), // Trocar pela SignupPage
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
