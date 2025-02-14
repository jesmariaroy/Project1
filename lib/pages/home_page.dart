import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart'; // Correctly imported
import 'registration_page.dart'; // Correctly imported

void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StylishHomePage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
      },
    );
  }
}

class StylishHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Zoom-In Effect
          Positioned.fill(
            child: Image.asset(
              'assets/images/burger.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay Gradient for Contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Hero Text
                AnimatedText(
                  text: 'Foodie Delights',
                  style: GoogleFonts.pacifico(
                    textStyle: TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                  delay: 300,
                ),
                SizedBox(height: 10),
                // Animated Subtitle
                AnimatedText(
                  text: 'A Paradise of Flavors',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  delay: 600,
                ),
                SizedBox(height: 40),
                // Glassmorphic Button for Register
                GlassMorphicButton(
                  text: 'Create Account',
                  icon: Icons.person_add,
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
                SizedBox(height: 20),
                // Glassmorphic Button for Login
                GlassMorphicButton(
                  text: 'Login',
                  icon: Icons.login,
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Animated Text Widget
class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int delay;

  const AnimatedText({
    required this.text,
    required this.style,
    required this.delay,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Text(text, style: style),
    );
  }
}

// Glassmorphic Button
class GlassMorphicButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const GlassMorphicButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
