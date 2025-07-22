import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:visite_securite/screens/home_screen.dart';
import 'package:visite_securite/screens/mes_visites_screen.dart';
import 'package:visite_securite/screens/NotificationsScreen.dart';
import 'objet_visite_screen.dart';
import '../services/api_service.dart';

class WelcomeVisitorScreen extends StatefulWidget {
  final int userId;

  const WelcomeVisitorScreen({super.key, required this.userId});

  @override
  State<WelcomeVisitorScreen> createState() => _WelcomeVisitorScreenState();
}

class _WelcomeVisitorScreenState extends State<WelcomeVisitorScreen> {
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

    // 🔔 Notification FCM temps réel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          final title = message.notification!.title ?? "Notification";
          final body = message.notification!.body ?? "";

          print("📥 Notification reçue : $title - $body");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title\n$body")),
          );

          _loadUnreadNotifications();
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("📦 Notification ouverte : ${message.notification?.title}");
        // TODO: naviguer vers une page précise si nécessaire
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER
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
                          "Bienvenue, Visiteur",
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Gérez vos visites facilement",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
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
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // MENU ITEMS
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    "Planifier une visite",
                    FontAwesomeIcons.calendarPlus,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => ObjetVisiteScreen())),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    context,
                    "Mes visites",
                    FontAwesomeIcons.listAlt,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => MesVisitesScreen())),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    context,
                    "Notifications",
                    FontAwesomeIcons.bell,
                        () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NotificationsScreen(userId: widget.userId)),
                      );
                      _loadUnreadNotifications();
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
                    child: FaIcon(icon, color: Colors.blue.shade800, size: 26),
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
