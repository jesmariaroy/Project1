import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:firebase_auth/firebase_auth.dart';
import 'history.dart'; // Import Booking History Page

class UserTableBookingPage extends StatefulWidget {
  final String restaurantId;
  final String userId;

  UserTableBookingPage({
    required this.restaurantId,
    required this.userId,
  });

  @override
  _UserTableBookingPageState createState() => _UserTableBookingPageState();
}

class _UserTableBookingPageState extends State<UserTableBookingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedDateTime;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey for Scaffold

  // Method to check if the reservation has expired (5 hours limit)
  bool _isReservationExpired(DateTime bookedAt) {
    final currentTime = DateTime.now();
    final expiryTime =
        bookedAt.add(Duration(hours: 5)); // Changed from 12 to 5 hours
    return currentTime.isAfter(expiryTime);
  }

  Future<void> _bookTable(String tableId, bool isCurrentlyBooked) async {
    if (isCurrentlyBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table is already booked.')),
      );
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date and time.')),
      );
      return;
    }

    try {
      await _firestore.collection('tables').doc(tableId).update({
        'isBooked': true,
        'bookedAt': _selectedDateTime,
        'bookedBy': widget.userId,
        'bookingStatus':
            'Pending', // Set status as Pending (Awaiting admin approval)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table booking request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send booking request: $e')),
      );
    }
  }

  Future<void> _cancelBooking(String tableId, String bookedBy) async {
    if (bookedBy != widget.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only cancel your own bookings.')),
      );
      return;
    }

    try {
      await _firestore.collection('tables').doc(tableId).update({
        'isBooked': false,
        'bookedAt': null,
        'bookedBy': null,
        'bookingStatus': 'Available', // Reset status to Available
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking canceled successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking: $e')),
      );
    }
  }

  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context)
          .pushReplacementNamed('/login'); // Redirect to login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      appBar: AppBar(
        title: Text(
          'User  Table Booking',
          style: GoogleFonts.pacifico(
              color: Colors.white), // Set text color to white
        ),
        backgroundColor: Colors.teal, // AppBar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back button
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.logout, color: Colors.white), // Logout button color
            onPressed: _logout,
          ),
          IconButton(
            icon: Icon(Icons.menu,
                color: Colors.white), // Menu button to open drawer
            onPressed: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // Open the drawer using the GlobalKey
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal,
                const Color.fromARGB(255, 64, 160, 138)
              ], // Teal gradient for the sidebar
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                    color: Colors.transparent), // Transparent to show gradient
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 40,
                      child: Icon(Icons.person,
                          size: 50,
                          color: const Color.fromARGB(255, 7, 11, 17)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Table Booking', // Replace with actual user name
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Home',
                    style: TextStyle(color: Colors.white)), // White text color
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to home page
                },
              ),
              ListTile(
                title: Text('Booking History',
                    style: TextStyle(color: Colors.white)), // White text color
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingHistoryPage(userId: widget.userId),
                    ),
                  ); // Navigate to Booking History page
                },
              ),
            ],
          ),
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _selectDateTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Button color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Select Date and Time'),
              ),
              if (_selectedDateTime != null)
                Text('Selected: $_selectedDateTime',
                    style: GoogleFonts.lato(
                        fontSize: 16,
                        color:
                            Colors.black87)), // Black text color for contrast
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('tables')
                      .where('restaurantId', isEqualTo: widget.restaurantId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final tables = snapshot.data!.docs;

                    if (tables.isEmpty) {
                      return Center(
                          child: Text('No tables available.',
                              style: TextStyle(
                                  color: Colors.black87))); // Black text color
                    }

                    return ListView.builder(
                      itemCount: tables.length,
                      itemBuilder: (context, index) {
                        final table = tables[index];
                        final tableId = table.id;
                        final isBooked = table['isBooked'];
                        final bookedBy = table['bookedBy'];
                        final bookedAt = table['bookedAt'] != null
                            ? (table['bookedAt'] as Timestamp).toDate()
                            : DateTime.now();
                        final bookingStatus = table['bookingStatus'];

                        // Automatically expire the reservation after 5 hours
                        if (_isReservationExpired(bookedAt) && isBooked) {
                          _firestore.collection('tables').doc(tableId).update({
                            'isBooked': false,
                            'bookedAt': null,
                            'bookedBy': null,
                            'bookingStatus':
                                'Available', // Reset status to Available after expiration
                          });
                        }

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                          ),
                          child: ListTile(
                            title: Text('Table ${table['tableNumber']}',
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .black)), // Set text color to black for contrast
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Capacity: ${table['capacity']}',
                                    style: GoogleFonts.lato()),
                                Text(
                                    'Booked: ${isBooked ? (bookingStatus == 'Pending' ? 'Pending' : 'Yes') : 'No'}',
                                    style: GoogleFonts.lato()),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isBooked || bookingStatus == 'Pending')
                                  IconButton(
                                    icon: Icon(Icons.check_circle,
                                        color: Colors.green),
                                    onPressed: () =>
                                        _bookTable(tableId, isBooked),
                                  ),
                                if (isBooked && bookedBy == widget.userId)
                                  IconButton(
                                    icon: Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () =>
                                        _cancelBooking(tableId, bookedBy),
                                  ),
                              ],
                            ),
                            tileColor: isBooked
                                ? Colors.grey[300]
                                : null, // Highlight reserved tables
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
