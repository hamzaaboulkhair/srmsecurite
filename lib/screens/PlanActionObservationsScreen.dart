import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class PlanActionObservationsScreen extends StatefulWidget {
  final Map<String, dynamic> visite;

  const PlanActionObservationsScreen({super.key, required this.visite});

  @override
  _PlanActionObservationsScreenState createState() => _PlanActionObservationsScreenState();
}

class _PlanActionObservationsScreenState extends State<PlanActionObservationsScreen> {
  List<dynamic> planActions = [];
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
      final actions = await ApiService.fetchPlanActionsByVisiteId(widget.visite['id']);
      setState(() {
        planActions = actions;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de charger le plan d\'action')));
      setState(() {
        _isLoading = false;
      });
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}