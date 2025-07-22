import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:8080/api/auth"; // 🔹 Adresse du backend

  // 🔹 Connexion
  static const bool isMockMode = false;

  Future<String?> login(String email, String password) async {
    if (isMockMode) {
      await Future.delayed(Duration(seconds: 1)); // Simule une latence

      // Simule un utilisateur VISITEUR
      if (email == 'visiteur@example.com' && password == '1234') {
        await _saveTokenAndRole('mock_token_visiteur', 'VISITEUR', 1);
        return 'VISITEUR';
      }

      // Simule un utilisateur APS
      if (email == 'aps@example.com' && password == '1234') {
        await _saveTokenAndRole('mock_token_aps', 'APS', 2);
        return 'APS';
      }

      // Simule un utilisateur RESPONSABLE
      if (email == 'responsable@example.com' && password == '1234') {
        await _saveTokenAndRole('mock_token_responsable', 'RESPONSABLE', 3);
        return 'RESPONSABLE';
      }

      print("Login mock échoué : identifiants invalides");
      return null;
    }

    // 🔁 Mode réel
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data["token"];
        String role = data["role"];
        int utilisateurId = data["id"];

        await _saveTokenAndRole(token, role, utilisateurId);
        return role;
      }
    } catch (e) {
      print("Login failed: $e");
    }

    return null;
  }



  // 🔹 Inscription
  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
    required String type,
    String? matricule,
    String? fonction,
    String? entite,
    String? service,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "nom": nom,
        "prenom": prenom,
        "email": email,
        "telephone": telephone,
        "password": password,
        "type": type.toUpperCase(),
        // Convertir en majuscules pour correspondre au backend
      };

      // Ajouter les champs spécifiques uniquement pour les visiteurs
      if (type.toUpperCase() == "VISITEUR") {
        requestBody.addAll({
          "matricule": matricule ?? "",
          "fonction": fonction ?? "",
          "entite": entite ?? "",
          "service": service ?? "",
        });
      }

      print("Envoi au backend: ${jsonEncode(requestBody)}"); // Debug

      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Réponse du backend: ${response.statusCode} - ${response
          .body}"); // Debug

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Exception lors de l'inscription: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  Future<bool> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        // Le code de vérification a été envoyé avec succès
        return true;
      } else {
        print('Erreur lors de l\'envoi du code : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur réseau : $e');
      return false;
    }
  }

  /// Vérifie le code et change le mot de passe
  Future<bool> verifyCodeAndResetPassword(String email, String code,
      String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        body: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erreur lors de la réinitialisation : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur réseau : $e');
      return false;
    }
  }


// 🔹 Sauvegarde du token JWT
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

// 🔹 Récupération du token JWT
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

// 🔹 Déconnexion (Suppression du token)

  Future<void> _saveTokenAndRole(String token, String type,
      int utilisateurId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('type', type);
    await prefs.setInt('id', utilisateurId); // ✅ Stocke l'ID de l'utilisateur
  }

}
