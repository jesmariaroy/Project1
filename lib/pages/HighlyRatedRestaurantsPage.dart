import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'restaurant_details_page.dart';

class HighlyRatedRestaurantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Highly Rated Restaurants', style: GoogleFonts.pacifico()),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .where('rating',
                isGreaterThan: 4.0) // Filter for highly rated restaurants
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final restaurants = snapshot.data!.docs;

          if (restaurants.isEmpty) {
            return Center(child: Text('No highly rated restaurants found.'));
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              final data = restaurant.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(data['name'] ?? 'Unknown Name',
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${data['description'] ?? 'No description'}',
                    style: GoogleFonts.lato(),
                  ),
                  leading: data['image'] != null
                      ? ClipOval(
                          child: Image.network(data['image'],
                              width: 50, height: 50, fit: BoxFit.cover),
                        )
                      : Icon(Icons.restaurant),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailsPage(
                          restaurantId: restaurant.id,
                          restaurantName: data['name'],
                          restaurantImage: data['image'],
                          restaurantDescription: data['description'],
                          userId: '', // Pass the userId if needed
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
