import 'package:flutter/material.dart';
import 'package:visite_securite/services/auth_service.dart';
import 'login_screen.dart';

class PasswordResetScreen extends StatefulWidget {
  final String email;

  const PasswordResetScreen({required this.email, super.key});

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  void _resetPassword() async {
    String code = _codeController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires")),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    bool success = await authService.verifyCodeAndResetPassword(
      widget.email,
      code,
      newPassword,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe réinitialisé avec succès")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la réinitialisation du mot de passe")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réinitialiser le mot de passe"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Entrez le code reçu par e-mail et votre nouveau mot de passe",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Code input
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Code de vérification",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // New password input
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nouveau mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm password input
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmez le mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Submit button
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Réinitialiser le mot de passe", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
