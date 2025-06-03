import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'dart:convert';
import '../services/api_service.dart';

class CompteRenduByVisiteScreen extends StatefulWidget {
  final int visiteId;

  const CompteRenduByVisiteScreen({super.key, required this.visiteId});

  @override
  State<CompteRenduByVisiteScreen> createState() => _CompteRenduByVisiteScreenState();
}

class _CompteRenduByVisiteScreenState extends State<CompteRenduByVisiteScreen> {
  List<dynamic> comptesRendus = [];
  bool isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await ApiService.fetchComptesRendusByVisiteId(widget.visiteId);
      setState(() {
        comptesRendus = data;
        isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _error = "Impossible de charger les comptes rendus. Veuillez réessayer plus tard.";
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}", style: GoogleFonts.montserrat())));
    }
  }

  void showDetailsDialog(Map<String, dynamic> compte) {
    final reponses = compte['reponses'] as Map<String, dynamic>?;
    final medias = compte['medias'] as List<dynamic>?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Détails Compte Rendu #${compte['id'] ?? 'N/A'}",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Réponses :", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (reponses != null && reponses.isNotEmpty)
                ...reponses.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "${entry.key} : ${entry.value}",
                    style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ))
              else
                Text(
                  "Aucune réponse détaillée.",
                  style: GoogleFonts.montserrat(fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 15),
              Text("Médias :", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (medias != null && medias.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: medias.map((mediaBase64) {
                    try {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(mediaBase64),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 90,
                                width: 90,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                              ),
                        ),
                      );
                    } catch (e) {
                      // Handle invalid Base64 string or image decoding error
                      print("Error decoding image: $e"); // For debugging
                      return Container(
                        height: 90,
                        width: 90,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.error, color: Colors.red.shade400),
                      );
                    }
                  }).toList(),
                )
              else
                Center(
                  child: Text(
                    "Aucun média joint.",
                    style: GoogleFonts.montserrat(fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Fermer", style: GoogleFonts.montserrat(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Comptes Rendus de Visite",
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchData,
            tooltip: 'Actualiser les comptes rendus',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Erreur: $_error",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: Colors.red.shade700, fontSize: 16),
          ),
        ),
      )
          : comptesRendus.isEmpty
          ? Center(
        child: Text(
          "Aucun compte rendu trouvé pour cette visite.",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade600),
        ),
      )
          : ListView.builder(
        itemCount: comptesRendus.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final compte = comptesRendus[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => showDetailsDialog(compte),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Compte Rendu ID: ${compte['id'] ?? 'N/A'}",
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date de Soumission: ${compte['dateSoumission'] ?? 'Non spécifiée'}",
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () => showDetailsDialog(compte),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // Remove default padding
                          alignment: Alignment.centerRight,
                        ),
                        child: Text(
                          "Voir détails",
                          style: GoogleFonts.montserrat(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? statut) {
    switch (statut) {
      case "En cours":
        return Colors.orange.shade700;
      case "Validé":
        return Colors.green.shade700;
      case "Rejeté":
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}