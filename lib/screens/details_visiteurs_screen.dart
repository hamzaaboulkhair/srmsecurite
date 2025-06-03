import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'DetailsParticipantScreen.dart';

class DetailsVisiteursScreen extends StatefulWidget {
  final List<dynamic> visiteurs;

  const DetailsVisiteursScreen({super.key, required this.visiteurs});

  @override
  _DetailsVisiteursScreenState createState() => _DetailsVisiteursScreenState();
}

class _DetailsVisiteursScreenState extends State<DetailsVisiteursScreen> {
  List<Map<String, dynamic>> uniqueVisiteurs = [];
  Set<int> selectedVisiteurs = <int>{};
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _removeDuplicates();
  }

  void _removeDuplicates() {
    final seenIds = <int>{};
    uniqueVisiteurs = widget.visiteurs
        .map<Map<String, dynamic>>((v) => Map<String, dynamic>.from(v))
        .where((visiteur) {
      if (visiteur.containsKey("id") && seenIds.add(visiteur["id"] as int)) {
        return true;
      }
      return false;
    }).toList();
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      selectedVisiteurs.clear();
      if (selectAll) {
        for (var i = 0; i < uniqueVisiteurs.length; i++) {
          selectedVisiteurs.add(i);
        }
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedVisiteurs.contains(index)) {
        selectedVisiteurs.remove(index);
      } else {
        selectedVisiteurs.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Participants",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: uniqueVisiteurs.length,
                itemBuilder: (context, index) {
                  final visiteur = uniqueVisiteurs[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        "${visiteur["prenom"] ?? ''} ${visiteur["nom"] ?? 'Nom inconnu'}",
                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
                      ),
                      subtitle: Text(
                        "Type: ${visiteur["type"] ?? 'Type inconnu'}",
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsParticipantScreen(participant: uniqueVisiteurs[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}