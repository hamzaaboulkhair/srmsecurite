import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart'; // à créer pour faire le POST

class AddElementDeMesureScreen extends StatefulWidget {
  final int planActionId;

  AddElementDeMesureScreen({required this.planActionId});

  @override
  _AddElementDeMesureScreenState createState() => _AddElementDeMesureScreenState();
}

class _AddElementDeMesureScreenState extends State<AddElementDeMesureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _elementController = TextEditingController();
  final _delaisController = TextEditingController();
  final _resultatController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiService.addElementDeMesure(
        planActionId: widget.planActionId,
        elementEfficacite: _elementController.text,
        detailsEfficacite: _delaisController.text,
        resultat: _resultatController.text,
        note: int.parse(_noteController.text),
      );
      Navigator.pop(context, true); // retour avec succès
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'ajout')));
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
        title: Text('Ajouter un élément de mesure', style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_elementController, 'Élément de mesure d\'efficacité'),
              _buildTextField(_delaisController, 'Délais de mesure d\'efficacité'),
              _buildTextField(_resultatController, 'Résultat'),
              _buildTextField(_noteController, 'Note', isNumeric: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Envoi...' : 'Ajouter'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
