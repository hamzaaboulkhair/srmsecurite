import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visite_securite/screens/signup_screen.dart';
import 'package:visite_securite/screens/welcome_aps_screen.dart';
import 'package:visite_securite/screens/welcome_responsable_screen.dart';
import 'package:visite_securite/screens/welcome_visitor_screen.dart';
import 'package:visite_securite/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'PasswordRecoveryScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _obscurePassword = true;

  void _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    String? role = await authService.login(email, password);

    if (role != null) {
      Widget nextScreen;
      final prefs = await SharedPreferences.getInstance();
      final int? id = prefs.getInt('id');
      if (role == "VISITEUR") {
        nextScreen = WelcomeVisitorScreen();
      } else if (role == "APS") {
        nextScreen = WelcomeApsScreen(userId: id!);
      } else if (role == "RESPONSABLE") {
        nextScreen = WelcomeResponsableScreen(userId: id!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rôle inconnu. Contactez un administrateur.")),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de connexion. Vérifiez vos identifiants.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView( // Added for better responsiveness on smaller screens
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Elevated Logo
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/srm_logo.png',
                  height: 120, // Slightly larger logo
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Bienvenue",
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Entrez vos informations svp",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Elevated Email Field
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade700),
                    border: InputBorder.none, // Remove default border
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Elevated Password Field
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade700),
                    border: InputBorder.none, // Remove default border
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordRecoveryScreen()),
                    );
                  },
                  child: Text(
                    "Mot de passe oublié?",
                    style: GoogleFonts.montserrat(color: Colors.black54),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Elevated Login Button with Gradient
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: _login,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade900],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                      "Se connecter",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stylish Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous n'avez pas encore de compte ?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(color: Colors.grey.shade700,fontSize: 1),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      "S'inscrire",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 14
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}