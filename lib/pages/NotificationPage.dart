import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMessagePage extends StatefulWidget {
  final String restaurantId; // Add restaurantId as a parameter

  AddMessagePage(
      {required this.restaurantId}); // Constructor to accept restaurantId

  @override
  _AddMessagePageState createState() => _AddMessagePageState();
}

class _AddMessagePageState extends State<AddMessagePage> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _submitMessage() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'restaurantId': widget.restaurantId, // Use the passed restaurantId
        'adminId': FirebaseAuth.instance.currentUser!.uid, // Store the admin ID
      });

      // Clear the text field after submission
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add message: $e')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Message', style: GoogleFonts.pacifico()),
        backgroundColor: const Color.fromARGB(255, 34, 174, 171),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your message below:',
              style:
                  GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitMessage,
              child: Text('Submit Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 14, 20),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
