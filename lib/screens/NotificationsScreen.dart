import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import '../services/api_service.dart';
import 'package:intl/intl.dart'; // Add this line

class NotificationsScreen extends StatefulWidget {
  final int userId;

  const NotificationsScreen({super.key, required this.userId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    // Mark all notifications as read when the screen initializes
    ApiService.markAllNotificationsAsRead(widget.userId);
    // Fetch notifications
    _notificationsFuture = ApiService.fetchNotificationsByUserId(widget.userId);
  }

  // Optional: Function to refresh notifications manually
  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = ApiService.fetchNotificationsByUserId(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mes Notifications",
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotifications,
            tooltip: 'Actualiser les notifications',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Erreur lors du chargement des notifications : ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(color: Colors.red.shade700, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_rounded,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Aucune nouvelle notification pour le moment.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.blue.shade700,
                    size: 30,
                  ),
                  title: Text(
                    notif['title'] ?? 'Titre inconnu',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.blueGrey.shade800),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      notif['body'] ?? 'Contenu non disponible.',
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ),
                  trailing: notif['dateEnvoi'] != null
                      ? Text(
                    _formatDate(notif['dateEnvoi']), // Use formatted date
                    style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey.shade500),
                  )
                      : null,
                  // Optional: Add onTap for notification details
                  onTap: () {
                    // You can navigate to a detail screen or show a dialog for more info
                    _showNotificationDetails(notif);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper to format date string
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime); // e.g., 15 Juin 2025
    } catch (e) {
      return dateString.substring(0, 10); // Fallback to original substring if parsing fails
    }
  }

  // Function to show notification details in a dialog
  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            notification['title'] ?? 'Détails de la Notification',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['body'] ?? 'Aucun contenu détaillé disponible.',
                  style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 15),
                Text(
                  'Date d\'envoi : ${_formatDate(notification['dateEnvoi'])}',
                  style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Fermer", style: GoogleFonts.montserrat(color: Colors.blue.shade700)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }
}