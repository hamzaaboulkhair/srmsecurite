import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart'; // Ensure this exists and has addElementDeMesure

class AddElementDeMesureScreen extends StatefulWidget {
  final int planActionId;

  const AddElementDeMesureScreen({super.key, required this.planActionId});

  @override
  State<AddElementDeMesureScreen> createState() => _AddElementDeMesureScreenState();
}

class _AddElementDeMesureScreenState extends State<AddElementDeMesureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _elementController = TextEditingController();
  final _delaisController = TextEditingController(); // This seems to be "detailsEfficacite" based on your submit method
  final _resultatController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs obligatoires.', style: GoogleFonts.montserrat())),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiService.addElementDeMesure(
        planActionId: widget.planActionId,
        elementEfficacite: _elementController.text.trim(),
        detailsEfficacite: _delaisController.text.trim(), // Ensure this matches API expectation
        resultat: _resultatController.text.trim(),
        note: int.tryParse(_noteController.text.trim()) ?? 0, // Handle potential parsing errors, default to 0 or null
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Élément de mesure ajouté avec succès !', style: GoogleFonts.montserrat())),
      );
      Navigator.pop(context, true); // Pop with success indication
    } catch (e) {
      print("Error adding element de mesure: $e"); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de l\'élément de mesure : ${e.toString()}', style: GoogleFonts.montserrat())),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _elementController.dispose();
    _delaisController.dispose();
    _resultatController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter un élément de mesure',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView for better scrollability
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column( // Use Column instead of ListView directly inside SingleChildScrollView
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Veuillez remplir les informations pour le nouvel élément de mesure.',
                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 25),

              _buildTextField(
                _elementController,
                'Élément de mesure d\'efficacité',
                hintText: 'Ex: Vérification visuelle, Test de performance',
              ),
              _buildTextField(
                _delaisController,
                'Détails de mesure / Délais', // Clarified label based on variable name
                hintText: 'Ex: Toutes les semaines, Avant le 31/12/2024',
              ),
              _buildTextField(
                _resultatController,
                'Résultat attendu',
                hintText: 'Ex: 95% de conformité, Réduction de 10% des incidents',
                maxLines: 3,
              ),
              _buildTextField(
                _noteController,
                'Note',
                isNumeric: true,
                hintText: 'Ex: 1, 2, 3, 4, 5',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'Ajout en cours...' : 'Ajouter l\'élément de mesure',
                    style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    disabledBackgroundColor: Colors.blue.shade300, // Style for disabled state
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        String? hintText,
        bool isNumeric = false,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text, // Default to text
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Increased vertical padding
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Ce champ est requis.';
          }
          if (isNumeric) {
            final int? number = int.tryParse(value.trim());
            if (number == null) {
              return 'Veuillez entrer un nombre valide.';
            }
            // Optional: Add range validation for note
            if (label == 'Note (sur 5)' && (number < 0 || number > 5)) {
              return 'La note doit être entre 0 et 5.';
            }
          }
          return null;
        },
        style: GoogleFonts.montserrat(fontSize: 15, color: Colors.blueGrey.shade900),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700, fontSize: 15),
          hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade500, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded borders
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade800, width: 2), // Blue border when focused
          ),
          filled: true,
          fillColor: Colors.grey.shade50, // Light fill color
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Increased padding inside field
        ),
      ),
    );
  }
}