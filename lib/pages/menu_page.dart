import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorite_dishes_page.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class MenuPage extends StatefulWidget {
  final String restaurantId;
  final String userId;

  MenuPage({required this.restaurantId, required this.userId});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot>? _menuItems;
  List<String> _favoriteDishIds = [];

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
    _fetchFavoriteDishes();
  }

  Future<void> _fetchMenuItems() async {
    try {
      final snapshot = await _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menu')
          .get();

      setState(() {
        _menuItems = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load menu items: $e')),
      );
    }
  }

  Future<void> _fetchFavoriteDishes() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('favorites_menu')
          .get();

      setState(() {
        _favoriteDishIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load favorite dishes: $e')),
      );
    }
  }

  Future<void> _toggleFavoriteDish(
      String dishId, Map<String, dynamic> dishData) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('favorites_menu')
          .doc(dishId);

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
        _favoriteDishIds.remove(dishId);
      } else {
        await docRef.set({
          'timestamp': FieldValue.serverTimestamp(),
          'restaurantId': widget.restaurantId,
          'dishId': dishId,
          ...dishData, // Store additional dish data
        });
        _favoriteDishIds.add(dishId);
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu',
          style: GoogleFonts.pacifico(
              color: Colors.white), // Set title text color to white
        ),
        backgroundColor: Colors.teal, // AppBar color
      ),
      body: _menuItems == null
          ? Center(child: CircularProgressIndicator())
          : _menuItems!.isEmpty
              ? Center(child: Text('No menu items available.'))
              : ListView.builder(
                  itemCount: _menuItems!.length,
                  itemBuilder: (context, index) {
                    final menuItem = _menuItems![index];
                    final dishId = menuItem.id;
                    final isFavorite = _favoriteDishIds.contains(dishId);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                      child: ListTile(
                        leading: menuItem['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  menuItem['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.fastfood, size: 50),
                        title: Text(
                          menuItem['name'],
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold), // Stylish text
                        ),
                        subtitle: Text(
                          'Price: \$${menuItem['price']}',
                          style: GoogleFonts.lato(
                              color: Colors.grey[700]), // Stylish price text
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () => _toggleFavoriteDish(
                            dishId,
                            menuItem.data()
                                as Map<String, dynamic>, // Explicit cast
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.favorite),
        backgroundColor: Colors.teal, // Floating button color
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoriteDishesPage(userId: widget.userId),
            ),
          );
        },
      ),
    );
  }
}
