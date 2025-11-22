import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/pages/book_detail_page.dart';
import 'package:untitled3/pages/catalogo_page.dart';
import 'package:untitled3/pages/login_page.dart';
import 'package:untitled3/pages/profile_page.dart';
import 'package:untitled3/pages/wishlist_page.dart';
import 'providers/wishlist_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/book_provider.dart';
import 'pages/main_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Livraria Online',
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/wishlist': (context) => const WishlistPage(),
        '/catalogo': (_) => const CatalogoPage(),
        '/login': (_) => const LoginPage(),
        '/profile': (_) => const ProfilePage(),
        '/catalogo': (_) => const CatalogoPage(),
      },
    );

  }
}
