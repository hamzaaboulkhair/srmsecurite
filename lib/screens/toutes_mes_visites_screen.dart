import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'details_compte_rendu_screen.dart';

class ToutesMesVisitesScreen extends StatefulWidget {
  @override
  _ToutesMesVisitesScreenState createState() => _ToutesMesVisitesScreenState();
}

class _ToutesMesVisitesScreenState extends State<ToutesMesVisitesScreen> {
  List<Map<String, dynamic>> visites = [];
  List<Map<String, dynamic>> filteredVisites = [];
  bool isLoading = true;
  String selectedFilter = "Tout";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVisites();
  }

  Future<void> _fetchVisites() async {
    try {
      final data = await ApiService.fetchToutesVisites();
      final uniqueVisites = <Map<String, dynamic>>[];
      for (var visite in data) {
        final isDuplicate = uniqueVisites.any((existingVisite) =>
        existingVisite["date"] == visite["date"] &&
            existingVisite["localisation"] == visite["localisation"] &&
            existingVisite["heureDebut"] == visite["heureDebut"] &&
            existingVisite["heureFin"] == visite["heureFin"]);
        if (!isDuplicate) {
          uniqueVisites.add(visite);
        }
      }
      setState(() {
        visites = uniqueVisites;
        filteredVisites = uniqueVisites;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading visits: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == "Tout") {
        filteredVisites = visites;
      } else {
        filteredVisites = visites.where((visite) => visite["etat"] == filter).toList();
      }
    });
  }

  void _searchVisites(String query) {
    setState(() {
      filteredVisites = visites.where((visite) {
        final location = visite["localisation"] ?? "";
        return location.toLowerCase().contains(query.toLowerCase());
      }).toList();

      if (selectedFilter != "Tout") {
        filteredVisites = filteredVisites.where((visite) => visite["etat"] == selectedFilter).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Toutes mes visites",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredVisites.isEmpty
                ? Center(
              child: Text(
                "Aucune visite trouvée",
                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade600),
              ),
            )
                : _buildVisitesList(),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterButton("Tout"),
            const SizedBox(width: 10),
            _filterButton("Planifiee"),
            const SizedBox(width: 10),
            _filterButton("envoye"),
            const SizedBox(width: 10),
            _filterButton("cloture"),
            const SizedBox(width: 10),
            _filterButton("realise")
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () => _applyFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade800 : Colors.white,
          border: Border.all(color: Colors.blue.shade800),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          filter,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.blue.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(25),
        child: TextField(
          controller: searchController,
          onChanged: _searchVisites,
          style: GoogleFonts.montserrat(),
          decoration: InputDecoration(
            hintText: "Rechercher une localisation...",
            hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
      ),
    );
  }

  Widget _buildVisitesList() {
    return ListView.builder(
      itemCount: filteredVisites.length,
      itemBuilder: (context, index) {
        final visite = filteredVisites[index];
        final etat = visite["etat"] ?? "État inconnu";

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            title: Text(
              visite["localisation"] ?? "Localisation inconnue",
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 17, color: Colors.blueGrey.shade800),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Prévue le : ${visite["date"]}",
                  style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600),
                ),
                _statusLabel(etat),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsCompteRenduScreen(visite: visite),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _statusLabel(String status) {
    Color color;
    switch (status) {
      case "Planifiee":
        color = Colors.orange.shade600;
        break;
      case "envoye":
        color = Colors.blue.shade600;
        break;
      case "cloture":
        color = Colors.green.shade600;
        break;
      case "realise":
        color = Colors.red.shade600;
        break;
      default:
        color = Colors.grey.shade600;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        status,
        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue.shade800,
      unselectedItemColor: Colors.grey.shade600,
      currentIndex: 2, // "Mes visites" is active
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context); // Back to previous screen
        }
        // Handle other navigation if needed
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Accueil"),
        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: "Rapports"),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded, color: Colors.blue.shade800), label: "Mes visites"),
        const BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: "Notifications"),
        const BottomNavigationBarItem(icon: Icon(Icons.menu_outlined), label: "Menu"),
      ],
    );
  }

  String _decodeText(dynamic text) {
    if (text == null) return "Non disponible";
    return utf8.decode(text.toString().codeUnits, allowMalformed: true);
  }
}