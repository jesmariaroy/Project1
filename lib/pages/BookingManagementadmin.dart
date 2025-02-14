import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingManagement extends StatefulWidget {
  @override
  _BookingManagementState createState() => _BookingManagementState();
}

class _BookingManagementState extends State<BookingManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _deleteBooking(String tableId) async {
    try {
      await _firestore.collection('tables').doc(tableId).update({
        'isBooked': false,
        'bookedAt': null,
        'bookedBy': null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tables')
            .where('isBooked', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tables = snapshot.data!.docs;

          if (tables.isEmpty) {
            return Center(child: Text('No bookings available.'));
          }

          return ListView.builder(
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              final tableData = table.data() as Map<String, dynamic>;
              final tableId = table.id;
              final bookedBy = tableData['bookedBy'];
              final bookedAt = tableData['bookedAt'] != null
                  ? (tableData['bookedAt'] as Timestamp).toDate()
                  : null;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(bookedBy).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Table ${tableData['tableNumber']}'),
                      subtitle: Text('Loading user details...'),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text('Table ${tableData['tableNumber']}'),
                    subtitle: Text(
                      'Capacity: ${tableData['capacity']}\n'
                      'Booked By: ${userData['name']} (${userData['email']})\n'
                      'Booked At: ${bookedAt != null ? bookedAt.toLocal() : 'N/A'}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteBooking(tableId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
