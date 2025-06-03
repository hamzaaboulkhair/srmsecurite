import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visite_securite/services/auth_service.dart';

import 'PasswordResetScreen.dart'; // Import the reset screen

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService authService = AuthService();

  void _recoverPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'adresse e-mail est requise")),
      );
      return;
    }

    try {
      bool success = await authService.sendVerificationCode(email);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Code envoyé à votre adresse e-mail")),
        );

        // Naviguer vers l'écran de réinitialisation avec juste l'email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetScreen(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'envoi du code")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de communication avec le serveur")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mot de passe oublié", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20)),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Entrez votre adresse e-mail pour recevoir un code de vérification.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.blueGrey.shade800)),
            const SizedBox(height: 30),

            // Email input field
            TextField(
              controller: emailController,
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                labelText: "Adresse e-mail",
                labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade800), borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 20),

            // Submit button
            ElevatedButton(
              onPressed: _recoverPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: Text("Envoyer le code", style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
