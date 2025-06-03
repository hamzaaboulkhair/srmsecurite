import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsObjetVisiteScreen extends StatelessWidget {
  final Map<String, dynamic> objetVisite;

  const DetailsObjetVisiteScreen({super.key, required this.objetVisite});

  String _decodeText(dynamic text) {
    if (text == null) return "Non disponible";
    return utf8.decode(text.toString().codeUnits, allowMalformed: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Détails de l'objet",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Informations du Projet"),
            _buildInfoCard([
              _buildInfoRow("Localisation", _decodeText(objetVisite["localisation"])),
              _buildInfoRow("Fluide", _decodeText(objetVisite["fluide"])),
              _buildInfoRow("Nature des Travaux", _decodeText(objetVisite["natureTravaux"])),
              _buildInfoRow("Département", _decodeText(objetVisite["departement"])),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle("Coordonnées APS"),
            _buildContactCard([
              _buildContactRow("Nom", _decodeText(objetVisite["aps"]?["nom"])),
              _buildContactRow("Email", _decodeText(objetVisite["aps"]?["email"])),
              _buildContactRow("Téléphone", _decodeText(objetVisite["aps"]?["telephone"])),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle("Coordonnées Responsable Chantier"),
            _buildContactCard([
              _buildContactRow("Nom", _decodeText(objetVisite["responsable"]?["nom"])),
              _buildContactRow("Email", _decodeText(objetVisite["responsable"]?["email"])),
              _buildContactRow("Téléphone", _decodeText(objetVisite["responsable"]?["telephone"])),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildContactCard(List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: child,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.montserrat(fontSize: 15, color: Colors.black87),
          children: <TextSpan>[
            TextSpan(text: '$label : ', style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text('$label :', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 15)),
        ),
        Expanded(
          child: Text(value, style: GoogleFonts.montserrat(fontSize: 15), overflow: TextOverflow.ellipsis, maxLines: 2),
        ),
      ],
    );
  }
}