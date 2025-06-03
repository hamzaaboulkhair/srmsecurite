import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visite_securite/screens/ApsActionScreen.dart';
import '../services/api_service.dart';

class VisitesApsScreen extends StatefulWidget {
  final int apsId;

  const VisitesApsScreen({super.key, required this.apsId});

  @override
  _VisitesApsScreenState createState() => _VisitesApsScreenState();
}

class _VisitesApsScreenState extends State<VisitesApsScreen> {
  List<dynamic> _visites = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = "Tout";

  @override
  void initState() {
    super.initState();
    _loadVisites();
  }

  Future<void> _loadVisites() async {
    try {
      setState(() => _isLoading = true);
      final data = await ApiService.fetchVisitesByAps(widget.apsId);
      setState(() {
        _visites = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    }
  }

  List<dynamic> get _filteredVisites {
    return _visites.where((visite) {
      final localisation = visite['objetVisite']?['localisation']?.toString().toLowerCase() ?? '';
      final matchesSearch = localisation.contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == "Tout" || visite['etat'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mes Visites APS",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVisites.isEmpty
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        style: GoogleFonts.montserrat(),
        decoration: InputDecoration(
          hintText: "Rechercher par localisation...",
          hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade800),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["Tout", "Planifiee", "envoye", "cloture", "realise"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(filter, style: GoogleFonts.montserrat(color: _selectedFilter == filter ? Colors.white : Colors.blueGrey.shade800)),
                selected: _selectedFilter == filter,
                onSelected: (selected) => setState(() => _selectedFilter = selected ? filter : "Tout"),
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.blue.shade300),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVisitesList() {
    return ListView.builder(
      itemCount: _filteredVisites.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final visite = _filteredVisites[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              visite['objetVisite']?['localisation'] as String? ?? 'Localisation inconnue',
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: ${visite['date'] as String? ?? 'Date inconnue'}",
                  style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  "État: ${visite['etat'] as String? ?? 'État inconnu'}",
                  style: GoogleFonts.montserrat(fontSize: 14, color: _getStatusColor(visite['etat'])),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
            onTap: () {
        final etat = visite['etat']?.toLowerCase();

        if (etat == 'envoye' || etat == 'cloture') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApsActionscreen(visite: visite),
                ),
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Vous ne pouvez accéder aux actions que si la visite est envoyé ou réalisée."),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
            },
          ),
        );
      },
    );
  }


  Color _getStatusColor(String? etat) {
    switch (etat) {
      case "Planifiee":
        return Colors.orange.shade700;
      case "envoye":
        return Colors.blue.shade700;
      case "cloture":
        return Colors.green.shade700;
      case "realise":
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}