import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'ImageDisplayPage.dart'; // Import the new image display page
import 'menu_page.dart';
import 'user_table_booking_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase is initialized
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class RestaurantDetailsPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final String restaurantDescription;
  final String userId;

  RestaurantDetailsPage({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.restaurantDescription,
    required this.userId,
  });

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  String? _restaurantAddress; // Variable to hold the restaurant address

  @override
  void initState() {
    super.initState();
    _fetchRating();
    _fetchAddress(); // Fetch the address when the page initializes
  }

  // Fetch the restaurant's rating from Firestore
  Future<void> _fetchRating() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        _rating = docSnapshot['rating'] ?? 0;
      });
    }
  }

  // Fetch the restaurant's address from Firestore
  Future<void> _fetchAddress() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        _restaurantAddress = docSnapshot['address']; // Get the address
      });
    }
  }

  // Save the user's rating to Firestore
  Future<void> _submitRating(double rating) async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .update({
      'rating': rating,
      'ratingsCount': FieldValue.increment(1),
    });
    setState(() {
      _rating = rating;
    });
  }

  // Submit a review
  Future<void> _submitReview(String review) async {
    if (review.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('reviews')
          .add({
        'userId': widget.userId,
        'review': review,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _reviewController.clear();
      setState(() {});
    }
  }

  // Fetch user name based on userId
  Future<String> _fetchUserName(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc['name'] : 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName,
            style: GoogleFonts.pacifico(
                color: Colors.white)), // Change restaurant name to white
        backgroundColor: Colors.teal,
        leading: IconButton(
          // Back button
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.white], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              widget.restaurantImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: Image.network(
                        widget.restaurantImage,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
                    ),
              SizedBox(height: 16),

              // Restaurant Description
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.restaurantDescription,
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
                ),
              ),

              // Display Restaurant Address
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Address:\n$_restaurantAddress', // Display the fetched address
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
                ),
              ),

              // Rating Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Rating: ${_rating.toStringAsFixed(1)}',
                        style: GoogleFonts.lato(fontSize: 18)),
                    SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40.0,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        _submitRating(rating);
                      },
                    ),
                  ],
                ),
              ),

              // Review Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews:',
                      style: GoogleFonts.lato(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        hintText: 'Write a review...',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            _submitReview(_reviewController.text.trim());
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Display reviews
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(widget.restaurantId)
                          .collection('reviews')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final reviews = snapshot.data!.docs;
                        if (reviews.isEmpty) {
                          return Text('No reviews yet.',
                              style: GoogleFonts.lato());
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return FutureBuilder<String>(
                              future: _fetchUserName(review['userId']),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) {
                                  return ListTile(
                                    title: Text('Loading...'),
                                  );
                                }
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(review['review'],
                                        style: GoogleFonts.lato()),
                                    subtitle: Text(
                                      'By: ${userSnapshot.data}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Button to navigate to Menu Page
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      textStyle: GoogleFonts.lato(fontSize: 16),
                    ),
                    onPressed: () {
                      // Navigate to Menu Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuPage(
                            restaurantId: widget.restaurantId,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    child: Text('View Menu'),
                  ),
                ),
              ),

              // Button to navigate to UserTableBookingPage
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      textStyle: GoogleFonts.lato(fontSize: 16),
                    ),
                    onPressed: () {
                      // Navigate to UserTableBookingPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserTableBookingPage(
                            restaurantId: widget.restaurantId,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    child: Text('Book a Table'),
                  ),
                ),
              ),

              // New Button to navigate to ImageDisplayPage
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      textStyle: GoogleFonts.lato(fontSize: 16),
                    ),
                    onPressed: () {
                      // Navigate to ImageDisplayPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDisplayPage(
                            restaurantId: widget.restaurantId,
                          ),
                        ),
                      );
                    },
                    child: Text('View Images'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
