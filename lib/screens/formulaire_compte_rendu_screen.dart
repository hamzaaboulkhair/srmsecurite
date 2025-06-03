import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'ObservationsScreen.dart';

class FormulaireCompteRenduScreen extends StatefulWidget {
  final Map<String, dynamic> visite;

  const FormulaireCompteRenduScreen({super.key, required this.visite});

  @override
  _FormulaireCompteRenduScreenState createState() => _FormulaireCompteRenduScreenState();
}

class _FormulaireCompteRenduScreenState extends State<FormulaireCompteRenduScreen> {
  Map<String, String> reponses = {
    "Ordre de travail": "OUI",
    "Permis de travail": "OUI",
    "Attestation de consignation": "OUI",
    "Installation de chantier": "OUI",
    "Base de vie": "OUI",
    "Aire de stockage": "OUI",
  };

  List<File> selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> _submitCompteRendu(String contenu) async {
    if (widget.visite["id"] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID du compte rendu manquant")),
      );
      return;
    }

    final createdCompteRendu = await ApiService.submitCompteRendu(
      contenu,
      widget.visite["id"],
      reponses,
      selectedFiles,
    );

    if (createdCompteRendu.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte Rendu enregistré avec succès !")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ObservationsScreen(compteRendu: createdCompteRendu),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'enregistrement du compte rendu")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Organisation du chantier",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Documents d'accès au chantier", [
              "Ordre de travail",
              "Permis de travail",
              "Attestation de consignation"
            ]),
            const SizedBox(height: 25),
            _buildSection("Aménagement du chantier", [
              "Installation de chantier",
              "Base de vie",
              "Aire de stockage"
            ]),
            const SizedBox(height: 25),
            _buildFileUploadSection(),
            const SizedBox(height: 30),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800)),
            const SizedBox(width: 8),
            const Icon(Icons.info_outline, color: Colors.grey, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildDropdown(item)).toList(),
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: reponses[label],
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade700),
              border: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.blue, size: 28),
            items: ["OUI", "NON"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                reponses[label] = newValue!;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Joindre des médias", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.attach_file_rounded, color: Colors.blue),
          label: Text("Sélectionner un fichier", style: GoogleFonts.montserrat(color: Colors.blue)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blue.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedFiles.map((file) {
            return Chip(
              label: Text(file.path.split('/').last, style: GoogleFonts.montserrat()),
              deleteIcon: const Icon(Icons.close_rounded, size: 18),
              onDeleted: () {
                setState(() {
                  selectedFiles.remove(file);
                });
              },
              backgroundColor: Colors.blue.shade50,
              labelStyle: TextStyle(color: Colors.blue.shade800),
              deleteIconColor: Colors.blue.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: Colors.blue.shade700, width: 1.5),
              textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            child: const Text("Annuler"),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _submitCompteRendu("Contenu du compte rendu");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            child: const Text("Suivant"),
          ),
        ),
      ],
    );
  }
}