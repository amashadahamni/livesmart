import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'data/property_data.dart';

const lightBlue = Color(0xff3d8df5);
const paleBlue = Color(0xffe4efff);

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
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: SplashScreen(),
    );
  }
}

// ================= 1. SPLASH SCREEN =================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _logoAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.65, curve: Curves.elasticOut),
    );
    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        },
        child: SizedBox.expand(
          child: FadeTransition(
            opacity: _contentAnimation,
            child: ScaleTransition(
              scale: _logoAnimation,
              child: Image.asset(
                'lib/Screen1FlashScreen.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveSmartMark extends StatelessWidget {
  const _LiveSmartMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 5),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.home_work_outlined, color: Colors.white, size: 82),
              Icon(Icons.hub, color: lightBlue, size: 47),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'LiveSmart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SplashActionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SplashActionButton({required this.onPressed});

  @override
  State<_SplashActionButton> createState() => _SplashActionButtonState();
}

class _SplashActionButtonState extends State<_SplashActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shineController,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: lightBlue.withOpacity(0.28),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                ElevatedButton(
                  onPressed: widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: lightBlue,
                    minimumSize: const Size(240, 62),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 18),
                      Icon(Icons.arrow_forward_rounded, size: 25),
                    ],
                  ),
                ),
                Positioned.fill(
                  left: -100 + (_shineController.value * 340),
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.35,
                      child: Container(width: 45, color: Colors.white.withOpacity(0.32)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SplashBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skylinePaint = Paint()..color = lightBlue.withOpacity(0.5);
    final baseY = size.height * 0.83;
    final widths = [38.0, 58.0, 30.0, 74.0, 44.0, 88.0, 34.0, 62.0];
    for (var index = 0; index < widths.length; index++) {
      final width = widths[index];
      final height = 35.0 + ((index * 29) % 85);
      final x = size.width * 0.04 + index * size.width * 0.125;
      canvas.drawRect(Rect.fromLTWH(x, baseY - height, width, height), skylinePaint);
    }
    final glowPaint = Paint()..color = const Color(0xff55cfff).withOpacity(0.15);
    canvas.drawCircle(Offset(size.width * 0.5, baseY - 55), size.width * 0.34, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        selectedItemColor: lightBlue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Location"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ================= 3. DASHBOARD (PROPERTIES) =================
class DashboardScreen extends StatelessWidget {
  final List<Map<String, String>> popularLocations = [
    {'name': 'Colombo 1-15'},
    {'name': 'Rajagiriya'},
    {'name': 'Galle'},
  ];

  final List<Map<String, String>> featuredProperties = PropertyData.all.take(2).toList();

  final List<Map<String, String>> latestListings = PropertyData.all.skip(2).take(2).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 32),
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => MainApp()),
                    (_) => false,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.home_work, color: lightBlue, size: 34),
                      SizedBox(width: 8),
                      Text('LiveSmart', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Spacer(),
                IconButton(
                  tooltip: 'Favorites',
                  icon: Icon(Icons.favorite_border, color: lightBlue, size: 28),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen())),
                ),
                IconButton(
                  tooltip: 'Notifications',
                  icon: Icon(Icons.notifications_none, color: lightBlue, size: 29),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen())),
                ),
              ],
            ),
            SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 2.5,
                child: Image.asset('lib/Screen2homeimage2.png', fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 18),
            Text('AI-Powered Property Search', style: TextStyle(fontSize: 16, color: lightBlue, fontWeight: FontWeight.w700)),
            SizedBox(height: 7),
            Text('Find your dream home', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Smart property search across Sri Lanka', style: TextStyle(fontSize: 17, color: Colors.grey[600])),
            SizedBox(height: 18),
            TextField(
              readOnly: true,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatScreen())),
              style: TextStyle(fontSize: 17),
              decoration: InputDecoration(
                hintText: 'Search by location, landmark, type...',
                hintStyle: TextStyle(fontSize: 17),
                prefixIcon: Icon(Icons.search, size: 29),
                suffixIcon: Icon(Icons.tune, color: lightBlue, size: 28),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatScreen())),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.all(19),
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    CircleAvatar(radius: 27, backgroundColor: lightBlue, child: Icon(Icons.smart_toy, color: Colors.white, size: 29)),
                    SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Ask the AI Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 5),
                      Text('Use text or voice to find a property', style: TextStyle(color: Colors.white70, fontSize: 15)),
                    ])),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            SizedBox(height: 22),
            Row(children: [
              categoryItem(context, Icons.home, 'House'),
              categoryItem(context, Icons.apartment, 'Apartment'),
              categoryItem(context, Icons.business, 'Commercial'),
              categoryItem(context, Icons.terrain, 'Land'),
            ]),
            SizedBox(height: 26),
            sectionTitle(context, 'Popular Locations'),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: ['Colombo 1-15', 'Rajagiriya', 'Galle', 'Kandy', 'Negombo']
                  .map((location) => Padding(padding: EdgeInsets.only(right: 10), child: chipItem(context, location))).toList()),
            ),
            SizedBox(height: 26),
            sectionTitle(context, 'Featured Properties'),
            SizedBox(height: 12),
            SizedBox(
              height: 440,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featuredProperties.length,
                separatorBuilder: (_, __) => SizedBox(width: 14),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: featuredProperties[index]))),
                  child: featuredCard(featuredProperties[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryItem(BuildContext context, IconData icon, String title) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyCategoryScreen(category: title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
              child: Icon(icon, color: lightBlue, size: 24),
            ),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget chipItem(BuildContext context, String title) {
    return ActionChip(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      label: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatScreen())),
    );
  }

  Widget sectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatScreen())),
          child: Text('See all', style: TextStyle(color: lightBlue, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget featuredCard(Map<String, String> item) {
    return Container(
      width: 260,
      height: 440,
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                child: propertyImage(item, height: 140, width: double.infinity),
              ),
              Expanded(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      badge(item['tag']!, paleBlue),
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: lightBlue)),
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
          Positioned(
            top: 10,
            right: 10,
            child: FavoriteButton(property: item),
          ),
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
            child: propertyImage(item, height: 150, width: 120),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      badge(item['tag']!, paleBlue),
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
                  Text(item['price']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: lightBlue)),
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

  Widget propertyImage(Map<String, String> item, {required double height, required double width}) {
    final imagePath = item['image']!;
    if (imagePath.startsWith('lib/')) {
      return Image.asset(imagePath, height: height, width: width, fit: BoxFit.cover);
    }
    return Image.network(imagePath, height: height, width: width, fit: BoxFit.cover);
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

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: PropertyData.favoritesChanged,
          builder: (context, _, __) {
            final allFavorites = PropertyData.favorites;
            final saleFavorites = allFavorites.where((property) => property['transactionType'] == 'Buy').toList();
            final rentFavorites = allFavorites.where((property) => property['transactionType'] == 'Rent').toList();
            final favorites = selectedTab == 1 ? saleFavorites : selectedTab == 2 ? rentFavorites : allFavorites;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header(context, allFavorites.length)),
                SliverToBoxAdapter(child: _tabs(allFavorites.length, saleFavorites.length, rentFavorites.length)),
                if (favorites.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No favorite properties yet', style: TextStyle(fontSize: 17))))
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 18, 16, 28),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _favoriteCard(context, favorites[index]),
                        childCount: favorites.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.home_work, color: lightBlue, size: 31),
            SizedBox(width: 8),
            Text('LiveSmart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.notifications_none, color: lightBlue, size: 28),
          ]),
          SizedBox(height: 28),
          Text('Favorites', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('$count properties you saved', style: TextStyle(fontSize: 17, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _tabs(int allCount, int saleCount, int rentCount) {
    final labels = ['All ($allCount)', 'For Sale ($saleCount)', 'For Rent ($rentCount)'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: selectedTab == index ? lightBlue : Colors.white,
                    borderRadius: BorderRadius.horizontal(
                      left: index == 0 ? Radius.circular(14) : Radius.zero,
                      right: index == labels.length - 1 ? Radius.circular(14) : Radius.zero,
                    ),
                    border: Border.all(color: lightBlue.withOpacity(0.18)),
                  ),
                  child: Text(labels[index], textAlign: TextAlign.center, style: TextStyle(color: selectedTab == index ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _favoriteCard(BuildContext context, Map<String, String> property) {
    final imagePath = property['image']!;
    final image = imagePath.startsWith('lib/')
        ? Image.asset(imagePath, fit: BoxFit.cover)
        : Image.network(imagePath, fit: BoxFit.cover);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: property))),
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: Offset(0, 5))]),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 132, height: 178, child: image),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 14, 8, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(property['label'] ?? 'Property', style: TextStyle(color: lightBlue, fontWeight: FontWeight.bold, fontSize: 12))),
                    FavoriteButton(property: property),
                  ]),
                  SizedBox(height: 4),
                  Text(property['title']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(property['city']!, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  SizedBox(height: 10),
                  Text(property['price']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: lightBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 9),
                  Row(children: [
                    iconInfo(Icons.bed, property['beds'] ?? '0'),
                    SizedBox(width: 10),
                    iconInfo(Icons.bathtub, property['baths'] ?? '0'),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  final Map<String, String> property;

  const FavoriteButton({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: PropertyData.favoritesChanged,
      builder: (context, _, __) => IconButton(
        tooltip: PropertyData.isFavorite(property) ? 'Remove favorite' : 'Add favorite',
        icon: Icon(
          PropertyData.isFavorite(property) ? Icons.favorite : Icons.favorite_border,
          color: lightBlue,
          size: 26,
        ),
        onPressed: () => PropertyData.toggleFavorite(property),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        children: [
          ListTile(leading: Icon(Icons.notifications, color: lightBlue), title: Text('New properties available'), subtitle: Text('Fresh listings are ready to explore.')),
          ListTile(leading: Icon(Icons.location_on, color: lightBlue), title: Text('Search update'), subtitle: Text('Explore properties across Sri Lanka.')),
        ],
      ),
    );
  }
}

class PropertyCategoryScreen extends StatefulWidget {
  final String category;

  const PropertyCategoryScreen({super.key, required this.category});

  @override
  State<PropertyCategoryScreen> createState() => _PropertyCategoryScreenState();
}

class _PropertyCategoryScreenState extends State<PropertyCategoryScreen> {
  final searchController = TextEditingController();
  late List<Map<String, String>> filteredProperties;

  @override
  void initState() {
    super.initState();
    _filterProperties('');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterProperties(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    setState(() {
      filteredProperties = PropertyData.all.where((property) {
        final matchesCategory = property['category'] == widget.category;
        final location = property['city']!.toLowerCase();
        return matchesCategory &&
            (normalizedQuery.isEmpty || location.contains(normalizedQuery));
      }).toList();
    });
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: lightBlue)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} properties')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: _filterProperties,
              decoration: InputDecoration(
                hintText: 'Search city or town',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _filterProperties('');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredProperties.length} properties',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: filteredProperties.length,
              itemBuilder: (context, index) {
                final property = filteredProperties[index];
                final title = property['title']!;
                final city = property['city']!;
                final displayTitle = title.endsWith(city) ? title : '$title, $city';
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailScreen(property: property),
                        ),
                      );
                    },
                    leading: SizedBox(
                      width: 64,
                      height: 64,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _resultImage(property),
                      ),
                    ),
                    title: Text(displayTitle),
                    subtitle: Text(
                      '${property['transactionType']} | $city\n'
                      'Area: ${property['area']}\n'
                      'Price: ${property['price']}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (property['bedrooms']!.isNotEmpty)
                          Text('${property['bedrooms']} bd\n${property['bathrooms']} ba'),
                        FavoriteButton(property: property),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultImage(Map<String, String> property) {
    final imagePath = property['image']!;
    if (imagePath.startsWith('lib/')) {
      return Image.asset(imagePath, fit: BoxFit.cover);
    }
    return Image.network(imagePath, fit: BoxFit.cover);
  }
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, size: 28)),
                  Expanded(
                    child: Column(
                      children: [
                        Text('LiveSmartAI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightBlue)),
                        Text('Your AI Property Assistant', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  IconButton(tooltip: 'Search history', onPressed: () {}, icon: Icon(Icons.history, size: 27)),
                  IconButton(tooltip: 'More options', onPressed: () {}, icon: Icon(Icons.more_horiz, size: 28)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(18, 22, 18, 18),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [Icon(Icons.auto_awesome, color: lightBlue), SizedBox(width: 8), Text('Try asking me', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))]),
                              TextButton.icon(onPressed: () => setState(() { _messages.removeWhere((message) => message['sender'] == 'user'); _assistantProperties = []; }), icon: Icon(Icons.refresh, color: lightBlue), label: Text('Refresh', style: TextStyle(color: lightBlue))),
                            ],
                          ),
                          SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.8,
                            children: _quickSuggestions.map((suggestion) => InkWell(
                              onTap: () => _sendMessage(suggestion['text']!),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: Color(0xfff4f7fd), borderRadius: BorderRadius.circular(18)),
                                child: Row(children: [Icon(Icons.home_outlined, color: lightBlue, size: 23), SizedBox(width: 8), Expanded(child: Text(suggestion['text']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5))) ]),
                              ),
                            )).toList(),
                          ),
                          SizedBox(height: 24),
                          _buildMessageBubble(_messages.first),
                          if (_messages.length > 1) ..._messages.skip(1).map(_buildMessageBubble),
                          if (_assistantProperties.isNotEmpty) ...[
                            SizedBox(height: 12),
                            Row(children: [Icon(Icons.inventory_2_outlined, color: lightBlue), SizedBox(width: 8), Text('${_assistantProperties.length} Properties found', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), Spacer(), Text('View all', style: TextStyle(color: lightBlue, fontWeight: FontWeight.bold))]),
                            SizedBox(height: 12),
                            ..._assistantProperties.map((property) => _propertyCard(property)),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(14, 12, 14, 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
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
                              child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: lightBlue, size: 27),
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
                                        hintText: 'Type your property request...',
                                        hintStyle: TextStyle(fontSize: 15),
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
                                color: lightBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.send_rounded, color: Colors.white, size: 25),
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
              decoration: BoxDecoration(color: lightBlue, shape: BoxShape.circle),
              child: Icon(Icons.star, color: Colors.white, size: 20),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? lightBlue : Colors.grey[200],
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
              decoration: BoxDecoration(color: lightBlue, shape: BoxShape.circle),
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
                      _badge(property['tag']!, paleBlue),
                      Icon(Icons.favorite_border, color: Colors.grey[600]),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(property['location']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  SizedBox(height: 6),
                  Text(property['title']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(property['price']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: lightBlue)),
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
    final imagePath = property['image']!;
    final contactNumber = property['contactNumber'] ?? 'Not shown';
    final propertyTitle = '${property['category']} for ${property['transactionType']} '
        'in ${property['streetName'] ?? property['location']}, ${property['city'] ?? ''}';
    return Scaffold(
      appBar: AppBar(
        title: Text(propertyTitle),
        actions: [FavoriteButton(property: property)],
      ),
      body: ListView(
        children: [
          imagePath.startsWith('lib/')
              ? Image.asset(imagePath, height: 300, width: double.infinity, fit: BoxFit.cover)
              : Image.network(imagePath, height: 300, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(propertyTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                SizedBox(height: 8),
                Text(property['city'] ?? property['location']!, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                SizedBox(height: 12),
                Text(property['price']!, style: TextStyle(color: lightBlue, fontWeight: FontWeight.w700, fontSize: 22)),
                SizedBox(height: 18),
                _detailRow('Transaction', property['transactionType'] ?? ''),
                _detailRow('Area', property['area'] ?? ''),
                _detailRow('Location', property['exactLocation'] ?? property['location'] ?? ''),
                _detailRow('Special Features', property['specialFeatures'] ?? ''),
                Row(
                  children: [
                    iconInfo(Icons.bed, property['beds'] ?? '0'),
                    SizedBox(width: 18),
                    iconInfo(Icons.bathtub, property['baths'] ?? '0'),
                  ],
                ),
                SizedBox(height: 18),
                _detailRow('Contact Number', contactNumber),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showContactDialog(context, contactNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightBlue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Contact Owner', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showContactDialog(BuildContext context, String contactNumber) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Contact Number'),
        content: Text(contactNumber, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Close')),
          if (contactNumber != 'Not shown')
            ElevatedButton(
              onPressed: () async {
                final uri = Uri(scheme: 'tel', path: contactNumber);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: Text('Call'),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: lightBlue)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16)),
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
            Icon(Icons.map, size: 80, color: lightBlue),
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
