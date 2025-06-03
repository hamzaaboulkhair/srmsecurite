import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:visite_securite/services/api_service.dart';
import 'enregistrer_visite_screen.dart';

class ObjetVisiteScreen extends StatefulWidget {
  @override
  _ObjetVisiteScreenState createState() => _ObjetVisiteScreenState();
}

class _ObjetVisiteScreenState extends State<ObjetVisiteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  List<Map<String, dynamic>> objetsVisites = [];
  List<Map<String, dynamic>> filteredObjets = [];
  bool isLoading = true;
  String searchQuery = "";
  Set<Marker> _markers = {};
  final String googleApiKey = "AIzaSyCBakaxklrZ1Rh338aBsaldnZHHGy97VAo";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchObjetsVisites();
  }

  Future<void> _fetchObjetsVisites() async {
    try {
      final objets = await ApiService.fetchObjetsVisites();
      setState(() {
        objetsVisites = objets;
        filteredObjets = objets;
        isLoading = false;
        _addMarkers();
      });
    } catch (e) {
      print("Erreur : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addMarkers() {
    Set<Marker> markers = {};

    for (var objet in objetsVisites) {
      if (objet["latitude"] != null && objet["longitude"] != null) {
        markers.add(
          Marker(
            markerId: MarkerId(objet["id"].toString()),
            position: LatLng(objet["latitude"], objet["longitude"]),
            infoWindow: InfoWindow(
              title: utf8.decode(objet["localisation"].toString().codeUnits),
              snippet: "Cliquer pour choisir",
              onTap: () {
                _selectObjet(objet["id"]);
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  void _filterSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredObjets = objetsVisites
          .where((objet) => utf8
          .decode(objet["localisation"].toString().codeUnits)
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectObjet(int objetId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnregistrerVisiteScreen(objetId: objetId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Objet de visite",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade300,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.map_outlined), text: "Carte"),
            Tab(icon: Icon(Icons.list_alt_outlined), text: "Liste"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapView(),
          _buildListView(),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(33.589886, -7.603869),
            zoom: 12,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            setState(() {
              _mapController = controller;
            });
          },
        ),
        Positioned(
          top: 15,
          right: 15,
          child: FloatingActionButton(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            mini: true,
            onPressed: () {
              _fetchObjetsVisites();
            },
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: TextField(
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                hintText: "Rechercher une localisation...",
                hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              onChanged: _filterSearch,
            ),
          ),
        ),
        Expanded(
          child: filteredObjets.isEmpty
              ? Center(child: Text("Aucun objet trouvé", style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade700)))
              : ListView.builder(
            itemCount: filteredObjets.length,
            itemBuilder: (context, index) {
              final objet = filteredObjets[index];
              final int objetId = objet["id"];
              return _buildVisiteCard(
                objetId,
                utf8.decode(objet["localisation"].toString().codeUnits),
                utf8.decode(objet["natureTravaux"].toString().codeUnits),
                utf8.decode(objet["service"].toString().codeUnits),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisiteCard(int objetId, String title, String subtitle, String service) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.location_on_outlined, color: Colors.blue.shade800),
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 17, color: Colors.blueGrey.shade800),
        ),
        subtitle: Text(
          "$subtitle\nService : $service",
          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade700, size: 20),
        onTap: () {
          _selectObjet(objetId);
        },
      ),
    );
  }
}