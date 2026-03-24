// lib/features/auth/login_screen.dart

import 'package:flutter/material.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/primary_button.dart';
import '../dashboard/dashboard_screen.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool obscure = true;

  void login() {
    if (AuthService.login(userCtrl.text, passCtrl.text)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 🖼️ LOGO
              Image.asset(
                "assets/logo.png",
                height: 100,
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              CustomTextField(
                controller: userCtrl,
                label: "User ID",
              ),

              // 🔐 PASSWORD FIELD WITH TOGGLE
              TextField(
                controller: passCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => obscure = !obscure);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              PrimaryButton(
                text: "Login",
                onTap: login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}