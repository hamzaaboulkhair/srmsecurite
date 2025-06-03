import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visite_securite/screens/CompteRenduByVisiteScreen.dart';
import 'NouvelleActionScreen.dart';
import 'ObservationsScreen.dart';
import 'PlanActionObservationsScreen.dart';
import 'details_objet_visite_screen.dart';
import 'details_visiteurs_screen.dart';
import 'formulaire_compte_rendu_screen.dart';
import 'AgentVisitedScreen.dart';
import '../services/api_service.dart';

class DetailsCompteRenduScreen extends StatefulWidget {
  final Map<String, dynamic> visite;

  const DetailsCompteRenduScreen({super.key, required this.visite});

  @override
  _DetailsCompteRenduScreenState createState() => _DetailsCompteRenduScreenState();
}

class _DetailsCompteRenduScreenState extends State<DetailsCompteRenduScreen> {
  late int currentStep;

  @override
  void initState() {
    super.initState();
    _setStepBasedOnStatus();
  }

  void _setStepBasedOnStatus() {
    final etat = widget.visite["etat"] as String? ?? "Planifiee";
    print("Visite etat: $etat");

    switch (etat) {
      case "envoye":
        currentStep = 1;
        break;
      case "cloture":
        currentStep = 2;
        break;
      case "realise":
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }
  }

  void _navigateToAgentVisitedScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentVisitedScreen(visite: widget.visite),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Détails du rapport",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepProgressBar(),
            const SizedBox(height: 25),
            _buildVisitDetails(),
            const SizedBox(height: 30),
            _buildOptionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepProgressBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stepIndicator("Planifiee", 0),
        _stepIndicator("envoye", 1),
        _stepIndicator("cloture", 2),
        _stepIndicator("realise", 3),
      ],
    );
  }

  Widget _stepIndicator(String label, int step) {
    final isActive = step == currentStep;
    return Column(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: isActive ? Colors.blue.shade800 : Colors.grey.shade400,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.blueGrey.shade800 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildVisitDetails() {
    final dateVisite = widget.visite["date"] as String? ?? "Date inconnue";
    final heureDebut = widget.visite["heureDebut"] as String? ?? "--:--";
    final heureFin = widget.visite["heureFin"] as String? ?? "--:--";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Détails de la Visite",
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  dateVisite,
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "$heureDebut - $heureFin",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    final options = [
      {"title": "Objet de la visite", "icon": Icons.location_on_outlined},
      {"title": "Données des visiteurs", "icon": Icons.people_outline},
      {"title": "Données des agents visités", "icon": Icons.person_outline},
      {"title": "Formulaire du rapport", "icon": Icons.assignment_outlined},
      {"title": "Observations / Suggestions", "icon": Icons.lightbulb_outline},
      {"title": "Plan d'action", "icon": Icons.check_box_outlined},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final option = options[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(option["icon"] as IconData?, color: Colors.blue.shade700),
            title: Text(
              option["title"] as String,
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 20),
            onTap: () {
              final title = option["title"];
              if (title == "Objet de la visite") {
                if (widget.visite["objetVisite"] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsObjetVisiteScreen(objetVisite: widget.visite["objetVisite"]),
                    ),
                  );
                } else {
                  _showError("Aucune donnée disponible pour l'objet de la visite");
                }
              } else if (title == "Données des visiteurs") {
                if (widget.visite["participants"] != null && (widget.visite["participants"] as List).isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsVisiteursScreen(visiteurs: widget.visite["participants"]),
                    ),
                  );
                } else {
                  _showError("Aucun visiteur trouvé pour cette visite");
                }
              } else if (title == "Données des agents visités") {
                _navigateToAgentVisitedScreen();
              } else if (title == "Formulaire du rapport") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormulaireCompteRenduScreen(visite: widget.visite),
                  ),
                );
              } else if (title == "Observations / Suggestions") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompteRenduByVisiteScreen(
                      visiteId: widget.visite['id'] ,
                    ),
                  ),
                );
              } else if (title == "Plan d'action") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlanActionObservationsScreen(visite: widget.visite),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }
}