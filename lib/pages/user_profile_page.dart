import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_user_profile_page.dart';

class UserProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('User  Profile', style: GoogleFonts.pacifico()),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: userData['profileImage'] != null
                        ? NetworkImage(userData['profileImage'])
                        : null,
                    child: userData['profileImage'] == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Name: ${userData['name'] ?? 'No Name'}',
                  style: GoogleFonts.lato(fontSize: 20),
                ),
                Text(
                  'Email: ${userData['email']}',
                  style: GoogleFonts.lato(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Phone: ${userData['phone'] ?? 'Not Set'}',
                  style: GoogleFonts.lato(),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserProfilePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      textStyle: GoogleFonts.lato(fontSize: 16),
                    ),
                    child: Text('Edit Profile'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
