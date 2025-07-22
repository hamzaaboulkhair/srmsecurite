import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';

class ResponsableActionDetailScreen extends StatefulWidget {
  final int actionId;
  final Map<String, dynamic> action;

  const ResponsableActionDetailScreen({
    super.key,
    required this.actionId,
    required this.action,
  });

  @override
  State<ResponsableActionDetailScreen> createState() => _ResponsableActionDetailScreenState();
}

class _ResponsableActionDetailScreenState extends State<ResponsableActionDetailScreen> {
  final _datePrevueController = TextEditingController();
  final _dateReelleController = TextEditingController();
  final _commentaireController = TextEditingController();
  final _dateEcheanceController = TextEditingController();

  final List<File> _selectedFiles = [];
  List<dynamic> _comptesRendus = [];
  bool _isLoadingComptesRendus = true;

  @override
  void initState() {
    super.initState();
    _fetchComptesRendus();
    // Initialize text controllers with existing action data if available
    _dateEcheanceController.text = widget.action['dateEcheance'] ?? '';
    _datePrevueController.text = widget.action['datePrevueRealisation'] ?? '';
    _dateReelleController.text = widget.action['dateReelleRealisation'] ?? '';
    _commentaireController.text = widget.action['commentaire'] ?? '';
  }

  @override
  void dispose() {
    _datePrevueController.dispose();
    _dateReelleController.dispose();
    _commentaireController.dispose();
    _dateEcheanceController.dispose();
    super.dispose();
  }

    Future<void> _fetchComptesRendus() async {
    try {
      final result = await ApiService.fetchComptesRendusByPlanActionId(widget.actionId);
      setState(() {
        _comptesRendus = result;
        _isLoadingComptesRendus = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComptesRendus = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des comptes rendus: ${e.toString()}', style: GoogleFonts.montserrat())),
      );
    }
  }

  void showCompteRenduDialog(Map<String, dynamic> compteRendu) {
    final reponses = Map<String, dynamic>.from(compteRendu['reponses'] ?? {});
    final medias = compteRendu['medias'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Compte Rendu (${compteRendu['dateSoumission'] ?? 'N/A'})',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Réponses :", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (reponses.isNotEmpty)
                  ...reponses.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "${entry.key} : ${entry.value}",
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ))
                else
                  Text("Aucune réponse détaillée.", style: GoogleFonts.montserrat(fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
                const SizedBox(height: 15),
                Text("Médias :", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (medias.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: medias.map((base64) {
                      try {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(base64),
                            height: 90,
                            width: 90,
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
                        print("Error decoding image: $e"); // Debugging
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
                  Center(child: Text("Aucun média joint.", style: GoogleFonts.montserrat(fontStyle: FontStyle.italic, color: Colors.grey.shade600))),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Fermer", style: GoogleFonts.montserrat(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue.shade800, // Header background color
            colorScheme: ColorScheme.light(primary: Colors.blue.shade800), // Selected day color
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme), // Apply Montserrat to picker text
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded dialog for date picker
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectFiles() async {
    if (_selectedFiles.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vous ne pouvez pas joindre plus de 10 fichiers.", style: GoogleFonts.montserrat())),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      final newFiles = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
      if (_selectedFiles.length + newFiles.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Limite de 10 fichiers atteinte. Seuls les premiers ${10 - _selectedFiles.length} ont été ajoutés.", style: GoogleFonts.montserrat())),
        );
        // Only add up to the limit
        _selectedFiles.addAll(newFiles.take(10 - _selectedFiles.length));
      } else {
        setState(() {
          _selectedFiles.addAll(newFiles);
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_datePrevueController.text.isEmpty ||
        _dateReelleController.text.isEmpty ||
        _commentaireController.text.isEmpty ||
        _dateEcheanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs obligatoires.", style: GoogleFonts.montserrat())),
      );
      return;
    }

    List<String> base64Files = [];
    for (File file in _selectedFiles) {
      try {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        base64Files.add(base64String);
      } catch (e) {
        print("Error reading file: ${file.path}, Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du traitement d\'un fichier: ${file.path}', style: GoogleFonts.montserrat())),
        );
        return; // Stop submission if a file cannot be read
      }
    }

    final data = {
      'datePrevueRealisation': _datePrevueController.text,
      'dateReelleRealisation': _dateReelleController.text,
      'commentaire': _commentaireController.text,
      'dateEcheance': _dateEcheanceController.text,
      'realisee': true,
      'files': base64Files,
    };

    try {
      // Assuming submitActionRealisation expects a Map for files, not a List<File>
      final response = await ApiService.submitActionRealisation(
        widget.actionId,
        data,
      );

      if (response.isNotEmpty && response.containsKey('id')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action mise à jour avec succès.', style: GoogleFonts.montserrat())),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour de l\'action. Réponse inattendue.', style: GoogleFonts.montserrat())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s\'est produite lors de l\'envoi: ${e.toString()}', style: GoogleFonts.montserrat())),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label : ', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800)),
          Expanded(child: Text(value, style: GoogleFonts.montserrat())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

    return Scaffold(
      appBar: AppBar(
        title: Text('Réaliser l\'action', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20)),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Action Details Section ---
            Text('Détails de l\'action', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800)),
            const SizedBox(height: 12),
            _buildDetailRow('Responsable', action['responsable'] ?? '---'),
            _buildDetailRow('Type', action['type'] ?? '---'),
            _buildDetailRow('Action', action['action'] ?? '---'),
            _buildDetailRow('Correction immédiate', action['correctionImmediate'] ?? 'Non'),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 20),

            // --- Associated Compte Rendus Section ---
            Text('Comptes Rendus associés', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800)),
            const SizedBox(height: 15),
            _isLoadingComptesRendus
                ? const Center(child: CircularProgressIndicator())
                : _comptesRendus.isEmpty
                ? Center(child: Text('Aucun compte rendu trouvé.', style: GoogleFonts.montserrat(fontStyle: FontStyle.italic, color: Colors.grey.shade600)))
                : ListView.separated(
              physics: const NeverScrollableScrollPhysics(), // Important to prevent double scrolling
              shrinkWrap: true,
              itemCount: _comptesRendus.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(color: Colors.grey),
              ),
              itemBuilder: (context, index) {
                final compteRendu = _comptesRendus[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(
                      'Compte Rendu #${compteRendu['id'] ?? index + 1}',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.blueGrey.shade800),
                    ),
                    subtitle: Text(
                      'Soumis le : ${compteRendu['dateSoumission'] ?? 'N/A'}',
                      style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blue.shade700),
                    onTap: () => showCompteRenduDialog(compteRendu),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 20),

            // --- Planning Section ---
            Text('Planification', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
            const SizedBox(height: 15),
            TextField(
              controller: _dateEcheanceController,
              readOnly: true,
              onTap: () => _selectDate(_dateEcheanceController),
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                labelText: 'Date échéance',
                labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade800), borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade600),
              ),
            ),
            const SizedBox(height: 20),

            // --- Realization Section ---
            Text('Réalisation', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
            const SizedBox(height: 15),
            TextField(
              controller: _dateReelleController,
              readOnly: true,
              onTap: () => _selectDate(_dateReelleController),
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                labelText: 'Date réelle de réalisation',
                labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade800), borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade600),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _datePrevueController,
              readOnly: true,
              onTap: () => _selectDate(_datePrevueController),
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                labelText: 'Date prévue de réalisation',
                labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade800), borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade600),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentaireController,
              maxLines: 4,
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                labelText: 'Commentaire',
                labelStyle: GoogleFonts.montserrat(color: Colors.blueGrey.shade700),
                alignLabelWithHint: true, // Align label to top for multiline
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade800), borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // --- File Attachment Section ---
            Text('Pièces jointes', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
            const SizedBox(height: 10),
            Text("Importez jusqu'à 10 fichiers.", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _selectFiles,
              icon: const Icon(Icons.attach_file_rounded, color: Colors.white),
              label: Text("Sélectionner des fichiers", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedFiles.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _selectedFiles.map((file) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400, width: 1.5),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFiles.remove(file);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade600, // Red for delete
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2), // Smaller padding for the icon
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

            const SizedBox(height: 40),

            // --- Submit Button ---
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                label: Text(
                  'Enregistrer la réalisation',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}