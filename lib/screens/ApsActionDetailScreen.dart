import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'AddElementDeMesureScreen.dart';
import 'dart:convert';

class ApsActionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> action;

  const ApsActionDetailScreen({super.key, required this.action});

  @override
  _ApsActionDetailScreenState createState() => _ApsActionDetailScreenState();
}

class _ApsActionDetailScreenState extends State<ApsActionDetailScreen> {
  List<dynamic> elements = [];
  List<dynamic> comptesRendus = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final id = widget.action['id'];
      final elementsResult = await ApiService.getElementsByPlanAction(id);
      final comptesRendusResult = await ApiService.fetchComptesRendusByPlanActionId(id);

      setState(() {
        elements = elementsResult;
        comptesRendus = comptesRendusResult;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur : $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du chargement")),
      );
    }
  }

  void showCompteRenduDialog(Map<String, dynamic> compteRendu) {
    final reponses = compteRendu['reponses'] as Map<String, dynamic>? ?? {};
    final medias = compteRendu['medias'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Compte Rendu  (${compteRendu['dateSoumission']})',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Réponses :", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                ...reponses.entries.map((entry) => Text("${entry.key} : ${entry.value}")),
                const SizedBox(height: 10),
                Text("Médias :", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                ...medias.map((base64) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Image.memory(base64Decode(base64)),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Fermer"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Évaluer l’action', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20)),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSection("Détails de l'action", Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Responsable: ${widget.action['responsable'] ?? '---'}", style: GoogleFonts.montserrat(fontSize: 16)),
                const SizedBox(height: 6),
                Text("Type: ${widget.action['type'] ?? '---'}", style: GoogleFonts.montserrat(fontSize: 16)),
                const SizedBox(height: 6),
                Text("Action: ${widget.action['action'] ?? '---'}", style: GoogleFonts.montserrat(fontSize: 16)),
                const SizedBox(height: 6),
                Text("Correction immédiate: ${widget.action['correctionImmediate'] ?? 'Non'}", style: GoogleFonts.montserrat(fontSize: 16)),
              ],
            )),
            const SizedBox(height: 20),

            // Éléments de mesure
            _buildSection("Évaluation", Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Éléments de mesure", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.blueGrey.shade800)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text("Ajouter une mesure", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddElementDeMesureScreen(planActionId: widget.action['id']),
                      ),
                    );
                    if (result == true) {
                      await fetchData(); // Recharger tous les éléments
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Élément ajouté avec succès")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                ...elements.map((e) => Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['elementEfficacite'] as String? ?? '', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text("Détails : ${e['detailsEfficacite'] as String? ?? ''}", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Text("Résultat : ${e['resultat'] as String? ?? ''}", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Text("Note : ${e['note']?.toString() ?? ''}", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.blue.shade700)),
                      ],
                    ),
                  ),
                )),
              ],
            )),

            const SizedBox(height: 20),

            // Section Compte Rendu
            _buildSection("Comptes Rendus", comptesRendus.isEmpty
                ? Text("Aucun compte rendu pour cette action", style: GoogleFonts.montserrat())
                : Column(
              children: comptesRendus.map((cr) => ListTile(
                title: Text("date soumission ${cr['dateSoumission']}", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                //subtitle: Text(cr['statut'] ?? "Sans statut", style: GoogleFonts.montserrat(fontSize: 14)),
                trailing: const Icon(Icons.visibility),
                onTap: () => showCompteRenduDialog(cr),
              )).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blue.shade800)),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}
