import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080/api";

  static Future<List<Map<String, dynamic>>> fetchUtilisateurs() async {
    try {
      // 🔹 Récupérer le token JWT stocké dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/utilisateurs"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Échec de la récupération des objets de visite");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }


  static Future<Map<String, dynamic>?> fetchVisiteDetails(int visiteId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/visite/$visiteId/participants"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> visiteDetails = jsonDecode(response.body);
      print("✅ Visite récupérée avec succès : $visiteDetails");
      return visiteDetails;
    } else {
      print("⚠️ Erreur API fetchVisiteDetails: ${response.statusCode}");
      return null;
    }
  }


  static Future<List<Map<String, dynamic>>> fetchParticipants(int visiteId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/visite/$visiteId/participants"));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        print("Erreur API fetchParticipants: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur lors de la récupération des participants: $e");
      return [];
    }
  }

  static Future<List<dynamic>> fetchVisitesByAps(int apsId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/visites/aps/$apsId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> visites = jsonDecode(response.body);
      print("✅ Visites APS récupérées avec succès");
      return visites;
    } else {
      print("⚠️ Erreur API fetchVisitesByAps: ${response.statusCode}");
      throw Exception("Erreur lors de la récupération des visites");
    }
  }

  static Future<List<dynamic>> fetchVisitesByResponsable(int responsableId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/visites/responsable/$responsableId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> visites = jsonDecode(response.body);
      print("✅ Visites APS récupérées avec succès");
      return visites;
    } else {
      print("⚠️ Erreur API fetchVisitesByResponsable: ${response.statusCode}");
      throw Exception("Erreur lors de la récupération des visites");
    }
  }

  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', userData['token']);

    // Stockez l'ID de l'utilisateur selon son type
    if (userData['type'] == 'APS') {
      await prefs.setString('apsId', userData['id'].toString());
    }
    // ... autres types d'utilisateurs
  }

  // 🔹 Récupérer la liste des objets de visite avec authentification
  static Future<List<Map<String, dynamic>>> fetchObjetsVisites() async {
    try {
      // 🔹 Récupérer le token JWT stocké dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');


      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/objets-visite"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Échec de la récupération des objets de visite");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }


  static Future<bool> enregistrerVisite(Map<String, dynamic> visiteData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? id = prefs.getInt('id');
    final String? role = prefs.getString('type');
    if (token == null || id == null || role == null) {
      throw Exception("Utilisateur non authentifié");
    }

    // Ajoute l'ID utilisateur aux données envoyées
    visiteData["utilisateurId"] = id;
    visiteData["role"] = role;

    final response = await http.post(
      Uri.parse("$baseUrl/visites/ajouter"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(visiteData),
    );
    print("ID utilisateur envoyé avec la visite : $id");
    print("Rôle utilisateur récupéré : $role");


    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> fetchToutesVisites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final int? id = prefs.getInt('id');

      if (token == null || id == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/visites/utilisateur/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Échec de la récupération des visites");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }




  static Future<List<Map<String, dynamic>>> fetchVisitesPlanifiees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final int? id = prefs.getInt('id');



      if (token == null || id == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/visites/utilisateur/$id"), // ✅ Correction URL
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Échec de la récupération des visites");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  static Future<List<dynamic>> fetchPlanActionsByVisiteId(int visiteId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Utilisateur non authentifié");
    }
    final response = await http.get(
      Uri.parse('$baseUrl/plans-action/visite/$visiteId'),
      headers: {"Authorization": "Bearer $token",
        'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // une liste de planActions
    } else {
      throw Exception('Échec de chargement des plans d\'action');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchComptesRendusByVisiteId(int visiteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/comptes-rendus/visite/$visiteId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Échec de la récupération des comptes rendus pour la visite $visiteId");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }



// ... other imports and class definition

  static Future<List<Map<String, dynamic>>> fetchNotificationsByUserId(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/utilisateur/$userId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // **CRUCIAL FIX FOR ACCENTS:** Decode the response body bytes as UTF-8
        final String responseBodyUtf8 = utf8.decode(response.bodyBytes);
        return List<Map<String, dynamic>>.from(jsonDecode(responseBodyUtf8));
      } else {
        // You might want to decode the error body too for better debugging
        final String errorBody = utf8.decode(response.bodyBytes);
        throw Exception("Échec de la récupération des notifications pour l'utilisateur $userId. Statut: ${response.statusCode}, Erreur: $errorBody");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  static Future<int> fetchUnreadNotificationsCount(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/non-lues/$userId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception("Erreur lors de la récupération du nombre de notifications");
      }
    } catch (e) {
      print("Erreur API fetchUnreadNotificationsCount : $e");
      return 0;
    }
  }


  static Future<void> markAllNotificationsAsRead(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/marquer-lues/$userId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Erreur lors de la mise à jour des notifications");
      }
    } catch (e) {
      print("Erreur API markAllNotificationsAsRead : $e");
    }
  }


  static Future<List<Map<String, dynamic>>> fetchComptesRendusByPlanActionId(int planActionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/comptes-rendus/by-plan-action/$planActionId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Échec de la récupération des comptes rendus pour le plan d'action $planActionId");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }









  // 🔹 Supprimer une ou plusieurs visites
  static Future<bool> supprimerVisites(List<int> visiteIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');


      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      bool success = true;
      for (int id in visiteIds) {
        final response = await http.delete(
          Uri.parse("$baseUrl/visites/$id"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode != 200) {
          success = false;
        }
      }
      return success;
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }
  static Future<bool> modifierVisite(int id, Map<String, dynamic> visiteData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');


      if (token == null) {
        throw Exception("Utilisateur non authentifié");
      }

      if (!visiteData.containsKey("etat")) {
        visiteData["etat"] = "Planifiée";
      }

      final response = await http.put(
        Uri.parse("$baseUrl/visites/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(visiteData),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  static Future<Map<String, dynamic>> submitCompteRendu(
      String contenu,
      int visiteId,
      Map<String, String> reponses,
      List<File> files,
      ) async {
    final Uri uploadUrl = Uri.parse("$baseUrl/comptes-rendus/ajouter");

    try {
      // Convertir chaque fichier en base64
      List<String> base64Files = [];
      for (var file in files) {
        final bytes = await file.readAsBytes();
        String base64File = base64Encode(bytes);
        base64Files.add(base64File);
      }

      final Map<String, dynamic> data = {
        "contenu": contenu,
        "visiteId": visiteId,
        "reponses": reponses,
        "filesBase64": base64Files,
      };

      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.post(
        uploadUrl,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Erreur lors de l\'envoi: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print("Erreur de communication avec l'API: $e");
      return {};
    }
  }

  static Future<void> sendTokenToBackend(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('id');

      if (token == null || userId == null) {
        throw Exception("Utilisateur non authentifié.");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/utilisateurs/$userId/fcm-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(fcmToken),
      );

      if (response.statusCode == 200) {
        print('✅ Token FCM envoyé avec succès.');
      } else {
        print('❌ Erreur lors de l\'envoi du token FCM : ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception lors de l\'envoi du token FCM : $e');
    }
  }




  static Future<List<String>> _encodeFilesAsBase64(List<File> files) async {
    List<String> base64Files = [];
    for (File file in files) {
      final bytes = await file.readAsBytes();
      base64Files.add(base64Encode(bytes));
    }
    return base64Files;
  }

  static Future<Map<String, dynamic>> submitActionRealisation(
      int actionId,
      Map<String, dynamic> data,
      ) async {
    final Uri url = Uri.parse("$baseUrl/execution_action/execution/$actionId");

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('Erreur de communication: $e');
      return {};
    }
  }





  static Future<List<Map<String, dynamic>>> fetchPlanActions(int compteRenduId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? id = prefs.getInt('id');

    final response = await http.get(
      Uri.parse('$baseUrl/plans-action/compte-rendu/$compteRenduId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print('Plan actions retrieved: $data');  // Print for debugging
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Failed to load plan actions with status: ${response.statusCode}');
      throw Exception('Failed to load plan actions');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCompteRenduById(int compteRenduId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');


    final response = await http.get(
      Uri.parse('$baseUrl/comptes-rendus/$compteRenduId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print('Plan actions retrieved: $data');  // Print for debugging
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Failed to load comptes rendus with status: ${response.statusCode}');
      throw Exception('Failed to load compte rendus');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAgentFunctions(int visiteId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agent-functions/visite/$visiteId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Ensure data is an array of maps with the required structure
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load agent functions');
      }
    } catch (e) {
      print("Error fetching agent functions: $e");
      throw Exception('Failed to load agent functions');
    }
  }





  // lib/services/api_service.dart

  static Future<bool> submitPlanAction(
      String observation, int compteRenduId, String type, String correctionImmediate, String action, String responsable) async {

    final Uri uploadUrl = Uri.parse("$baseUrl/plans-action/ajouter");

    try {
      var request = http.MultipartRequest('POST', uploadUrl);
      request.fields['observation'] = observation;  // Assurez-vous que le champ est correct
      request.fields['compte_rendu_id'] = compteRenduId.toString();
      request.fields['type'] = type;
      request.fields['correctionImmediate'] = correctionImmediate;
      request.fields['action'] = action;
      request.fields['responsable'] = responsable;


      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Plan Action submitted successfully");
        return true;
      } else {
        print("Error submitting Plan Action: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Communication error with API: $e");
      return false;
    }
  }




  // Add an agent function
  static Future<Map<String, dynamic>> addAgentFunction(int visiteId, String functionName) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/agent-functions/visite/$visiteId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'functionName': functionName}), // Send functionName in the body
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Return the response from the server
    } else {
      throw Exception('Failed to add agent function');
    }
  }

  static Future<List<String>> getAvailableFunctions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/functions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map<String>((e) => e['name'] as String).toList();
    } else {
      throw Exception("Erreur de chargement des fonctions");
    }
  }


  static Future<Map<String, dynamic>> addElementDeMesure({
    required int planActionId,
    required String elementEfficacite,
    required String detailsEfficacite,
    required String resultat,
    required int note,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/element-mesure/add/$planActionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'elementEfficacite': elementEfficacite,
        'detailsEfficacite': detailsEfficacite,
        'resultat': resultat,
        'note': note,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec de l\'ajout de l\'élément de mesure');
    }
  }

  static Future<List<dynamic>> getElementsByPlanAction(int planActionId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/element-mesure/plan-action/$planActionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des éléments');
    }
  }


  static Future<bool> deleteAgentFunction(int visiteId, int functionId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/agent-functions/visite/$visiteId/function/$functionId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true; // Successfully deleted
    } else {
      throw Exception('Failed to delete agent function');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPlanActionsByvisite(int visiteId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/plans-action/visite/$visiteId'), // Assurez-vous que l'endpoint correspond
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load plan actions');
    }
  }



}




















