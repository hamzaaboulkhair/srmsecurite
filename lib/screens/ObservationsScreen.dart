import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visite_securite/screens/details_compte_rendu_screen.dart';
import 'NouvelleActionScreen.dart';
import '../services/api_service.dart';

class ObservationsScreen extends StatefulWidget {
  final Map<String, dynamic> compteRendu;

  const ObservationsScreen({super.key, required this.compteRendu});

  @override
  _ObservationsScreenState createState() => _ObservationsScreenState();
}

class _ObservationsScreenState extends State<ObservationsScreen> {
  List<Map<String, dynamic>> planActions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlanActions();
  }

  Future<void> _fetchPlanActions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final actions = await ApiService.fetchPlanActions(widget.compteRendu['id']);
      setState(() {
        planActions = actions;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de charger les suggestions')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPlanActionItem(Map<String, dynamic> planAction) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          planAction['action'] as String? ?? 'Action non spécifiée',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.blueGrey.shade800),
        ),
        subtitle: Text(
          'Observation: ${planAction['observation'] as String? ?? 'Aucune observation'}',
          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
        onTap: () {
          // Implement navigation to edit action if needed
        },
      ),
    );
  }

  void _goBackToDetailCompteRendu() {
    Navigator.pop(context);
  }

  void _handleSecondButton() {
    // Implement functionality when ready
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Suggestions / Actions",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton.icon(
              onPressed: () async {
                final nouvelleSuggestion = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NouvelleActionScreen(
                      planAction: widget.compteRendu,
                      compteRenduId: widget.compteRendu['id'],
                    ),
                  ),
                );

                if (nouvelleSuggestion != null) {
                  _fetchPlanActions();
                }
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: Text("Ajouter", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : planActions.isEmpty
          ? Center(
        child: Text(
          "Aucune suggestion ajoutée pour l’instant.",
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade600),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: planActions.length,
        itemBuilder: (context, index) => _buildPlanActionItem(planActions[index]),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _goBackToDetailCompteRendu,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: Colors.blue.shade700, width: 1.5),
                  textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                child: const Text("Retour"),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleSecondButton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                child: const Text("Envoyer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}