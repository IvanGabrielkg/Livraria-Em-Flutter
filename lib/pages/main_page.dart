import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/pages/wishlist_page.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/cart_provider.dart';
import 'book_detail_page.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'catalogo_page.dart';
import 'profile_page.dart';
import '../services/auth_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();

  bool isLoggedIn = false;
  String? userName;

  final List<Map<String, dynamic>> categories = const [
    {'icon': Icons.menu_book, 'label': 'Ficção'},
    {'icon': Icons.auto_awesome, 'label': 'Fantasia'},
    {'icon': Icons.favorite, 'label': 'Romance'},
    {'icon': Icons.nightlight_round, 'label': 'Terror'},
    {'icon': Icons.psychology_alt, 'label': 'Mistério'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final logged = await _authService.isLoggedIn();
    setState(() => isLoggedIn = logged);
  }

  Future<void> _onRefresh() async {
    await context.read<BookProvider>().loadBooks();
    await _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(cart.items.length),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Livraria', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(isLoggedIn ? Icons.person : Icons.login, color: Colors.white),
            tooltip: isLoggedIn ? 'Perfil' : 'Fazer login',
            onPressed: () async {
              if (isLoggedIn) {
                await Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                _checkAuth();
              } else {
                await Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const LoginPage()));
                _checkAuth();
              }
            },
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 9,
                    child: Text(
                      '${cart.items.length}',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: _StableScrollBody(
          categories: categories,
          isLoggedIn: isLoggedIn,
          onRefresh: _onRefresh,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(cart.items.length),
    );
  }

  BottomNavigationBar _buildBottomNav(int cartCount) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.indigoAccent,
      unselectedItemColor: Colors.grey,
      onTap: (i) {
        switch (i) {
          case 0:
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogoPage()));
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => isLoggedIn ? const ProfilePage() : const LoginPage(),
              ),
            );
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart),
              if (cartCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Carrinho',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.view_module), label: 'Catálogo'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }

  Drawer _buildDrawer(int cartCount) {

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigoAccent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 56),
                const SizedBox(height: 8),
                Text(
                  isLoggedIn ? 'Bem-vindo!' : 'Usuário sem conta',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Todos os Livros'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CatalogoPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Lista de Desejos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              );},
          ),
          const Divider(),
          if (!isLoggedIn) ...[
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

class _StableScrollBody extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final bool isLoggedIn;
  final Future<void> Function() onRefresh;

  const _StableScrollBody({
    required this.categories,
    required this.isLoggedIn,
    required this.onRefresh,
  });

  @override
  State<_StableScrollBody> createState() => _StableScrollBodyState();
}

class _StableScrollBodyState extends State<_StableScrollBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final books = provider.books ?? [];

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        key: const PageStorageKey<String>('main_scroll'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _SearchBar(
                onSubmitted: (query) {
                  print('Pesquisar: $query');
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _CategoryStrip(categories: widget.categories),
          ),
          if (provider.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Erro: ${provider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (books.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Nenhum livro disponível.')),
              )
            else

              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, sectionIndex) {
                    // agrupa por categoria
                    final grouped = <String, List<Book>>{};
                    for (final b in books) {
                      grouped.putIfAbsent(b.category, () => []).add(b);
                    }
                    final entries = grouped.entries.toList();
                    final entry = entries[sectionIndex];
                    return _BookHorizontalSection(
                      key: PageStorageKey('section_${entry.key}'),
                      title: entry.key,
                      books: entry.value,
                    );
                  },
                  childCount: (() {
                    final grouped = <String, List<Book>>{};
                    for (final b in books) grouped.putIfAbsent(b.category, () => []).add(b);
                    return grouped.length;
                  })(),
                ),
              ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onSubmitted;
  const _SearchBar({required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Pesquisar título ou autor...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  const _CategoryStrip({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final c = categories[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.indigo.shade50,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {},
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(c['icon'], color: Colors.indigo, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 68,
                child: Text(
                  c['label'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookHorizontalSection extends StatelessWidget {
  final String title;
  final List<Book> books;

  const _BookHorizontalSection({Key? key, required this.title, required this.books})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardHeight = width < 360 ? 220.0 : 250.0;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CatalogoPage()));
                },
                child: const Text('Ver todos', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          SizedBox(
            height: cardHeight,
            child: ListView.builder(
              key: PageStorageKey('hlist_$title'),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: books.length,
              itemBuilder: (context, index) => _BookCard(book: books[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.05))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
                child: book.imageUrl.isNotEmpty
                    ? Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 70),
                )
                    : const Icon(Icons.book, size: 70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: Text(book.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(book.author,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('R\$ ${book.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    cart.addBook(book);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${book.title}" adicionado ao carrinho'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Comprar',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}