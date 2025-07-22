import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/api_service.dart';
import 'mes_visites_screen.dart';

class EnregistrerVisiteScreen extends StatefulWidget {
  final int objetId;

  const EnregistrerVisiteScreen({super.key, required this.objetId});

  @override
  _EnregistrerVisiteScreenState createState() => _EnregistrerVisiteScreenState();
}

class _EnregistrerVisiteScreenState extends State<EnregistrerVisiteScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedHeureDebut;
  TimeOfDay? selectedHeureFin;
  List<String> participants = [];
  String? selectedParticipant;
  List<String> utilisateurs = [];

  @override
  void initState() {
    super.initState();
    _fetchUtilisateurs();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants() async {
    try {
      final participantsList = await ApiService.fetchParticipants(widget.objetId);
      setState(() {
        participants = participantsList.map<String>((p) => p["nom"] as String).toList();
      });
    } catch (e) {
      print("Erreur lors du chargement des participants: $e");
    }
  }

  Future<void> _fetchUtilisateurs() async {
    try {
      final users = await ApiService.fetchUtilisateurs();
      setState(() {
        utilisateurs = users.map<String>((user) => user["nom"] as String).toList();
      });
    } catch (e) {
      print("Erreur de récupération des utilisateurs: $e");
    }
  }

  void _submitVisite() async {
    if (selectedHeureDebut == null || selectedHeureFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une heure de début et une heure de fin !")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('id');
    final String? role = prefs.getString('role');

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non authentifié")),
      );
      return;
    }

    final String formattedHeureDebut =
        "${selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${selectedHeureDebut!.minute.toString().padLeft(2, '0')}";
    final String formattedHeureFin =
        "${selectedHeureFin!.hour.toString().padLeft(2, '0')}:${selectedHeureFin!.minute.toString().padLeft(2, '0')}";

    final Map<String, dynamic> visiteData = {
      "date": selectedDate.toIso8601String().split("T")[0],
      "heureDebut": formattedHeureDebut,
      "heureFin": formattedHeureFin,
      "etat": "Planifiee",
      "objetVisite": {"id": widget.objetId},
      "participants": participants.map((e) => {"nom": e}).toList(),
      "utilisateurId": id,
      "role": role
    };

    final bool success = await ApiService.enregistrerVisite(visiteData);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Visite enregistrée avec succès !")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MesVisitesScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'enregistrement.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Planifier une Visite",
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(),
            const SizedBox(height: 25),
            _buildTimePickers(),
            const SizedBox(height: 25),
            _buildParticipantsSection(),
            const SizedBox(height: 35),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: selectedDate,
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          calendarFormat: CalendarFormat.month,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              selectedDate = selectedDay;
            });
          },
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: GoogleFonts.montserrat(
                fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blue.shade800),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(color: Colors.blue.shade800, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: Colors.blue.shade300.withOpacity(0.8), shape: BoxShape.circle),
            defaultTextStyle: GoogleFonts.montserrat(),
            weekendTextStyle: GoogleFonts.montserrat(color: Colors.red.shade400),
            selectedTextStyle: GoogleFonts.montserrat(color: Colors.white),
            todayTextStyle: GoogleFonts.montserrat(color: Colors.white),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
            weekendStyle: GoogleFonts.montserrat(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickers() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sélectionner l'heure", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimePickerButton("Début", selectedHeureDebut, (time) {
                  setState(() {
                    selectedHeureDebut = time;
                  });
                }),
                _buildTimePickerButton("Fin", selectedHeureFin, (time) {
                  setState(() {
                    selectedHeureFin = time;
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerButton(String title, TimeOfDay? selectedTime, Function(TimeOfDay) onTimePicked) {
    return ElevatedButton(
      onPressed: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Colors.blue.shade50,
                  dialBackgroundColor: Colors.blue.shade100,
                  hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected) ? Colors.white : Colors.blue.shade800),
                  dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected) ? Colors.white : Colors.blue.shade800),
                  dialTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected) ? Colors.white : Colors.blue.shade800),
                  entryModeIconColor: Colors.blue.shade800,
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                colorScheme: ColorScheme.light(
                  primary: Colors.blue.shade800,
                  onPrimary: Colors.white,
                  surface: Colors.blue.shade50,
                  onSurface: Colors.blue.shade800,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade800,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onTimePicked(picked);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
      child: Text(
        selectedTime == null ? "$title" : selectedTime.format(context),
        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ajouter des Participants", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    child: DropdownButtonFormField<String>(
                      value: selectedParticipant,
                      style: GoogleFonts.montserrat(),
                      decoration: InputDecoration(
                        hintText: "Nom du participant",
                        hintStyle: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      items: utilisateurs.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: GoogleFonts.montserrat(color: Colors.black)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedParticipant = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (selectedParticipant != null && !participants.contains(selectedParticipant)) {
                      setState(() {
                        participants.add(selectedParticipant!);
                        selectedParticipant = null;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(14),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: participants.map((participant) {
                return Chip(
                  label: Text(participant, style: GoogleFonts.montserrat()),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      participants.remove(participant);
                    });
                  },
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: GoogleFonts.montserrat(color: Colors.blue.shade800),
                  deleteIconColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _submitVisite,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            child: const Text("Enregistrer"),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: Colors.blue.shade700, width: 1.5),
              textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            child: const Text("Annuler"),
          ),
        ),
      ],
    );
  }

}