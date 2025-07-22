import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For subtle animations
import 'package:google_fonts/google_fonts.dart'; // Import the google_fonts package
import 'signup_screen.dart'; // Écran d'inscription
import 'login_screen.dart'; // Écran après connexion

class HomeScreen extends StatelessWidget {
  // Define consistent text styles with Montserrat
  static TextStyle titleTextStyle(BuildContext context) => GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.w600, // Slightly bolder
    letterSpacing: 1.1,
    color: Colors.blueGrey, // A more sophisticated blue
  );

  static TextStyle buttonTextStyle(BuildContext context) => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Semi-bold for emphasis
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Stack(
        children: [
          // Subtle patterned background (optional, can be removed)
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/images/white_pattern_background.jpg", // Replace with your pattern image or remove
                repeat: ImageRepeat.repeat,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Elevated and slightly larger image with rounded corners
                  Container(
                    margin: const EdgeInsets.only(bottom: 40, top: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/srm_background.jpg",
                        height: 300,
                        width: MediaQuery.of(context).size.width * 0.85,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate().slideY(duration: const Duration(milliseconds: 500), begin: -0.1, end: 0),


                // Logo with a refined shadow
                Container(
                  margin: EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset("assets/images/srm_logo.png", height: 100),
                ).animate().scale(duration: const Duration(milliseconds: 600)), // Subtle scale-in animation

                // Elegant title text with Montserrat
                Text(
                  "SRM Casablanca-Settat",
                  style: titleTextStyle(context), // Using the defined text style with context
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 50),

                // Primary Action Button (Se connecter) with Montserrat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blue.shade300,
                      textStyle: buttonTextStyle(context).copyWith(color: Colors.white), // Applying and customizing
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text("Se connecter"),
                  ).animate().fade(duration: const Duration(milliseconds: 700)), // Subtle fade-in animation
                ),

                const SizedBox(height: 20),

                // Secondary Action Button (S'inscrire) with Montserrat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      side: BorderSide(color: Colors.blue.shade700, width: 2),
                      textStyle: buttonTextStyle(context).copyWith(color: Colors.blue.shade700), // Applying and customizing
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text("S'inscrire"),
                  ).animate().fade(duration: const Duration(milliseconds: 800), delay: const Duration(milliseconds: 100)), // Subtle delayed fade-in
                ),

                const SizedBox(height: 40),

                // Optional: "Continue as guest" button or text
                // You can add this here with similar styling if needed.
              ],
            ),
          ),
          ),],
      ),
    );
  }
}