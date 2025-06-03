import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'ApsActionDetailScreen.dart';

class ApsActionscreen extends StatefulWidget {
  final Map<String, dynamic> visite;

  const ApsActionscreen({super.key, required this.visite});

  @override
  _ApsActionScreenState createState() => _ApsActionScreenState();
}

class _ApsActionScreenState extends State<ApsActionscreen> {
  List<Map<String, dynamic>> planActions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlanActions();
  }

  Future<void> _fetchPlanActions() async {
    try {
      setState(() => _isLoading = true);
      final actions = await ApiService.fetchPlanActionsByvisite(widget.visite['id']);
      setState(() {
        planActions = actions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de charger le plan d\'action')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plan d\'action',
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : planActions.isEmpty
          ? Center(
        child: Text(
          'Aucune action planifiée pour cette visite.',
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade600),
        ),
      )
          : ListView.builder(
        itemCount: planActions.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final action = planActions[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApsActionDetailScreen(action: action),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action['action'] as String? ?? 'Action non spécifiée',
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Observation: ${action['observation'] as String? ?? 'Aucune observation'}',
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Responsable: ${action['responsable'] as String? ?? 'Non assigné'}',
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Statut: ${action['statut'] as String? ?? 'Non défini'}',
                      style: GoogleFonts.montserrat(fontSize: 14, color: _getStatusColor(action['statut'])),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? statut) {
    switch (statut) {
      case "Ouvert":
        return Colors.orange.shade700;
      case "En cours":
        return Colors.blue.shade700;
      case "Terminé":
        return Colors.green.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}