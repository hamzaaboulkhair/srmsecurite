import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsParticipantScreen extends StatelessWidget {
  final Map<String, dynamic> participant;

  const DetailsParticipantScreen({super.key, required this.participant});

  String _decodeText(String? text) {
    return text ?? "Non spécifié";
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text("$label:", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.montserrat(fontSize: 16), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> rows) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Détails du participant",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Informations générales"),
            _buildInfoCard([
              _buildInfoRow("Nom", _decodeText(participant["nom"] as String?)),
              _buildInfoRow("Prénom", _decodeText(participant["prenom"] as String?)),
              _buildInfoRow("Type", _decodeText(participant["type"] as String?)),
              _buildInfoRow("Téléphone", _decodeText(participant["telephone"] as String?)),
              _buildInfoRow("Email", _decodeText(participant["email"] as String?)),
            ]),
          ],
        ),
      ),
    );
  }
}