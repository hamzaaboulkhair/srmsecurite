import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:visite_securite/screens/mes_visites_screen.dart';
import 'package:visite_securite/screens/home_screen.dart';
import 'package:visite_securite/screens/objet_visite_screen.dart';
import 'package:visite_securite/screens/visites_responsable_screen.dart'; // Importez l'écran Responsable

class WelcomeResponsableScreen extends StatelessWidget {
  final int userId;
  const WelcomeResponsableScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gradient Header with Logout
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bienvenue, Responsable",
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Supervisez la sécurité de vos chantiers",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>  HomeScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Items Section
          Expanded(
            child: Container(
              color: Colors.grey.shade50, // Very light grey background
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    "Planifier une visite",
                    FontAwesomeIcons.calendarPlus, // Changed icon
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  ObjetVisiteScreen()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    context,
                    "Mes visites",
                    FontAwesomeIcons.listAlt, // Changed icon
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  MesVisitesScreen()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    context,
                    "Suivi des actions", // Updated title for Responsable
                    FontAwesomeIcons.tasks, // Changed icon to represent actions
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VisitesResponsableScreen(responsableId: userId)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    context,
                    "Documentation Utile", // Updated title
                    FontAwesomeIcons.bookOpen, // Changed icon
                        () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Page Documentation à venir")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      elevation: 3, // Added subtle elevation
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: FaIcon(
                  icon,
                  color: Colors.blue.shade800,
                  size: 26,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}