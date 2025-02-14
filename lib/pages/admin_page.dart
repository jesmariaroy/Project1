import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

void main() => runApp(AdminDashboardApp());

class AdminDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    DashboardHome(),
    BookingManagement(),
    SettingsScreen(),
    RegisterUserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800], // Teal gradient color
        title: Text('Admin Dashboard', style: GoogleFonts.pacifico()),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out user
              Navigator.pushReplacementNamed(
                  context, '/login'); // Navigate to login page
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal[800]!,
                    Colors.teal[400]!
                  ], // Teal gradient color
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40,
                    child: Icon(Icons.person,
                        size: 50,
                        color: Colors.teal[800]!), // Teal gradient color
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Restaurant Admin',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Booking Management'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Register User'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.white], // Teal gradient color
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _pages[_selectedIndex],
        ),
      ),
    );
  }
}

// Dashboard Home Page
class DashboardHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Admin Dashboard',
            style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800]!), // Teal gradient color
          ),
          SizedBox(height: 20),
          Text(
            'Here, you can manage bookings, user settings, and other important functions of the restaurant. Use the sidebar to navigate.',
            style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 40),
          _buildCard('Manage Bookings', Icons.table_chart, Colors.teal[400]!,
              context, '/booking'),
          _buildCard('User  Management', Icons.person_add, Colors.teal[400]!,
              context, '/users'),
          _buildCard('Settings', Icons.settings, Colors.teal[400]!, context,
              '/settings'),
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color,
      BuildContext context, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// Booking Management Page
class BookingManagement extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800], // Teal gradient color
        title: Text('Booking Management', style: GoogleFonts.pacifico()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Management',
                style: GoogleFonts.lato(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('tables').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final bookings = snapshot.data!.docs;

                  if (bookings.isEmpty) {
                    return Center(child: Text('No bookings found.'));
                  }

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final bookingData =
                          booking.data() as Map<String, dynamic>;

                      final isBooked = bookingData['isBooked'] ?? false;
                      final bookedBy = bookingData['bookedBy'] ?? 'N/A';
                      final tableNumber = bookingData['tableNumber'] ?? 'N/A';
                      final capacity = bookingData['capacity'] ?? 'N/A';
                      final bookedAt = bookingData['bookedAt'] != null
                          ? (bookingData['bookedAt'] as Timestamp).toDate()
                          : null;

                      return Card(
                        elevation: 4.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text('Table $tableNumber',
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Capacity: $capacity',
                                  style: GoogleFonts.lato()),
                              Text('Booked By: $bookedBy',
                                  style: GoogleFonts.lato()),
                              if (bookedAt != null)
                                Text('Booked At: ${bookedAt.toString()}',
                                    style: GoogleFonts.lato()),
                              Text(
                                  'Status: ${isBooked ? 'Booked' : 'Available'}',
                                  style: GoogleFonts.lato()),
                            ],
                          ),
                          trailing: isBooked
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _cancelBooking(context, booking.id);
                                  },
                                )
                              : null,
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
    );
  }

  Future<void> _cancelBooking(BuildContext context, String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tables')
          .doc(bookingId)
          .update({
        'isBooked': false,
        'bookedAt': null,
        'bookedBy': null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking canceled successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel booking: $e')));
    }
  }
}

// Settings Page - Manage Users
class SettingsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800], // Teal gradient color
        title: Text('Settings', style: GoogleFonts.pacifico()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User  Management',
                style: GoogleFonts.lato(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;

                  if (users.isEmpty) {
                    return Center(child: Text('No users found.'));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final userData = user.data() as Map<String, dynamic>;

                      final userName = userData['name'] ?? 'No Name';
                      final userEmail = userData['email'] ?? 'No Email';
                      final userRole = userData['role'] ?? 'No Role';

                      return Card(
                        elevation: 2.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(userName,
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: $userEmail',
                                  style: GoogleFonts.lato()),
                              Text('Role: $userRole',
                                  style: GoogleFonts.lato()),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteUser(context, user.id);
                            },
                          ),
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
    );
  }

  Future<void> _deleteUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User  deleted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
    }
  }
}

// Register User Screen - Form to add a new user
class RegisterUserScreen extends StatefulWidget {
  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'User '; // Default role

  final List<String> roles = ['Hotel Admin', 'User '];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800], // Teal gradient color
        title: Text('Register User', style: GoogleFonts.pacifico()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Register New User',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Select Role'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _registerUser(context);
              },
              child: Text('Register User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[800], // Teal gradient color
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

  Future<void> _registerUser(BuildContext context) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'email': _emailController.text,
        'role': _selectedRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User  registered successfully!')));

      // Clear the fields after successful registration
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to register user: $e')));
    }
  }
}
