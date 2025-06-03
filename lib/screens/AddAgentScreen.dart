import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class AddAgentScreen extends StatefulWidget {
  final int visiteId;

  const AddAgentScreen({super.key, required this.visiteId});

  @override
  _AddAgentScreenState createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  String? selectedFunction;
  TextEditingController otherFunctionController = TextEditingController();
  List<String> availableFunctions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableFunctions();
  }

  Future<void> fetchAvailableFunctions() async {
    try {
      final List<String> functions = await ApiService.getAvailableFunctions(); // Méthode à créer
      setState(() {
        availableFunctions = [...functions, 'Autre'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des fonctions')),
      );
    }
  }

  Future<void> _addAgent() async {
    String functionToAdd = selectedFunction == "Autre"
        ? otherFunctionController.text
        : selectedFunction ?? '';
    if (functionToAdd.isNotEmpty) {
      try {
        final response = await ApiService.addAgentFunction(widget.visiteId, functionToAdd);

        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonction de l\'agent ajoutée avec succès')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de l\'ajout de la fonction de l\'agent')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de l\'ajout de la fonction de l\'agent')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner ou entrer une fonction')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter un Agent',
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fonction de l\'agent visité',
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedFunction,
              hint: Text("Sélectionner une fonction", style: GoogleFonts.montserrat(color: Colors.grey.shade600)),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: availableFunctions.map((String function) {
                return DropdownMenuItem<String>(
                  value: function,
                  child: Text(function, style: GoogleFonts.montserrat()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFunction = value;
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedFunction == "Autre")
              TextField(
                controller: otherFunctionController,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  labelText: "Autre fonction",
                  labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                  hintText: "Entrez la fonction de l'agent",
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _addAgent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                child: const Text('Enregistrer'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  textStyle: GoogleFonts.montserrat(fontSize: 16),
                ),
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
