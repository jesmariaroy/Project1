import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class FavoriteDishesPage extends StatelessWidget {
  final String userId;

  FavoriteDishesPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Dishes',
          style: GoogleFonts.pacifico(), // Stylish font for the title
        ),
        backgroundColor: Colors.teal, // AppBar color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites_menu')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final favoriteDishes = snapshot.data!.docs;

          if (favoriteDishes.isEmpty) {
            return Center(
              child: Text(
                'No favorite dishes yet.',
                style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteDishes.length,
            itemBuilder: (context, index) {
              final favoriteDoc = favoriteDishes[index];
              final data = favoriteDoc.data() as Map<String, dynamic>?;

              if (data == null ||
                  !data.containsKey('restaurantId') ||
                  !data.containsKey('dishId')) {
                return _buildErrorTile(context, favoriteDoc);
              }

              final restaurantId = data['restaurantId'];
              final dishId = data['dishId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('restaurants')
                    .doc(restaurantId)
                    .collection('menu')
                    .doc(dishId)
                    .get(),
                builder: (context, dishSnapshot) {
                  if (!dishSnapshot.hasData) {
                    return _buildLoadingTile();
                  }

                  if (!dishSnapshot.data!.exists) {
                    return _buildNotFoundTile(context, favoriteDoc);
                  }

                  final dishData =
                      dishSnapshot.data!.data() as Map<String, dynamic>;

                  return _buildDishTile(dishData, favoriteDoc);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorTile(BuildContext context, DocumentSnapshot favoriteDoc) {
    return ListTile(
      title: Text('Incomplete Favorite Data'),
      subtitle: Text('Missing restaurant or dish information.'),
      leading: Icon(Icons.error, color: Colors.red),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.grey),
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('favorites_menu')
              .doc(favoriteDoc.id)
              .delete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid favorite removed.')),
          );
        },
      ),
    );
  }

  Widget _buildLoadingTile() {
    return ListTile(
      title: Text('Loading...'),
      leading: CircularProgressIndicator(),
    );
  }

  Widget _buildNotFoundTile(
      BuildContext context, DocumentSnapshot favoriteDoc) {
    return ListTile(
      title: Text('Dish Not Found'),
      subtitle: Text('This dish might have been removed.'),
      leading: Icon(Icons.error_outline, color: Colors.orange),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.grey),
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('favorites_menu')
              .doc(favoriteDoc.id)
              .delete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid favorite removed.')),
          );
        },
      ),
    );
  }

  Widget _buildDishTile(
      Map<String, dynamic> dishData, DocumentSnapshot favoriteDoc) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: ListTile(
        leading: dishData.containsKey('image')
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(dishData['image'],
                    width: 50, height: 50, fit: BoxFit.cover),
              )
            : Icon(Icons.fastfood, size: 50),
        title: Text(
          dishData['name'],
          style: GoogleFonts.lato(fontWeight: FontWeight.bold), // Stylish text
        ),
        subtitle: Text('Price: \$${dishData['price']}',
            style: GoogleFonts.lato(color: Colors.grey[700])),
      ),
    );
  }
}
