import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageDisplayPage extends StatelessWidget {
  final String restaurantId;

  ImageDisplayPage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restaurant Images',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.white, // Solid white background
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .snapshots(),
          builder: (context, restaurantSnapshot) {
            if (!restaurantSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (!restaurantSnapshot.data!.exists) {
              return Center(
                child: Text(
                  'Restaurant not found.',
                  style: GoogleFonts.lato(color: Colors.black, fontSize: 18),
                ),
              );
            }

            final createdBy = restaurantSnapshot.data!['createdBy'];

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restaurant_images')
                  .where('uploadedBy', isEqualTo: createdBy)
                  .snapshots(),
              builder: (context, imagesSnapshot) {
                if (!imagesSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final images = imagesSnapshot.data!.docs;

                if (images.isEmpty) {
                  return Center(
                    child: Text(
                      'No images available.',
                      style:
                          GoogleFonts.lato(color: Colors.black, fontSize: 18),
                    ),
                  );
                }

                List<String> imageUrls =
                    images.map((doc) => doc['image'] as String).toList();

                return CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    height: MediaQuery.of(context).size.height * 0.6,
                  ),
                  items: imageUrls.map((imageUrl) {
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                '${imageUrls.indexOf(imageUrl) + 1} / ${imageUrls.length}',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
