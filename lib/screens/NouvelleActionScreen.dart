import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visite_securite/services/api_service.dart';
import 'ObservationsScreen.dart';

class NouvelleActionScreen extends StatefulWidget {
  final Map<String, dynamic> planAction;
  final int compteRenduId;

  const NouvelleActionScreen({super.key, required this.planAction, required this.compteRenduId});

  @override
  _NouvelleActionScreenState createState() => _NouvelleActionScreenState();
}

class _NouvelleActionScreenState extends State<NouvelleActionScreen> {
  final _formKey = GlobalKey<FormState>();

  String observation = '';
  String type = '';
  String action = '';
  String correctionImmediate = '';
  String responsable = '';

  @override
  void initState() {
    super.initState();
    observation = widget.planAction['observation'] as String? ?? '';
  }

  Future<void> _submitPlanAction() async {
    if (_formKey.currentState!.validate()) {
      final success = await ApiService.submitPlanAction(
        observation,
        widget.compteRenduId,
        type,
        correctionImmediate,
        action,
        responsable,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Action ajoutée avec succès")),
        );
        Navigator.pop(context, true); // Indicate success when popping
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'ajout de l'action")),
        );
      }
    }
  }

  Widget _buildTextField(String label, Function(String) onChanged, {String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        style: GoogleFonts.montserrat(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(fontSize: 16, color: Colors.blueGrey.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade800), borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label est requis';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue.shade700,
            textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          child: const Text("Annuler"),
        ),
        const SizedBox(width: 120),
        ElevatedButton(
          onPressed: _submitPlanAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
          ),
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nouvelle Suggestion",
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Observation", (val) => observation = val, initialValue: observation),
              _buildTextField("Type", (val) => type = val),
              _buildTextField("Action", (val) => action = val),
              _buildTextField("Correction Immédiate", (val) => correctionImmediate = val),
              _buildTextField("Responsable", (val) => responsable = val),
              const Spacer(),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }
}