import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:proj1/pages/restaurant_image_upload_page.dart';
import 'package:proj1/pages/TableBookingPage.dart';
import 'package:proj1/pages/NotificationPage.dart';

class HotelAdminDashboard extends StatefulWidget {
  @override
  _HotelAdminDashboardState createState() => _HotelAdminDashboardState();
}

class _HotelAdminDashboardState extends State<HotelAdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _restaurantName;
  String? _restaurantDescription;
  dynamic _restaurantImageFile;
  String? _restaurantAddress;

  String? _menuName;
  String? _menuPrice;
  String? _menuCategory;
  dynamic _menuImageFile;

  String? _selectedState;
  String? _selectedDistrict;

  bool _isUploading = false;

  // Sample data for states and districts
  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];

  final Map<String, List<String>> _districts = {
    'Andhra Pradesh': [
      'Anakapalli',
      'Anantapur',
      'Bapatla',
      'Chittoor',
      'East Godavari',
      'Eluru',
      'Guntur',
      'Kakinada',
      'Konaseema',
      'Krishna',
      'Kurnool',
      'Nandyal',
      'Nellore',
      'Parvathipuram Manyam',
      'Prakasam',
      'Srikakulam',
      'Sri Sathya Sai',
      'Tirupati',
      'Visakhapatnam',
      'Vizianagaram',
      'West Godavari',
      'YSR Kadapa'
    ],
    'Arunachal Pradesh': [
      'Anjaw',
      'Changlang',
      'Dibang Valley',
      'East Kameng',
      'East Siang',
      'Kamle',
      'Kra Daadi',
      'Kurung Kumey',
      'Lepa Rada',
      'Lohit',
      'Longding',
      'Lower Dibang Valley',
      'Lower Siang',
      'Lower Subansiri',
      'Namsai',
      'Pakke-Kessang',
      'Papum Pare',
      'Shi Yomi',
      'Siang',
      'Tawang',
      'Tirap',
      'Upper Siang',
      'Upper Subansiri',
      'West Kameng',
      'West Siang'
    ],
    'Assam': [
      'Baksa',
      'Barpeta',
      'Biswanath',
      'Bongaigaon',
      'Cachar',
      'Charaideo',
      'Chirang',
      'Darrang',
      'Dhemaji',
      'Dhubri',
      'Dibrugarh',
      'Goalpara',
      'Golaghat',
      'Hailakandi',
      'Hojai',
      'Jorhat',
      'Kamrup',
      'Kamrup Metropolitan',
      'Karbi Anglong',
      'Karimganj',
      'Kokrajhar',
      'Lakhimpur',
      'Majuli',
      'Morigaon',
      'Nagaon',
      'Nalbari',
      'Dima Hasao',
      'Sivasagar',
      'Sonitpur',
      'South Salmara-Mankachar',
      'Tinsukia',
      'Udalguri',
      'West Karbi Anglong'
    ],
    'Bihar': [
      'Araria',
      'Arwal',
      'Aurangabad',
      'Banka',
      'Begusarai',
      'Bhagalpur',
      'Bhojpur',
      'Buxar',
      'Darbhanga',
      'East Champaran (Motihari)',
      'Gaya',
      'Gopalganj',
      'Jamui',
      'Jehanabad',
      'Kaimur (Bhabua)',
      'Katihar',
      'Khagaria',
      'Kishanganj',
      'Lakhisarai',
      'Madhepura',
      'Madhubani',
      'Munger (Monghyr)',
      'Muzaffarpur',
      'Nalanda',
      'Nawada',
      'Patna',
      'Purnia (Purnea)',
      'Rohtas',
      'Saharsa',
      'Samastipur',
      'Saran (Chhapra)',
      'Sheikhpura',
      'Sheohar',
      'Sitamarhi',
      'Siwan',
      'Supaul',
      'Vaishali',
      'West Champaran'
    ],
    'Chhattisgarh': [
      'Balod',
      'Baloda Bazar',
      'Balrampur',
      'Bastar',
      'Bemetara',
      'Bijapur',
      'Bilaspur',
      'Dantewada (South Bastar)',
      'Dhamtari',
      'Durg',
      'Gariyaband',
      'Gaurela-Pendra-Marwahi',
      'Janjgir-Champa',
      'Jashpur',
      'Kabirdham (Kawardha)',
      'Kanker (North Bastar)',
      'Kondagaon',
      'Korba',
      'Koriya',
      'Mahasamund',
      'Mungeli',
      'Narayanpur',
      'Raigarh',
      'Raipur',
      'Rajnandgaon',
      'Sukma',
      'Surajpur',
      'Surguja'
    ],
    'Goa': ['North Goa', 'South Goa'],
    'Gujarat': [
      'Ahmedabad',
      'Amreli',
      'Anand',
      'Aravalli',
      'Banaskantha (Palanpur)',
      'Bharuch',
      'Bhavnagar',
      'Botad',
      'Chhota Udaipur',
      'Dahod',
      'Dang (Ahwa)',
      'Devbhoomi Dwarka',
      'Gandhinagar',
      'Gir Somnath',
      'Jamnagar',
      'Junagadh',
      'Kheda (Nadiad)',
      'Kutch (Bhuj)',
      'Mahisagar',
      'Mehsana',
      'Morbi',
      'Narmada (Rajpipla)',
      'Navsari',
      'Panchmahal (Godhra)',
      'Patan',
      'Porbandar',
      'Rajkot',
      'Sabarkantha (Himmatnagar)',
      'Surat',
      'Surendranagar',
      'Tapi (Vyara)',
      'Vadodara',
      'Valsad'
    ],
    'Haryana': [
      'Ambala',
      'Bhiwani',
      'Charkhi Dadri',
      'Faridabad',
      'Fatehabad',
      'Gurugram',
      'Hisar',
      'Jhajjar',
      'Jind',
      'Kaithal',
      'Karnal',
      'Kurukshetra',
      'Mahendragarh',
      'Nuh',
      'Palwal',
      'Panchkula',
      'Panipat',
      'Rewari',
      'Rohtak',
      'Sirsa',
      'Sonipat',
      'Yamunanagar'
    ],
    'Himachal Pradesh': [
      'Bilaspur',
      'Chamba',
      'Hamirpur',
      'Kangra',
      'Kinnaur',
      'Kullu',
      'Lahaul and Spiti',
      'Mandi',
      'Shimla',
      'Sirmaur',
      'Solan',
      'Una'
    ],
    'Jharkhand': [
      'Bokaro',
      'Chatra',
      'Deoghar',
      'Dhanbad',
      'Dumka',
      'East Singhbhum (Jamshedpur)',
      'Garhwa',
      'Giridih',
      'Godda',
      'Gumla',
      'Hazaribagh',
      'Jamtara',
      'Khunti',
      'Koderma',
      'Latehar',
      'Lohardaga',
      'Pakur',
      'Palamu',
      'Ramgarh',
      'Ranchi',
      'Sahebganj',
      'Saraikela-Kharsawan',
      'Simdega',
      'West Singhbhum (Chaibasa)'
    ],
    'Karnataka': [
      'Bagalkot',
      'Ballari (Bellary)',
      'Belagavi (Belgaum)',
      'Bengaluru (Bangalore) Rural',
      'Bengaluru (Bangalore) Urban',
      'Bidar',
      'Chamarajanagar',
      'Chikballapur',
      'Chikkamagaluru (Chikmagalur)',
      'Chitradurga',
      'Dakshina Kannada',
      'Davanagere',
      'Dharwad',
      'Gadag',
      'Hassan',
      'Haveri',
      'Kalaburagi (Gulbarga)',
      'Kodagu',
      'Kolar',
      'Koppal',
      'Mandya',
      'Mysuru (Mysore)',
      'Raichur',
      'Ramanagara',
      'Shivamogga (Shimoga)',
      'Tumakuru (Tumkur)',
      'Udupi',
      'Uttara Kannada (Karwar)',
      'Vijayapura (Bijapur)',
      'Yadgir'
    ],
    'Kerala': [
      'Alappuzha',
      'Ernakulam',
      'Idukki',
      'Kannur',
      'Kasaragod',
      'Kollam',
      'Kottayam',
      'Kozhikode',
      'Malappuram',
      'Palakkad',
      'Pathanamthitta',
      'Thiruvananthapuram',
      'Thrissur',
      'Wayanad'
    ],
    'Madhya Pradesh': [
      'Agar Malwa',
      'Alirajpur',
      'Anuppur',
      'Ashoknagar',
      'Balaghat',
      'Barwani',
      'Betul',
      'Bhind',
      'Bhopal',
      'Burhanpur',
      'Chhatarpur',
      'Chhindwara',
      'Damoh',
      'Datia',
      'Dewas',
      'Dhar',
      'Dindori',
      'Guna',
      'Gwalior',
      'Harda',
      'Hoshangabad',
      'Indore',
      'Jabalpur',
      'Jhabua',
      'Katni',
      'Khandwa',
      'Khargone',
      'Mandla',
      'Mandsaur',
      'Morena',
      'Narsinghpur',
      'Neemuch',
      'Niwari',
      'Panna',
      'Raisen',
      'Rajgarh',
      'Ratlam',
      'Rewa',
      'Sagar',
      'Satna',
      'Sehore',
      'Seoni',
      'Shahdol',
      'Shajapur',
      'Sheopur',
      'Shivpuri',
      'Sidhi',
      'Singrauli',
      'Tikamgarh',
      'Ujjain',
      'Umaria',
      'Vidisha'
    ],
    'Maharashtra': [
      'Ahmednagar',
      'Akola',
      'Amravati',
      'Aurangabad',
      'Beed',
      'Bhandara',
      'Buldhana',
      'Chandrapur',
      'Dhule',
      'Gadchiroli',
      'Gondia',
      'Hingoli',
      'Jalgaon',
      'Jalna',
      'Kolhapur',
      'Latur',
      'Mumbai City',
      'Mumbai Suburban',
      'Nagpur',
      'Nanded',
      'Nandurbar',
      'Nashik',
      'Osmanabad',
      'Palghar',
      'Parbhani',
      'Pune',
      'Raigad',
      'Ratnagiri',
      'Sangli',
      'Satara',
      'Sindhudurg',
      'Solapur',
      'Thane',
      'Wardha',
      'Washim',
      'Yavatmal'
    ],
    'Manipur': [
      'Bishnupur',
      'Chandel',
      'Churachandpur',
      'Imphal East',
      'Imphal West',
      'Jiribam',
      'Kakching',
      'Kamjong',
      'Kangpokpi',
      'Noney',
      'Pherzawl',
      'Senapati',
      'Tamenglong',
      'Tengnoupal',
      'Thoubal',
      'Ukhrul'
    ],
    'Meghalaya': [
      'East Garo Hills',
      'East Jaintia Hills',
      'East Khasi Hills',
      'North Garo Hills',
      'Ri-Bhoi',
      'South Garo Hills',
      'South West Garo Hills',
      'South West Khasi Hills',
      'West Garo Hills',
      'West Jaintia Hills',
      'West Khasi Hills'
    ],
    'Mizoram': [
      'Aizawl',
      'Champhai',
      'Hnahthial',
      'Kolasib',
      'Lawngtlai',
      'Lunglei',
      'Mamit',
      'Saiha',
      'Serchhip',
      'Saitual'
    ],
    'Nagaland': [
      'Chumoukedima',
      'Dimapur',
      'Kiphire',
      'Kohima',
      'Longleng',
      'Mokokchung',
      'Mon',
      'Noklak',
      'Peren',
      'Phek',
      'Tuensang',
      'Wokha',
      'Zunheboto'
    ],
    'Odisha': [
      'Angul',
      'Balangir',
      'Balasore',
      'Bargarh',
      'Bhadrak',
      'Boudh',
      'Cuttack',
      'Debagarh',
      'Dhenkanal',
      'Gajapati',
      'Ganjam',
      'Jagatsinghpur',
      'Jajpur',
      'Jharsuguda',
      'Kalahandi',
      'Kandhamal',
      'Kendrapara',
      'Kendujhar',
      'Khordha',
      'Koraput',
      'Malkangiri',
      'Mayurbhanj',
      'Nabarangpur',
      'Nayagarh',
      'Nuapada',
      'Puri',
      'Rayagada',
      'Sambalpur',
      'Sonepur',
      'Sundargarh'
    ],
    'Punjab': [
      'Amritsar',
      'Barnala',
      'Bathinda',
      'Faridkot',
      'Fatehgarh Sahib',
      'Fazilka',
      'Ferozepur',
      'Gurdaspur',
      'Hoshiarpur',
      'Jalandhar',
      'Kapurthala',
      'Ludhiana',
      'Mansa',
      'Moga',
      'Pathankot',
      'Patiala',
      'Rupnagar',
      'S.A.S. Nagar (Mohali)',
      'Sangrur',
      'Shaheed Bhagat Singh Nagar',
      'Sri Muktsar Sahib',
      'Tarn Taran'
    ],
    'Rajasthan': [
      'Ajmer',
      'Alwar',
      'Banswara',
      'Baran',
      'Barmer',
      'Bharatpur',
      'Bhilwara',
      'Bikaner',
      'Bundi',
      'Chittorgarh',
      'Churu',
      'Dausa',
      'Dholpur',
      'Dungarpur',
      'Hanumangarh',
      'Jaipur',
      'Jaisalmer',
      'Jalore',
      'Jhalawar',
      'Jhunjhunu',
      'Jodhpur',
      'Karauli',
      'Kota',
      'Nagaur',
      'Pali',
      'Pratapgarh',
      'Rajsamand',
      'Sawai Madhopur',
      'Sikar',
      'Sirohi',
      'Sri Ganganagar',
      'Tonk',
      'Udaipur'
    ],
    'Sikkim': ['East Sikkim', 'North Sikkim', 'South Sikkim', 'West Sikkim'],
    'Tamil Nadu': [
      'Ariyalur',
      'Chengalpattu',
      'Chennai',
      'Coimbatore',
      'Cuddalore',
      'Dharmapuri',
      'Dindigul',
      'Erode',
      'Kallakurichi',
      'Kanchipuram',
      'Kanyakumari',
      'Karur',
      'Krishnagiri',
      'Madurai',
      'Mayiladuthurai',
      'Nagapattinam',
      'Namakkal',
      'Nilgiris',
      'Perambalur',
      'Pudukkottai',
      'Ramanathapuram',
      'Ranipet',
      'Salem',
      'Sivaganga',
      'Tenkasi',
      'Thanjavur',
      'Theni',
      'Thoothukudi (Tuticorin)',
      'Tiruchirappalli',
      'Tirunelveli',
      'Tirupathur',
      'Tiruppur',
      'Tiruvallur',
      'Tiruvannamalai',
      'Tiruvarur',
      'Vellore',
      'Viluppuram',
      'Virudhunagar'
    ],
    'Telangana': [
      'Adilabad',
      'Bhadradri Kothagudem',
      'Hyderabad',
      'Jagtial',
      'Jangaon',
      'Jayashankar Bhupalpally',
      'Jogulamba Gadwal',
      'Kamareddy',
      'Karimnagar',
      'Khammam',
      'Kumuram Bheem',
      'Mahabubabad',
      'Mahabubnagar',
      'Mancherial',
      'Medak',
      'Medchal–Malkajgiri',
      'Mulugu',
      'Nagarkurnool',
      'Nalgonda',
      'Narayanpet',
      'Nirmal',
      'Nizamabad',
      'Peddapalli',
      'Rajanna Sircilla',
      'Rangareddy',
      'Sangareddy',
      'Siddipet',
      'Suryapet',
      'Vikarabad',
      'Wanaparthy',
      'Warangal (Rural)',
      'Warangal (Urban)',
      'Yadadri Bhuvanagiri'
    ],
    'Tripura': [
      'Dhalai',
      'Gomati',
      'Khowai',
      'North Tripura',
      'Sepahijala',
      'South Tripura',
      'Unakoti',
      'West Tripura'
    ],
    'Uttar Pradesh': [
      'Agra',
      'Aligarh',
      'Allahabad (Prayagraj)',
      'Ambedkar Nagar',
      'Amethi',
      'Amroha',
      'Auraiya',
      'Azamgarh',
      'Barabanki',
      'Bareilly',
      'Basti',
      'Bijnor',
      'Budaun',
      'Bulandshahr',
      'Chandauli',
      'Chitrakoot',
      'Deoria',
      'Etah',
      'Etawah',
      'Faizabad',
      'Farrukhabad',
      'Fatehpur',
      'Firozabad',
      'Gautam Buddh Nagar (Noida)',
      'Ghaziabad',
      'Ghazipur',
      'Gonda',
      'Hamirpur',
      'Hapur',
      'Hardoi',
      'Hathras',
      'Jalaun',
      'Jaunpur',
      'Jhansi',
      'Kannauj',
      'Kanpur Dehat',
      'Kanpur Nagar',
      'Kaushambi',
      'Kushinagar',
      'Lakhimpur Kheri',
      'Lalitpur',
      'Lucknow',
      'Maharajganj',
      'Mainpuri',
      'Mathura',
      'Meerut',
      'Mirzapur',
      'Moradabad',
      'Muzaffarnagar',
      'Pilibhit',
      'Pratapgarh',
      'Raebareli',
      'Rampur',
      'Saharanpur',
      'Sambhal',
      'Sant Kabir Nagar',
      'Shahjahanpur',
      'Shrawasti',
      'Siddharthnagar',
      'Sitapur',
      'Sonbhadra',
      'Sultanpur',
      'Unnao',
      'Varanasi'
    ],
    'Uttarakhand': [
      'Almora',
      'Bageshwar',
      'Chamoli',
      'Champawat',
      'Dehradun',
      'Haridwar',
      'Nainital',
      'Pauri Garhwal',
      'Pithoragarh',
      'Rudraprayag',
      'Tehri Garhwal',
      'Udham Singh Nagar',
      'Uttarkashi'
    ],
    'West Bengal': [
      'Alipurduar',
      'Bankura',
      'Birbhum',
      'Cooch Behar',
      'Dakshin Dinajpur',
      'Darjeeling',
      'Hooghly',
      'Howrah',
      'Jalpaiguri',
      'Jhargram',
      'Kolkata',
      'Malda',
      'Murshidabad',
      'Nadia',
      'North 24 Parganas',
      'Paschim Bardhaman',
      'Paschim Medinipur',
      'Purba Bardhaman',
      'Purba Medinipur',
      'South 24 Parganas',
      'Uttar Dinajpur'
    ]
  };
  Future<void> _pickAndUploadImage({required bool isMenu}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final Uint8List webImage = await pickedFile.readAsBytes();
        setState(() {
          if (isMenu) {
            _menuImageFile = webImage;
          } else {
            _restaurantImageFile = webImage;
          }
        });
      } else {
        setState(() {
          if (isMenu) {
            _menuImageFile = File(pickedFile.path);
          } else {
            _restaurantImageFile = File(pickedFile.path);
          }
        });
      }
    }
  }

  Future<String> _uploadToCloudinary(dynamic imageFile) async {
    const String cloudName = 'dgr1x58to';
    const String unsignedPreset = 'flutter_upload';
    final String uploadUrl =
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['upload_preset'] = unsignedPreset;

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageFile as Uint8List,
        filename: 'image.jpg',
      ));
    } else {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        await (imageFile as File).readAsBytes(),
        filename: 'image.jpg',
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody)['secure_url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> _addRestaurant() async {
    if (_restaurantName != null &&
        _restaurantDescription != null &&
        _restaurantAddress != null && // Check for address
        _restaurantImageFile != null &&
        _selectedState != null &&
        _selectedDistrict != null) {
      setState(() => _isUploading = true);
      try {
        final imageUrl = await _uploadToCloudinary(_restaurantImageFile);
        await _firestore.collection('restaurants').add({
          'name': _restaurantName,
          'description': _restaurantDescription,
          'address': _restaurantAddress, // Store address
          'image': imageUrl,
          'createdBy': _auth.currentUser!.uid,
          'state': _selectedState,
          'district': _selectedDistrict,
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Restaurant added successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add restaurant: $e')));
      } finally {
        setState(() => _isUploading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('All fields, image, and address are required.')));
    }
  }

  Future<void> _updateRestaurant(String restaurantId) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Restaurant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'New Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'New Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                await _firestore
                    .collection('restaurants')
                    .doc(restaurantId)
                    .update({
                  'name': nameController.text,
                  'description': descriptionController.text,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Restaurant updated successfully!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fields cannot be empty.')));
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMenu(String restaurantId, String menuId) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'New Name'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'New Price'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'New Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                await _firestore
                    .collection('restaurants')
                    .doc(restaurantId)
                    .collection('menu')
                    .doc(menuId)
                    .update({
                  'name': nameController.text,
                  'price': priceController.text,
                  'category': categoryController.text,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Menu item updated successfully!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fields cannot be empty.')));
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRestaurant(String restaurantId) async {
    try {
      await _firestore.collection('restaurants').doc(restaurantId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant deleted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete restaurant: $e')));
    }
  }

  Future<void> _addMenu(String restaurantId) async {
    if (_menuName != null &&
        _menuPrice != null &&
        _menuCategory != null &&
        _menuImageFile != null) {
      setState(() => _isUploading = true);
      try {
        final imageUrl = await _uploadToCloudinary(_menuImageFile);
        await _firestore
            .collection('restaurants')
            .doc(restaurantId)
            .collection('menu')
            .add({
          'name': _menuName,
          'price': _menuPrice,
          'category': _menuCategory,
          'image': imageUrl,
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Menu item added!')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add menu: $e')));
      } finally {
        setState(() => _isUploading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All fields and image are required.')));
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to log out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hotel Admin Dashboard',
          style: GoogleFonts.pacifico(),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Upload Restaurant Images'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantImageUploadPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.restaurant),
              title: Text('Manage Restaurants'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Table Booking'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TableBookingPage(
                      restaurantId: '',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added scrolling feature
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('restaurants')
                .where('createdBy', isEqualTo: _auth.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final restaurants = snapshot.data!.docs;

              if (restaurants.isNotEmpty) {
                final restaurant = restaurants.first;
                final restaurantId = restaurant.id;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        restaurant['name'],
                        style: GoogleFonts.lato(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        restaurant['description'],
                        style: GoogleFonts.lato(),
                      ),
                    ),
                    _buildTextField(
                        'Address (Format:Restaurant Name\nShop/Building Name, Street Name, Landmark (if any)\n Road, Locality/Area\nCity - Pincode\nState\n📞 +Contact Number\n✉ Email)',
                        (value) => _restaurantAddress = value,
                        maxLines: 6),
                    SizedBox(height: 10),
                    _buildStylishButton('Update Restaurant',
                        () => _updateRestaurant(restaurant.id)),
                    SizedBox(height: 10), // Added spacing
                    _buildStylishButton('Delete Restaurant',
                        () => _deleteRestaurant(restaurant.id)),
                    SizedBox(height: 20),
                    _buildStylishButton('Go to Table Booking', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TableBookingPage(
                                  restaurantId: restaurantId,
                                )),
                      );
                    }),
                    SizedBox(height: 20), // Added spacing
                    Text(
                      'Menu Management',
                      style: GoogleFonts.lato(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10), // Added spacing
                    _buildTextField('Menu Name', (value) => _menuName = value),
                    _buildTextField('Price', (value) => _menuPrice = value),
                    _buildTextField(
                        'Category', (value) => _menuCategory = value),
                    _buildImageButton('Pick Menu Image', true),
                    SizedBox(height: 10), // Added spacing
                    _buildStylishButton(
                        'Add Menu Item', () => _addMenu(restaurant.id)),
                    SizedBox(height: 20), // Added spacing
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('restaurants')
                          .doc(restaurant.id)
                          .collection('menu')
                          .snapshots(),
                      builder: (context, menuSnapshot) {
                        if (!menuSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final menuItems = menuSnapshot.data!.docs;

                        return ListView.builder(
                          itemCount: menuItems.length,
                          shrinkWrap: true, // Important to set this to true
                          physics:
                              NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                          itemBuilder: (context, index) {
                            final menuItem = menuItems[index];
                            return ListTile(
                              leading: Image.network(menuItem['image']),
                              title: Text(
                                menuItem['name'],
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${menuItem['price']} \$',
                                  style: GoogleFonts.lato()),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _updateMenu(restaurant.id, menuItem.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              }

              return ListView(
                children: [
                  _buildTextField(
                      'Restaurant Name', (value) => _restaurantName = value),
                  _buildTextField(
                      'Description', (value) => _restaurantDescription = value),
                  _buildDropdown('Select State', _states, (value) {
                    setState(() {
                      _selectedState = value;
                      _selectedDistrict = null; // Reset district
                    });
                  }),
                  _buildDropdown(
                      'Select District',
                      _selectedState == null
                          ? []
                          : _districts[_selectedState!]!, (value) {
                    setState(() {
                      _selectedDistrict = value;
                    });
                  }),
                  _buildTextField(
                      'Address (Format: Tandoori Delights\nGround Floor, Royal Plaza\nMG Road, Near Metro Station\nBangalore - 560001\nKarnataka\n📞 +91 98765 43210\n✉ info@tandooridelights.in)',
                      (value) => _restaurantAddress = value,
                      maxLines: 6),
                  _buildImageButton('Pick Restaurant Image', false),
                  SizedBox(height: 10), // Added spacing
                  _buildStylishButton('Add Restaurant', _addRestaurant),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged,
      {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2.0),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildImageButton(String label, bool isMenu) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () => _pickAndUploadImage(isMenu: isMenu),
      child: Text(label),
    );
  }

  Widget _buildStylishButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildDropdown(
      String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration:
          InputDecoration(labelText: label, border: OutlineInputBorder()),
      value: null,
      onChanged: onChanged,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
