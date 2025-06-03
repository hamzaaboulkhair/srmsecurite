import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Visite managériale de sécurité",
          style: TextStyle(color: Colors.white), // ✅ White text color
        ),
        backgroundColor: Colors.blue.shade900, // Background color remains blue
        iconTheme: IconThemeData(color: Colors.white), // ✅ Makes icons white
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white), // ✅ White icon
            onPressed: () {
              // TODO: Add notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white), // ✅ White icon
            onPressed: () {
              // TODO: Add info page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Accueil Visiteur",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  _menuItem("Planifier une visite", Icons.calendar_today),
                  _divider(),
                  _menuItem("Mes visites", Icons.list),
                  _divider(),
                  _menuItem("Documentation", Icons.folder),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade900),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600),
      onTap: () {
        // TODO: Add navigation
      },
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade300);
  }
}
