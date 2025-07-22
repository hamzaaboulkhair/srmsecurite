import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import 'modifier_visite_screen.dart';
import 'toutes_mes_visites_screen.dart';

class MesVisitesScreen extends StatefulWidget {
  @override
  _MesVisitesScreenState createState() => _MesVisitesScreenState();
}

class _MesVisitesScreenState extends State<MesVisitesScreen> {
  List<Map<String, dynamic>> visitesPlanifiees = [];
  Set<int> selectedVisites = <int>{};
  bool isLoading = true;
  bool showSelection = false;

  @override
  void initState() {
    super.initState();
    _fetchVisitesPlanifiees();
  }

  Future<void> _fetchVisitesPlanifiees() async {
    try {
      setState(() => isLoading = true);

      final visites = await ApiService.fetchVisitesPlanifiees();
      final uniqueVisites = <Map<String, dynamic>>[];

      for (var visite in visites) {
        final isDuplicate = uniqueVisites.any((existingVisite) =>
        existingVisite["date"] == visite["date"] &&
            existingVisite["localisation"] == visite["localisation"] &&
            existingVisite["heureDebut"] == visite["heureDebut"] &&
            existingVisite["heureFin"] == visite["heureFin"]
        );
        if (!isDuplicate) {
          uniqueVisites.add(visite);
        }
      }

      setState(() {
        visitesPlanifiees = uniqueVisites;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading visits: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _supprimerVisites() async {
    if (selectedVisites.isEmpty) return;

    final success = await ApiService.supprimerVisites(selectedVisites.toList());

    if (success) {
      setState(() {
        visitesPlanifiees.removeWhere((visite) => selectedVisites.contains(visite["id"]));
        selectedVisites.clear();
        showSelection = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de supprimer la visite car elle a déjà été envoyée."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _modifierVisite(Map<String, dynamic> visite) async {
    final modificationEffectuee = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ModifierVisiteScreen(visite: visite)),
    );
    if (modificationEffectuee == true) {
      await _fetchVisitesPlanifiees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mes Visites",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (showSelection)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  showSelection = false;
                  selectedVisites.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(FontAwesomeIcons.trash, color: Colors.white),
              onPressed: () {
                setState(() {
                  showSelection = true;
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : visitesPlanifiees.isEmpty
          ? Center(
        child: Text(
          "Aucune visite planifiée",
          style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey.shade600),
        ),
      )
          : _buildVisitesList(),
      bottomNavigationBar: showSelection ? _buildBottomButtons() : _bottomNavigationBar(),
    );
  }

  Widget _buildVisitesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ListView.builder(
        itemCount: visitesPlanifiees.length,
        itemBuilder: (context, index) {
          final visite = visitesPlanifiees[index];
          final isSelected = selectedVisites.contains(visite["id"]);

          return GestureDetector(
            onTap: () => _modifierVisite(visite),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                leading: showSelection
                    ? Checkbox(
                  value: isSelected,
                  activeColor: Colors.blue.shade800,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedVisites.add(visite["id"] as int);
                      } else {
                        selectedVisites.remove(visite["id"] as int);
                      }
                    });
                  },
                )
                    : Icon(FontAwesomeIcons.calendarCheck, color: Colors.blue.shade800, size: 22),
                title: Text(
                  visite["date"] as String,
                  style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
                ),
                subtitle: Text(
                  "${visite["localisation"] ?? "Localisation inconnue"} - ${visite["heureDebut"]} à ${visite["heureFin"]}",
                  style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600),
                ),
                trailing: const Icon(FontAwesomeIcons.angleRight, color: Colors.grey, size: 20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  showSelection = false;
                  selectedVisites.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue.shade700, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(120, 50),
              ),
              child: Text("Annuler", style: GoogleFonts.montserrat(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: selectedVisites.isEmpty ? null : _supprimerVisites,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedVisites.isEmpty ? Colors.grey.shade400 : Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(120, 50),
                textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: const Text("Supprimer"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue.shade800,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: false,
      currentIndex: 2, // Assuming "Mes Visites" is the third item (index 2)
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context); // Navigate back to the previous screen (Accueil)
        } else if (index == 2) {
          // We are already on the "Mes Visites" screen, no need to navigate again
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ToutesMesVisitesScreen()));
        }
        // Handle other navigation items if needed
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Accueil"),
        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: "Rapports"),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded, color: Colors.blue.shade800), label: "Mes Visites"),
        const BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: "Notifications"),
        const BottomNavigationBarItem(icon: Icon(Icons.menu_outlined), label: "Menu"),
      ],
    );
  }
}