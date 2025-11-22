import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'main_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _message;
  bool _obscure = true;

  // Paleta e estilos compartilhados (igual LoginPage simplificada)
  static const Color primaryBg = Color(0xFF6366F1);
  static const Color circlesColor = Color(0xFF1E2633);
  static const Color fieldFill = Color(0xFFD9D9D9);
  static const Color buttonColor = Color(0xFF111517);

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final result = await _authService.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _message = result;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topHeight = MediaQuery.of(context).size.height * 0.33;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Fundo decorativo
            SizedBox(
              height: topHeight,
              width: double.infinity,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: primaryBg),
                child: _CirclePattern(),
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

            // Logo / Ícone
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
                  child: const Icon(Icons.person_add_alt_1, size: 64, color: Colors.black),
                ),
              ),
            ),
            // Formulário
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 140, 28, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Criar conta',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Preencha os dados para continuar:',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _label('NOME DE USUÁRIO'),
                        TextFormField(
                          controller: _usernameController,
                          decoration: _decoration(hint: 'Digite seu usuário...'),
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Digite um nome de usuário.' : null,
                        ),
                        const SizedBox(height: 22),
                        _label('EMAIL'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _decoration(hint: 'email@exemplo.com'),
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Digite um email.' : null,
                        ),
                        const SizedBox(height: 22),
                        _label('SENHA'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: _decoration(hint: 'Digite a senha...').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_off : Icons.visibility,
                                color: Colors.black54,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                          v != null && v.length < 4 ? 'Senha muito curta.' : null,
                        ),
                        const SizedBox(height: 26),
                        if (_message != null)
                          Center(
                            child: Text(
                              _message!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _message!.contains('sucesso') ? Colors.green : Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
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
                            onPressed: _register,
                            child: const Text(
                              'Cadastrar',
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
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              'Já tem conta? Entrar',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blueGrey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
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
                    color: _RegisterPageState.circlesColor,
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