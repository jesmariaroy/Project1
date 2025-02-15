import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class TableBookingPage extends StatefulWidget {
  final String restaurantId;

  TableBookingPage({required this.restaurantId});

  @override
  _TableBookingPageState createState() => _TableBookingPageState();
}

class _TableBookingPageState extends State<TableBookingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _tableNumberController = TextEditingController();
  TextEditingController _capacityController = TextEditingController();

  // Method to add a new table
  Future<void> _addTable() async {
    if (_tableNumberController.text.isNotEmpty &&
        _capacityController.text.isNotEmpty) {
      try {
        await _firestore.collection('tables').add({
          'tableNumber': _tableNumberController.text,
          'capacity': int.parse(_capacityController.text),
          'isBooked': false,
          'bookedAt': null,
          'bookedBy': null,
          'restaurantId': widget.restaurantId,
          'bookingStatus': 'Available', // Set to 'Available' initially
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Table added successfully!')),
        );
        _tableNumberController.clear();
        _capacityController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add table: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required.')),
      );
    }
  }

  // Method to fetch user name from userId
  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        // Accessing 'name' field safely
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['name'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Error';
    }
  }

  // Method to change booking status to "Requested", "Accepted" or "Rejected"
  Future<void> _updateBookingStatus(String tableId, String status) async {
    try {
      await _firestore.collection('tables').doc(tableId).update({
        'bookingStatus': status, // Update booking status
        'isBooked': status == 'Accepted' ? true : false, // Update booking flag
      });
      String message =
          status == 'Accepted' ? 'Booking accepted.' : 'Booking rejected.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking status: $e')),
      );
    }
  }

  // Method to mark the table as finished
  Future<void> _markAsFinished(String tableId) async {
    try {
      await _firestore.collection('tables').doc(tableId).update({
        'isBooked': false,
        'bookedAt': null,
        'bookedBy': null,
        'bookingStatus': 'Available', // Reset status to Available
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table marked as finished and available.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark table as finished: $e')),
      );
    }
  }

  // Method to delete a table
  Future<void> _deleteTable(String tableId) async {
    try {
      await _firestore.collection('tables').doc(tableId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete table: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Table Booking Management',
          style: GoogleFonts.pacifico(
            color: Colors.white, // Stylish font with white color
          ),
        ),
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
        child: SingleChildScrollView(
          // Wrap the body with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fields to add a table
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _tableNumberController,
                      decoration: InputDecoration(
                        labelText: 'Table Number',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.teal[50], // Light background color
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _capacityController,
                      decoration: InputDecoration(
                        labelText: 'Capacity',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.teal[50], // Light background color
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addTable,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Button color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text('Add Table'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Available Tables:',
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
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
                    return Center(child: Text('No tables available.'));
                  }

                  return ListView.builder(
                    shrinkWrap:
                        true, // Prevent ListView from expanding infinitely
                    physics:
                        NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      final tableId = table.id;

                      return Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: ListTile(
                          title: Text('Table ${table['tableNumber']}',
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Capacity: ${table['capacity']}',
                                  style: GoogleFonts.lato()),
                              Text(
                                  'Booked: ${table['isBooked'] ? "Yes" : "No"}',
                                  style: GoogleFonts.lato()),
                              if (table['isBooked'])
                                FutureBuilder<String>(
                                  future: _getUserName(table['bookedBy']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Fetching user name...');
                                    } else if (snapshot.hasError) {
                                      return Text('Error fetching user name');
                                    } else {
                                      return Text('Booked By: ${snapshot.data}',
                                          style: GoogleFonts.lato());
                                    }
                                  },
                                ),
                              if (table['isBooked'] &&
                                  table['bookedAt'] != null)
                                Text('Booked At: ${table['bookedAt'].toDate()}',
                                    style: GoogleFonts.lato()),
                            ],
                          ),
                          trailing: table['isBooked']
                              ? Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // Ensure buttons take only the necessary space
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () => _updateBookingStatus(
                                          tableId, 'Accepted'),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () => _updateBookingStatus(
                                          tableId, 'Rejected'),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.done_all,
                                          color: Colors.blue),
                                      onPressed: () => _markAsFinished(
                                          tableId), // Mark as Finished button
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTable(tableId),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
