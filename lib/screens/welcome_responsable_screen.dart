import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:visite_securite/screens/mes_visites_screen.dart';
import 'package:visite_securite/screens/home_screen.dart';
import 'package:visite_securite/screens/objet_visite_screen.dart';
import 'package:visite_securite/screens/visites_responsable_screen.dart';

import '../services/api_service.dart';
import 'NotificationsScreen.dart'; // Importez l'écran Responsable

class WelcomeResponsableScreen extends StatefulWidget {
  final int userId;
  const WelcomeResponsableScreen({super.key, required this.userId});

  @override
  State<WelcomeResponsableScreen> createState() => _WelcomeResponsableScreenState();
}

class _WelcomeResponsableScreenState extends State<WelcomeResponsableScreen> {
  int unreadCount = 0;

  Future<void> _loadUnreadNotifications() async {
    final count = await ApiService.fetchUnreadNotificationsCount(widget.userId);
    print("🔴 Notifications non lues : $count (pour userId=${widget.userId})");
    setState(() {
      unreadCount = count;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUnreadNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          final title = message.notification!.title ?? "Notification";
          final body = message.notification!.body ?? "";

          print("📥 Notification reçue (foreground) : $title - $body");

          // Affichage dans l'app
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title\n$body")),
          );
          _loadUnreadNotifications();
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final title = message.notification?.title;
        print("📦 Notification ouverte : $title");
        // TODO : rediriger vers une page spécifique si nécessaire
      });

    });




  }



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
                  crossAxisAlignment: CrossAxisAlignment.start, // au cas où
                  children: [
                    Expanded( // 👈 Ajouté ici
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bienvenue, Responsable",
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis, // 👈 Sécurité
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Supervisez la sécurité de vos chantiers",
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
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
                      MaterialPageRoute(builder: (_) => VisitesResponsableScreen(responsableId: widget.userId)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    context,
                    "Notifications",
                    Icons.notifications_active_rounded,
                        () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(userId: widget.userId),
                        ),
                      );
                      _loadUnreadNotifications(); // Recharge le badge
                    },
                    showBadge: unreadCount > 0,
                    badgeCount: unreadCount,
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
      VoidCallback onTap, {
        bool showBadge = false,
        int badgeCount = 0,
      }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
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
              Stack(
                clipBehavior: Clip.none,
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
                  if (showBadge && badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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