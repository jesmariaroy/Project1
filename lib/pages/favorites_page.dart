import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class FavoritesPage extends StatelessWidget {
  final List<String> favoriteDishes;

  FavoritesPage({required this.favoriteDishes});

  @override
  Widget build(BuildContext context) {
    final List<String> dishes =
        ModalRoute.of(context)!.settings.arguments as List<String>? ??
            favoriteDishes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: GoogleFonts.pacifico(), // Stylish font for the title
        ),
        backgroundColor: Colors.teal, // AppBar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back button
          onPressed: () {
            Navigator.pop(context); // Go back to the User Dashboard
          },
        ),
      ),
      body: dishes.isEmpty
          ? Center(
              child: Text(
                'No favorites added yet!',
                style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: ListTile(
                    title: Text(
                      dishes[index],
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold), // Stylish text
                    ),
                    trailing: Icon(Icons.favorite, color: Colors.red),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/dishDetail',
                        arguments: dishes[index],
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
