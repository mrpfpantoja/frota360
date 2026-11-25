import 'package:flutter/material.dart';
import 'models.dart';
import 'telas.dart';

void main() {
  carregarExemplo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frota360',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

// ------------------------------------------------------------------- 1. LOGIN
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  bool _esconderSenha = true;

  // Login simulado: aceita qualquer usuário e senha preenchidos
  void _entrar() {
    if (_usuario.text.trim().isEmpty || _senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha usuário e senha')),
      );
      return;
    }
    usuarioLogado = _usuario.text.trim();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.directions_car, size: 72, color: Colors.blue),
              const Text('Frota360',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              const Text('Checklist Inteligente de Veículos'),
              const SizedBox(height: 32),
              TextField(
                controller: _usuario,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Usuário',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senha,
                obscureText: _esconderSenha,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _esconderSenha ? Icons.visibility : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _esconderSenha = !_esconderSenha),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _entrar,
                  child: const Text('Entrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
