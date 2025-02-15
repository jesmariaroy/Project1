import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class RestaurantImageUploadPage extends StatefulWidget {
  @override
  _RestaurantImageUploadPageState createState() =>
      _RestaurantImageUploadPageState();
}

class _RestaurantImageUploadPageState extends State<RestaurantImageUploadPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<XFile>? _restaurantImageFiles = [];
  bool _isUploading = false;
  List<String> _uploadedImageUrls = []; // List to store uploaded image URLs

  @override
  void initState() {
    super.initState();
    _fetchUploadedImages(); // Fetch images when the page is initialized
  }

  Future<void> _fetchUploadedImages() async {
    try {
      final snapshot = await _firestore
          .collection('restaurant_images')
          .where('uploadedBy',
              isEqualTo: _auth.currentUser!.uid) // Adjust this query as needed
          .get();

      setState(() {
        _uploadedImageUrls =
            snapshot.docs.map((doc) => doc['image'] as String).toList();
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> _pickAndUploadImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _restaurantImageFiles = pickedFiles;
      });
    }
  }

  Future<String> _uploadToCloudinary(XFile imageFile) async {
    const String cloudName =
        'dgr1x58to'; // Replace with your Cloudinary cloud name
    const String unsignedPreset =
        'flutter_upload'; // Replace with your unsigned preset name
    final String uploadUrl =
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    // Prepare the multipart request
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['upload_preset'] = unsignedPreset;

    if (kIsWeb) {
      // For web, use MultipartFile from bytes
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      ));
    } else {
      // For mobile, use MultipartFile from path
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    // Send the request
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody)['secure_url'];
    } else {
      throw Exception('Failed to upload image: $responseBody');
    }
  }

  Future<void> _uploadImages() async {
    setState(() => _isUploading = true);
    try {
      for (var imageFile in _restaurantImageFiles!) {
        final imageUrl = await _uploadToCloudinary(imageFile);
        await _firestore.collection('restaurant_images').add({
          'image': imageUrl,
          'uploadedBy': _auth.currentUser!.uid,
        });
        _uploadedImageUrls.add(imageUrl);
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Images uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to upload images: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      final snapshot = await _firestore
          .collection('restaurant_images')
          .where('image', isEqualTo: imageUrl)
          .where('uploadedBy', isEqualTo: _auth.currentUser!.uid)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _uploadedImageUrls.remove(imageUrl);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image deleted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Restaurant Image',
          style: GoogleFonts.pacifico(
            color: Colors.white, // Stylish font with white color
          ),
        ),
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
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickAndUploadImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Pick Images',
                style: TextStyle(fontFamily: 'Pacifico', fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _uploadedImageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = _uploadedImageUrls[index];
                  return ListTile(
                    leading: Image.network(imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(
                      'Image ${index + 1}',
                      style: TextStyle(fontFamily: 'Pacifico'),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteImage(imageUrl),
                    ),
                  );
                },
              ),
            ),
            if (_isUploading) CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Upload Selected Images',
                style: TextStyle(fontFamily: 'Pacifico', fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
