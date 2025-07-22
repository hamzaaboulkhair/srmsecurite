import 'package:flutter/material.dart';
import 'package:visite_securite/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
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
  bool _isLoading = false; // Added for loading state
  bool _isNewPasswordVisible = false; // For password visibility toggle
  bool _isConfirmPasswordVisible = false; // For password visibility toggle

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    // Basic validation
    String code = _codeController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tous les champs sont obligatoires.", style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Les mots de passe ne correspondent pas.", style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    // Add password strength validation (optional but recommended)
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Le nouveau mot de passe doit contenir au moins 6 caractères.", style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }


    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      bool success = await authService.verifyCodeAndResetPassword(
        widget.email,
        code,
        newPassword,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Mot de passe réinitialisé avec succès. Veuillez vous connecter avec votre nouveau mot de passe.", style: GoogleFonts.montserrat()),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()), // Ensure LoginScreen is const if possible
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Échec de la réinitialisation du mot de passe. Le code est peut-être incorrect ou a expiré.", style: GoogleFonts.montserrat()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur s'est produite : ${e.toString()}", style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Réinitialiser le mot de passe",
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade800, // Consistent with other screens
        iconTheme: const IconThemeData(color: Colors.white), // For back button
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow
        padding: const EdgeInsets.all(24.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            Text(
              "Un code de vérification a été envoyé à l'adresse e-mail associée à votre compte (${widget.email}). Veuillez l'entrer ci-dessous avec votre nouveau mot de passe.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 15, color: Colors.blueGrey.shade700),
            ),
            const SizedBox(height: 30), // More vertical space

            // Code input
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number, // Suggest numeric keyboard for codes
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                labelText: "Code de vérification",
                labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                prefixIcon: Icon(Icons.vpn_key_rounded, color: Colors.blue.shade600), // Icon
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // New password input
            TextField(
              controller: _newPasswordController,
              obscureText: !_isNewPasswordVisible, // Toggle visibility
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                labelText: "Nouveau mot de passe",
                labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                prefixIcon: Icon(Icons.lock_rounded, color: Colors.blue.shade600),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm password input
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible, // Toggle visibility
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                labelText: "Confirmez le mot de passe",
                labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                prefixIcon: Icon(Icons.lock_reset_rounded, color: Colors.blue.shade600),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 30),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword, // Disable button while loading
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                minimumSize: const Size(double.infinity, 55), // Taller button
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                elevation: 5, // Add shadow
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                  : Text(
                "Réinitialiser le mot de passe",
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}