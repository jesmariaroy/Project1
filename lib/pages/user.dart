import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile_page.dart';
import 'restaurant_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HighlyRatedRestaurantsPage.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;

  String _searchQuery = '';
  String? _selectedState;
  String? _selectedDistrict;

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
    // Add other states and their districts
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

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
  }

  void _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  void _toggleFavorite(String restaurantId) async {
    final favoritesRef =
        _firestore.collection('users').doc(_userId).collection('favorites');

    final doc = await favoritesRef.doc(restaurantId).get();
    if (doc.exists) {
      await favoritesRef.doc(restaurantId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favorites!')),
      );
    } else {
      await favoritesRef
          .doc(restaurantId)
          .set({'timestamp': FieldValue.serverTimestamp()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('User  Dashboard',
              style: GoogleFonts.pacifico(
                  color: Colors.white, fontSize: 24)), // Stylish font
          backgroundColor: Colors.teal, // AppBar color
          actions: [
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: 'All Restaurants'),
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            ],
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
          child: Column(
            children: [
              // Location Filter - State Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButton<String>(
                  value: _selectedState,
                  hint: Text('Select State', style: GoogleFonts.lato()),
                  isExpanded: true,
                  items: _states.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state, style: GoogleFonts.lato()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                      _selectedDistrict =
                          null; // Reset district when state changes
                    });
                  },
                ),
              ),

              // Location Filter - District Dropdown
              if (_selectedState != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    value: _selectedDistrict,
                    hint: Text('Select District', style: GoogleFonts.lato()),
                    isExpanded: true,
                    items: _districts[_selectedState]!.map((district) {
                      return DropdownMenuItem(
                        value: district,
                        child: Text(district, style: GoogleFonts.lato()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    },
                  ),
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Restaurants',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.teal[50],
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    // All Restaurants Tab
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('restaurants').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final restaurants = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name = data['name']?.toLowerCase() ?? '';
                          final description =
                              data['description']?.toLowerCase() ?? '';
                          final state = data['state']?.toLowerCase() ?? '';
                          final district =
                              data['district']?.toLowerCase() ?? '';

                          final matchesSearchQuery = _searchQuery.isEmpty ||
                              name.contains(_searchQuery.toLowerCase()) ||
                              description.contains(_searchQuery.toLowerCase());

                          final matchesLocation = (_selectedState == null ||
                                  state == _selectedState!.toLowerCase()) &&
                              (_selectedDistrict == null ||
                                  district == _selectedDistrict!.toLowerCase());

                          return matchesSearchQuery && matchesLocation;
                        }).toList();

                        return ListView.builder(
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            final data =
                                restaurant.data() as Map<String, dynamic>;

                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(data['name'] ?? 'Unknown Name',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${data['description'] ?? 'No description'}\n${data['state']}, ${data['district']}',
                                  style: GoogleFonts.lato(),
                                ),
                                leading: data['image'] != null
                                    ? ClipOval(
                                        child: Image.network(data['image'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover),
                                      )
                                    : Icon(Icons.restaurant),
                                trailing: IconButton(
                                  icon: Icon(Icons.favorite_border),
                                  onPressed: () =>
                                      _toggleFavorite(restaurant.id),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailsPage(
                                        restaurantId: restaurant.id,
                                        restaurantName: data['name'],
                                        restaurantImage: data['image'],
                                        restaurantDescription:
                                            data['description'],
                                        userId: _userId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Favorites Tab
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('users')
                          .doc(_userId)
                          .collection('favorites')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final favoriteDocs = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: favoriteDocs.length,
                          itemBuilder: (context, index) {
                            final favoriteId = favoriteDocs[index].id;

                            return FutureBuilder<DocumentSnapshot>(
                              future: _firestore
                                  .collection('restaurants')
                                  .doc(favoriteId)
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return SizedBox();

                                if (!snapshot.data!.exists) {
                                  return ListTile(
                                    title: Text('Restaurant not found'),
                                    leading: Icon(Icons.error),
                                  );
                                }

                                final restaurant = snapshot.data!;
                                final data =
                                    restaurant.data() as Map<String, dynamic>;

                                return Card(
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 10.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    title: Text(data['name'],
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(data['description']),
                                    leading: data['image'] != null
                                        ? ClipOval(
                                            child: Image.network(data['image'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover),
                                          )
                                        : Icon(Icons.restaurant),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RestaurantDetailsPage(
                                            restaurantId: restaurant.id,
                                            restaurantName: data['name'],
                                            restaurantImage: data['image'],
                                            restaurantDescription:
                                                data['description'],
                                            userId: _userId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Button to view highly rated restaurants
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HighlyRatedRestaurantsPage(),
                      ),
                    );
                  },
                  child: Text('View Highly Rated Restaurants'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
