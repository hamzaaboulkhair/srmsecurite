import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'AddAgentScreen.dart';

class AgentVisitedScreen extends StatefulWidget {
  final Map<String, dynamic> visite;

  const AgentVisitedScreen({super.key, required this.visite});

  @override
  _AgentVisitedScreenState createState() => _AgentVisitedScreenState();
}

class _AgentVisitedScreenState extends State<AgentVisitedScreen> {
  List<String> agentFunctions = [];
  List<int> functionIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAgentFunctions();
  }

  Future<void> _fetchAgentFunctions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final functions = await ApiService.fetchAgentFunctions(widget.visite['id']);
      setState(() {
        agentFunctions = functions.map((function) => function['functionName'] as String).toList();
        functionIds = functions.map((function) => function['id'] as int).toList();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de charger les agents visités')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAddAgentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAgentScreen(visiteId: widget.visite['id']),
      ),
    ).then((result) {
      if (result != null && result == true) {
        _fetchAgentFunctions();
      }
    });
  }

  Future<void> _deleteAgentFunction(int index) async {
    try {
      final functionId = functionIds[index];
      final success = await ApiService.deleteAgentFunction(widget.visite['id'], functionId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agent supprimé avec succès')));
        _fetchAgentFunctions();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la suppression de l\'agent')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agents Visités',
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 28),
            onPressed: _navigateToAddAgentScreen,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : agentFunctions.isEmpty
          ? Center(
        child: Text(
          'Aucun agent visité pour le moment',
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade600),
        ),
      )
          : ListView.separated(
        itemCount: agentFunctions.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(
              agentFunctions[index],
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              onPressed: () => _deleteAgentFunction(index),
            ),
            onTap: () {
              // Handle tapping if needed
            },
          );
        },
      ),
    );
  }
}