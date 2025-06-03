import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'package:email_validator/email_validator.dart'; // For email validation
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _fonctionController = TextEditingController();
  final _entiteController = TextEditingController();
  final _serviceController = TextEditingController();

  String _selectedType = "VISITEUR";
  bool _isLoading = false;
  String? _errorMessage;
  bool _showVisitorFields = false;

  // Method to validate email format
  bool _isEmailValid(String email) {
    return EmailValidator.validate(email);
  }

  // Method to validate password (e.g., at least 6 characters)
  bool _isPasswordValid(String password) {
    return password.length >= 6;
  }

  // Method to validate name fields (nom and prenom)
  bool _isNameValid(String name) {
    return name.isNotEmpty && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  // Method to validate phone number format (for French numbers)
  bool _isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber);
  }

  // Method to handle the registration process
  void _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedType.isEmpty ||
        (_showVisitorFields &&
            (_matriculeController.text.isEmpty ||
                _fonctionController.text.isEmpty ||
                _entiteController.text.isEmpty ||
                _serviceController.text.isEmpty))) {
      setState(() {
        _errorMessage = "Veuillez remplir toutes les informations.";
        _isLoading = false;
      });
      return;
    }

    if (!_isEmailValid(_emailController.text)) {
      setState(() {
        _errorMessage = "Veuillez entrer un email valide.";
        _isLoading = false;
      });
      return;
    }

    if (!_isPasswordValid(_passwordController.text)) {
      setState(() {
        _errorMessage = "Le mot de passe doit comporter au moins 6 caractères.";
        _isLoading = false;
      });
      return;
    }

    if (!_isNameValid(_nomController.text)) {
      setState(() {
        _errorMessage = "Le nom doit être composé uniquement de lettres.";
        _isLoading = false;
      });
      return;
    }

    if (!_isNameValid(_prenomController.text)) {
      setState(() {
        _errorMessage = "Le prénom doit être composé uniquement de lettres.";
        _isLoading = false;
      });
      return;
    }

    if (!_isPhoneNumberValid(_telephoneController.text)) {
      setState(() {
        _errorMessage = "Veuillez entrer un numéro de téléphone valide.";
        _isLoading = false;
      });
      return;
    }

    AuthService authService = AuthService();
    bool success = await authService.register(
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
      telephone: _telephoneController.text,
      password: _passwordController.text,
      type: _selectedType,
      matricule: _showVisitorFields ? _matriculeController.text : null,
      fonction: _showVisitorFields ? _fonctionController.text : null,
      entite: _showVisitorFields ? _entiteController.text : null,
      service: _showVisitorFields ? _serviceController.text : null,
    );

    if (success) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      setState(() {
        _errorMessage = "Échec de l'inscription. Réessayez.";
      });
      // Optionally, you might not want to immediately navigate on failure
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildErrorMessage() {
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          _errorMessage!,
          style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.montserrat(),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade700),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Créer un compte", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/srm_logo.png',
                height: 100,
              ),
              const SizedBox(height: 25),
              Text(
                "Créer un compte",
                style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
              ),
              const SizedBox(height: 8),
              Text(
                "Remplissez les informations ci-dessous.",
                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // Text fields for the form
              _buildTextField("Nom", _nomController),
              _buildTextField("Prénom", _prenomController),
              _buildTextField("Email", _emailController, keyboardType: TextInputType.emailAddress),
              _buildTextField("Téléphone", _telephoneController, keyboardType: TextInputType.phone),
              _buildTextField("Mot de passe", _passwordController, obscureText: true),

              const SizedBox(height: 15),
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: "Type de compte",
                    labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade700),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                  items: ["APS", "VISITEUR", "RESPONSABLE"]
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type, style: GoogleFonts.montserrat()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      _showVisitorFields = _selectedType == "VISITEUR";
                    });
                  },
                ),
              ),

              if (_showVisitorFields) ...[
                const SizedBox(height: 15),
                ExpansionTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  backgroundColor: Colors.blue.shade50.withOpacity(0.3),
                  title: Text("Informations supplémentaires pour les visiteurs", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 18),
                  children: [
                    _buildTextField("Matricule", _matriculeController),
                    _buildTextField("Fonction", _fonctionController),
                    _buildTextField("Entité", _entiteController),
                    _buildTextField("Service", _serviceController),
                  ],
                ),
              ],

              // S'inscrire button
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: _register,
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
                      "S'inscrire",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              _buildErrorMessage(),

              // Navigation to login screen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous avez déjà un compte ?",
                    style: GoogleFonts.montserrat(color: Colors.grey.shade700),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Se connecter",
                      style: GoogleFonts.montserrat(color: Colors.blue.shade800, fontWeight: FontWeight.w500),
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