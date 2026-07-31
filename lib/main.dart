import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(LiveSmartApp());
}

// ================= APP ROOT =================
class LiveSmartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LiveSmart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: SplashScreen(),
    );
  }
}

// ================= 1. SPLASH SCREEN =================
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "LiveSmart",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Get Started"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ================= 2. LOGIN SCREEN =================
class LoginScreen extends StatelessWidget {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "LiveSmart Login",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),

                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainApp()),
                    );
                  },
                  child: Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= 3–7 MAIN APP WITH BOTTOM NAV =================
class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;

  final screens = [
    DashboardScreen(),
    AIChatScreen(),
    MessagesScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "AI"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ================= 3. DASHBOARD (PROPERTIES) =================
class DashboardScreen extends StatelessWidget {
  final List<Map<String, String>> popularLocations = [
    {'name': 'Colombo 03'},
    {'name': 'Kadawatha'},
    {'name': 'Weligama'},
  ];

  final List<Map<String, String>> featuredProperties = [
    {
      'tag': 'Villa',
      'label': 'For Rent',
      'location': 'Dondra, Matara',
      'title': 'Luxury Villa in Dondra',
      'price': 'LKR 84,000/mo',
      'image': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
      'beds': '5',
      'baths': '1',
    },
    {
      'tag': 'House',
      'label': 'For Sale',
      'location': 'Kadawatha, Gampaha',
      'title': 'Modern Family Home',
      'price': 'LKR 141,000,000',
      'image': 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=800&q=80',
      'beds': '4',
      'baths': '2',
    },
  ];

  final List<Map<String, String>> latestListings = [
    {
      'tag': 'House',
      'location': 'Colombo 03, Colombo',
      'title': 'Two-Storey House',
      'price': 'LKR 69,000,000',
      'image': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
    },
    {
      'tag': 'Land',
      'label': 'For Rent',
      'location': 'Kadawatha, Gampaha',
      'title': 'Coconut Land in Gampaha',
      'price': 'LKR 418,000/mo',
      'image': 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI-Powered Property Search',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w700,
                      )),
                  SizedBox(height: 12),
                  Text('Find your dream home',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: 6),
                  Text('Smart property search across Sri Lanka',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      )),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by location, type...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.star, color: Colors.white),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ask the AI Assistant',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                                SizedBox(height: 4),
                                Text('"3-bedroom house in Colombo under 50M"',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                    )),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      categoryItem(Icons.home, 'House'),
                      categoryItem(Icons.apartment, 'Apartment'),
                      categoryItem(Icons.stars, 'Villa'),
                      categoryItem(Icons.terrain, 'Land'),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Popular Locations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      Text('See all',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: popularLocations
                        .map((item) => chipItem(item['name']!))
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  sectionTitle('Featured'),
                  SizedBox(height: 14),
                  SizedBox(
                    height: 280,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredProperties.length,
                      separatorBuilder: (_, __) => SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final item = featuredProperties[index];
                        return featuredCard(item);
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  sectionTitle('Latest Listings'),
                  SizedBox(height: 14),
                  Column(
                    children: latestListings.map((item) => latestCard(item)).toList(),
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryItem(IconData icon, String title) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.green[800], size: 24),
          ),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget chipItem(String title) {
    return Chip(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      label: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
  }

  Widget sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        Text('See all',
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }

  Widget featuredCard(Map<String, String> item) {
    return Container(
      width: 260,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              item['image']!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      badge(item['tag']!, Colors.green[100]!),
                      SizedBox(width: 8),
                      if (item['label'] != null)
                        badge(item['label']!, Colors.orange[100]!),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(item['location']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  SizedBox(height: 6),
                  Text(item['title']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 6),
                  Text(item['price']!,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green[800])),
                  Spacer(),
                  Row(
                    children: [
                      iconInfo(Icons.bed, item['beds'] ?? '0'),
                      SizedBox(width: 12),
                      iconInfo(Icons.bathtub, item['baths'] ?? '0'),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget latestCard(Map<String, String> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(22)),
            child: Image.network(
              item['image']!,
              height: 110,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      badge(item['tag']!, Colors.green[100]!),
                      if (item['label'] != null) ...[
                        SizedBox(width: 8),
                        badge(item['label']!, Colors.orange[100]!),
                      ],
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(item['location']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  SizedBox(height: 6),
                  Text(item['title']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(item['price']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.green[800])),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget iconInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
      ],
    );
  }
}

Widget badge(String label, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
  );
}

Widget iconInfo(IconData icon, String label) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey[700]),
      SizedBox(width: 6),
      Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
    ],
  );
}

// ================= 4. AI CHAT SCREEN =================
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _lastWords = '';
  List<Map<String, String>> _assistantProperties = [];
  final List<Map<String, String>> _quickSuggestions = [
    {'text': '3-bedroom house in Colombo under 50 million'},
    {'text': '2-bedroom apartment in Kandy for rent'},
    {'text': 'Luxury villa in Galle with parking'},
    {'text': 'Land in Gampaha under 10 million'},
  ];
  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text': 'Hi! I\'m your LiveSmart AI assistant. Tell me what you\'re looking for — for example, "a 3-bedroom house in Colombo under 50 million rupees."'
    }
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          _messageController.text = _lastWords;
        });
      });
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _speak(String text) {
    _flutterTts.speak(text);
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messageController.clear();
    });

    Future.delayed(Duration(milliseconds: 250), () {
      final response = _generateResponse(text);
      setState(() {
        _messages.add({'sender': 'assistant', 'text': response['message']!});
        _assistantProperties = response['properties']!;
      });
      _speak(response['message']!);
    });
  }

  Map<String, dynamic> _generateResponse(String query) {
    final lower = query.toLowerCase();
    final sampleProperties = [
      {
        'tag': 'House',
        'location': 'Colombo 04, Colombo',
        'title': 'Spacious Bungalow in Colombo 04',
        'price': 'LKR 20,000,000',
        'image': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80',
        'beds': '5',
        'baths': '1',
      },
      {
        'tag': 'Apartment',
        'location': 'Colombo 05, Colombo',
        'title': 'Modern 3-Bedroom Apartment',
        'price': 'LKR 18,500,000',
        'image': 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=900&q=80',
        'beds': '3',
        'baths': '2',
      },
      {
        'tag': 'Villa',
        'location': 'Galle, South',
        'title': 'Luxury Villa Retreat',
        'price': 'LKR 42,000,000',
        'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=900&q=80',
        'beds': '4',
        'baths': '3',
      },
    ];

    if (lower.contains('colombo') && lower.contains('3-bedroom')) {
      return {
        'message': 'I found 2 houses 3-bedroom in Colombo under LKR 50,000,000 matching your requirements.',
        'properties': [sampleProperties[0], sampleProperties[1]],
      };
    }

    if (lower.contains('villa') || lower.contains('luxury')) {
      return {
        'message': 'Here are some luxury properties that match your search.',
        'properties': [sampleProperties[2]],
      };
    }

    return {
      'message': 'I found 3 properties matching your request. Tap any property to view details.',
      'properties': sampleProperties,
    };
  }

  void _openPropertyDetail(Map<String, String> property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: property),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _iconInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Property Assistant',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 6),
                  Text('Ask in plain English or Sinhala',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _quickSuggestions.map((suggestion) {
                              return ActionChip(
                                label: Text(suggestion['text']!),
                                backgroundColor: Colors.green[50],
                                onPressed: () => _sendMessage(suggestion['text']!),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                          ..._messages.map((message) => _buildMessageBubble(message)),
                          if (_assistantProperties.isNotEmpty) ...[
                            SizedBox(height: 10),
                            Text('Tap a property to view details', style: TextStyle(color: Colors.grey[700])),
                            SizedBox(height: 12),
                            ..._assistantProperties.map((property) => _propertyCard(property)),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _isListening ? _stopListening : _startListening,
                            child: Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                                ],
                              ),
                              child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.green[800]),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: InputDecoration(
                                        hintText: 'Type your requirements...',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: _sendMessage,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      final lastAssistant = _messages.lastWhere(
                                        (msg) => msg['sender'] == 'assistant',
                                        orElse: () => {'sender': 'assistant', 'text': ''},
                                      );
                                      final assistantText = lastAssistant['text'];
                                      if (assistantText != null && assistantText.isNotEmpty) {
                                        _speak(assistantText);
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Icon(Icons.volume_up, color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _sendMessage(_messageController.text),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green[800],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.send, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final bool isUser = message['sender'] == 'user';
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: EdgeInsets.only(right: 12, top: 6),
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.green[800], shape: BoxShape.circle),
              child: Icon(Icons.star, color: Colors.white, size: 20),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? Colors.green[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message['text']!,
                style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: EdgeInsets.only(left: 12, top: 6),
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.green[800], shape: BoxShape.circle),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _propertyCard(Map<String, String> property) {
    return GestureDetector(
      onTap: () => _openPropertyDetail(property),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(property['image']!, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _badge(property['tag']!, Colors.green[100]!),
                      Icon(Icons.favorite_border, color: Colors.grey[600]),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(property['location']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  SizedBox(height: 6),
                  Text(property['title']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(property['price']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.green[800])),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _iconInfo(Icons.bed, property['beds'] ?? '0'),
                      SizedBox(width: 16),
                      _iconInfo(Icons.bathtub, property['baths'] ?? '0'),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PropertyDetailScreen extends StatelessWidget {
  final Map<String, String> property;

  const PropertyDetailScreen({required this.property, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property['title']!)),
      body: ListView(
        children: [
          Image.network(property['image']!, height: 260, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property['title']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                SizedBox(height: 8),
                Text(property['location']!, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                SizedBox(height: 12),
                Text(property['price']!, style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w700, fontSize: 22)),
                SizedBox(height: 18),
                Row(
                  children: [
                    iconInfo(Icons.bed, property['beds'] ?? '0'),
                    SizedBox(width: 18),
                    iconInfo(Icons.bathtub, property['baths'] ?? '0'),
                  ],
                ),
                SizedBox(height: 18),
                Text('Property Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('A very attractive property with high quality finishes, prime location, and excellent amenities. Tap the contact button below to get in touch with the owner.'),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], minimumSize: Size(double.infinity, 50)),
                  child: Text('Contact Owner'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ================= 5. MESSAGES SCREEN =================
class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("John"),
            subtitle: Text("Hey, is the house available?"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Sarah"),
            subtitle: Text("Can I schedule a visit?"),
          ),
        ],
      ),
    );
  }
}

// ================= 6. MAP SCREEN =================
class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Map")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 80, color: Colors.green),
            SizedBox(height: 10),
            Text("Google Maps will be added here later"),
          ],
        ),
      ),
    );
  }
}

// ================= 7. PROFILE SCREEN =================
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            SizedBox(height: 10),
            Text("User Name", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.email),
              title: Text("user@email.com"),
            ),

            ListTile(
              leading: Icon(Icons.phone),
              title: Text("+94 7X XXX XXXX"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
