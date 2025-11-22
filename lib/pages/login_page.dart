import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _obscure = true;

  static const Color primaryBg = Color(0xFF6366F1);
  static const Color circlesColor = Color(0xFF1E2633);
  static const Color fieldFill = Color(0xFFD9D9D9);
  static const Color buttonColor = Color(0xFF111517);

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      setState(() => _error = 'Email ou senha incorretos ou erro de conexão.');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topHeight = MediaQuery.of(context).size.height * 0.33; // reduzido
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

            // Fundo decorativo
            SizedBox(
              height: topHeight,
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: primaryBg),
                child: const _CirclePattern(),
              ),
            ),
            // Botão de voltar
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainPage()),
                  );
                },
              ),
            ),

            // Logo
            Positioned(
              top: topHeight * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: const Icon(Icons.menu_book, size: 64, color: Colors.black),
                ),
              ),
            ),
            // Formulário
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // altura automática -> permite rolagem sem esconder campos
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 140, 28, 32),
                  // OBS: 140 cobre a área atrás da logo. Ajuste se quiser subir/descer.
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Entre para continuar:',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _label('EMAIL'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _decoration(hint: 'email@exemplo.com'),
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Digite seu email.' : null,
                        ),
                        const SizedBox(height: 22),
                        _label('SENHA'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: _decoration(hint: 'Sua senha').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_off : Icons.visibility,
                                color: Colors.black54,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Digite sua senha.' : null,
                        ),
                        const SizedBox(height: 26),
                        if (_error != null)
                          Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _login,
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  // TODO: tela de recuperação
                                },
                                child: const Text(
                                  'Esqueceu a senha?',
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                                  );
                                },
                                child: const Text(
                                  'Cadastre-se',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blueGrey,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  static InputDecoration _decoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.black54),
    );
  }
}

class _CirclePattern extends StatelessWidget {
  const _CirclePattern();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        const size = 100.0;
        final cols = (w / size).ceil();
        final rows = (h / size).ceil();

        return Wrap(
          children: List.generate(rows * cols, (i) {
            return SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Container(
                  width: size * 0.75,
                  height: size * 0.75,
                  decoration: const BoxDecoration(
                    color: _LoginPageState.circlesColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}