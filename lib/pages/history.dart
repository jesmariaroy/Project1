import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class BookingHistoryPage extends StatelessWidget {
  final String userId;

  BookingHistoryPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking History', style: GoogleFonts.pacifico()),
        backgroundColor: Colors.teal, // Stylish color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.white], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tables')
              .where('bookedBy', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final bookings = snapshot.data!.docs;

            if (bookings.isEmpty) {
              return Center(child: Text('No booking history found.'));
            }

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final bookedAt = booking['bookedAt'] != null
                    ? (booking['bookedAt'] as Timestamp).toDate()
                    : DateTime.now();
                final bookingStatus = booking['bookingStatus'] ?? 'Unknown';
                final bookedBy = booking['bookedBy'] ?? 'Unknown';

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(bookedBy)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('Table ${booking['tableNumber']}'),
                          subtitle: Text('Loading user details...'),
                        ),
                      );
                    }

                    if (userSnapshot.hasError) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('Table ${booking['tableNumber']}'),
                          subtitle: Text('Error fetching user details'),
                        ),
                      );
                    }

                    final userData =
                        userSnapshot.data?.data() as Map<String, dynamic>;
                    final userName = userData['name'] ?? 'Unknown';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                      child: ListTile(
                        title: Text('Table ${booking['tableNumber']}',
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Booked By: $userName',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Status: $bookingStatus'),
                            Text('Booked At: ${bookedAt.toLocal()}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
