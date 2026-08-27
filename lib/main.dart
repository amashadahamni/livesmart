import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'data/property_data.dart';
import 'services/property_nlp.dart';

const lightBlue = Color(0xff3d8df5);
const paleBlue = Color(0xffe4efff);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LiveSmartApp());
}

Future<void> _saveAuthenticatedProfile(User user) async {
  final preferences = await SharedPreferences.getInstance();
  final nameParts = (user.displayName ?? '').trim().split(RegExp(r'\s+'));
  await preferences.setBool('account_signed_in', true);
  await preferences.setString('account_email', user.email ?? '');
  if (nameParts.isNotEmpty && nameParts.first.isNotEmpty) {
    await preferences.setString('profile_name', nameParts.first);
    await preferences.setString('profile_surname', nameParts.skip(1).join(' '));
  }
  await preferences.setString('profile_email', user.email ?? '');
}

Future<UserCredential> _authenticateWithGoogle() async {
  final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  await FirebaseAuth.instance.signOut();
  await googleSignIn.signOut();
  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) {
    throw FirebaseAuthException(code: 'sign-in-cancelled', message: 'Google sign-in was cancelled.');
  }
  final googleAuthentication = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuthentication.accessToken,
    idToken: googleAuthentication.idToken,
  );
  return FirebaseAuth.instance.signInWithCredential(credential);
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

// ================= 2. AUTHENTICATION =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    if (!email.contains('@') || password.length < 6) {
      _showMessage('Enter a valid email and a password with at least 6 characters.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      await _saveAuthenticatedProfile(credential.user!);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainApp()), (route) => false);
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(error.message ?? 'Unable to log in.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isSubmitting = true);
    try {
      final credential = await _authenticateWithGoogle();
      await _saveAuthenticatedProfile(credential.user!);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainApp()), (route) => false);
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(error.message ?? 'Google sign-in could not be completed.');
    } catch (error) {
      if (mounted) _showMessage('Google sign-in could not be completed. Check that Google is enabled in Firebase.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      child: Column(
        children: [
          const _AuthBrand(),
          const SizedBox(height: 20),
          const Text('Welcome Back!', style: TextStyle(color: Color(0xff071d69), fontSize: 31, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Log in to continue your property journey\nwith LiveSmart', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff66728d), height: 1.45, fontSize: 16)),
          const SizedBox(height: 22),
          Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: const Color(0xffeaf4ff), borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.home_work_rounded, size: 110, color: lightBlue)),
          const SizedBox(height: 20),
          _AuthPanel(
            children: [
              const _AuthLabel('Email'),
              _AuthField(controller: _emailController, hint: 'Enter your email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 18),
              const _AuthLabel('Password'),
              _AuthField(controller: _passwordController, hint: 'Enter your password', icon: Icons.lock_outline_rounded, obscureText: _hidePassword, suffix: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xff68748e)))),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => _showMessage('Password recovery will be available with Firebase authentication.'), child: const Text('Forgot Password?', style: TextStyle(color: lightBlue, fontWeight: FontWeight.w700)))),
              const SizedBox(height: 4),
              _AuthPrimaryButton(label: 'Log In', loading: _isSubmitting, onPressed: _login),
              const _AuthDivider(),
              _GoogleAuthButton(onPressed: _isSubmitting ? () {} : _loginWithGoogle),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Don't have an account? ", style: TextStyle(color: Color(0xff66728d))), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())), child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w800, color: lightBlue)))]),
            ],
          ),
        ],
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _accountPurpose = 'Both';
  bool _agreedToTerms = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty || !email.contains('@') || phone.length < 7 || password.length < 6 || password != _confirmPasswordController.text || !_agreedToTerms) {
      _showMessage('Complete all fields, use a 6+ character password, and accept the terms.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(name);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('account_phone', phone);
      await preferences.setString('account_purpose', _accountPurpose);
      await preferences.setString('profile_phone', phone);
      await preferences.setString('profile_account_role', _accountPurpose == 'Both' ? 'Both Buyer & Seller' : _accountPurpose == 'Buy' ? 'Buyer' : 'Seller');
      await _saveAuthenticatedProfile(credential.user!);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainApp()), (route) => false);
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(error.message ?? 'Unable to create your account.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isSubmitting = true);
    try {
      final credential = await _authenticateWithGoogle();
      await _saveAuthenticatedProfile(credential.user!);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainApp()), (route) => false);
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(error.message ?? 'Google sign-up could not be completed.');
    } catch (error) {
      if (mounted) _showMessage('Google sign-up could not be completed. Check that Google is enabled in Firebase.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff071d69))), const Spacer()]),
        const _AuthBrand(alignment: CrossAxisAlignment.start),
        const SizedBox(height: 18),
        const Text('Create Your Account', style: TextStyle(color: Color(0xff071d69), fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        const Text('Join LiveSmart and find your\nperfect property', style: TextStyle(color: Color(0xff66728d), height: 1.4, fontSize: 16)),
        const SizedBox(height: 22),
        _AuthPanel(children: [
          const _AuthLabel('Full Name'),
          _AuthField(controller: _nameController, hint: 'Enter your full name', icon: Icons.person_outline_rounded),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _AuthLabel('Email'), _AuthField(controller: _emailController, hint: 'Email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress)])), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _AuthLabel('Phone Number'), _AuthField(controller: _phoneController, hint: 'Phone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone)]))]),
          const SizedBox(height: 16),
          const _AuthLabel('Password'),
          _AuthField(controller: _passwordController, hint: 'Create a password', icon: Icons.lock_outline_rounded, obscureText: _hidePassword, suffix: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xff68748e)))),
          const SizedBox(height: 6),
          const Row(children: [Icon(Icons.verified_user_outlined, size: 17, color: Color(0xff268b7c)), SizedBox(width: 6), Text('Use 6+ characters for your password', style: TextStyle(color: Color(0xff66728d), fontSize: 12))]),
          const SizedBox(height: 16),
          const _AuthLabel('Confirm Password'),
          _AuthField(controller: _confirmPasswordController, hint: 'Confirm your password', icon: Icons.lock_outline_rounded, obscureText: _hideConfirmation, suffix: IconButton(onPressed: () => setState(() => _hideConfirmation = !_hideConfirmation), icon: Icon(_hideConfirmation ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xff68748e)))),
          const SizedBox(height: 18),
          const _AuthLabel('I am looking to'),
          const SizedBox(height: 8),
          Row(children: ['Buy', 'Sell', 'Both'].map((option) => Expanded(child: Padding(padding: EdgeInsets.only(right: option == 'Both' ? 0 : 8), child: _AccountPurposeOption(label: option, selected: _accountPurpose == option, onTap: () => setState(() => _accountPurpose = option))))).toList()),
          const SizedBox(height: 12),
          InkWell(onTap: () => setState(() => _agreedToTerms = !_agreedToTerms), child: Row(children: [Checkbox(value: _agreedToTerms, activeColor: lightBlue, onChanged: (value) => setState(() => _agreedToTerms = value ?? false)), const Expanded(child: Text('I agree to the Terms & Conditions and Privacy Policy', style: TextStyle(color: Color(0xff66728d), fontSize: 12)))])),
          const SizedBox(height: 8),
          _AuthPrimaryButton(label: 'Sign Up', loading: _isSubmitting, onPressed: _signUp),
          const _AuthDivider(),
          _GoogleAuthButton(onPressed: _isSubmitting ? () {} : _signUpWithGoogle),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Already have an account? ', style: TextStyle(color: Color(0xff66728d))), TextButton(onPressed: () => Navigator.pop(context), child: const Text('Log In', style: TextStyle(color: lightBlue, fontWeight: FontWeight.w800)))]),
        ]),
      ]),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  final Widget child;
  const _AuthScaffold({required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff5f9ff),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class _AuthBrand extends StatelessWidget {
  final CrossAxisAlignment alignment;
  const _AuthBrand({this.alignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: alignment, children: [Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: const Color(0xffeaf3ff), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.real_estate_agent_rounded, color: lightBlue, size: 34)), const SizedBox(width: 10), const Text('LiveSmart', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: Color(0xff071d69)))])]);
}

class _AuthPanel extends StatelessWidget {
  final List<Widget> children;
  const _AuthPanel({required this.children});

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: lightBlue.withValues(alpha: 0.10), blurRadius: 26, offset: const Offset(0, 10))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
}

class _AuthLabel extends StatelessWidget {
  final String text;
  const _AuthLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(color: Color(0xff101d48), fontSize: 15, fontWeight: FontWeight.w800)));
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  const _AuthField({required this.controller, required this.hint, required this.icon, this.obscureText = false, this.suffix, this.keyboardType});

  @override
  Widget build(BuildContext context) => TextField(controller: controller, obscureText: obscureText, keyboardType: keyboardType, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: const Color(0xff68748e)), suffixIcon: suffix, filled: true, fillColor: const Color(0xfffbfcff), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xffdbe4f1))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xffdbe4f1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: lightBlue, width: 1.5))));
}

class _AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _AuthPrimaryButton({required this.label, required this.loading, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 58, child: ElevatedButton(onPressed: loading ? null : onPressed, style: ElevatedButton.styleFrom(backgroundColor: lightBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))));
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text('OR', style: TextStyle(color: Color(0xff68748e), fontWeight: FontWeight.w700))), Expanded(child: Divider())]));
}

class _GoogleAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleAuthButton({required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 54, child: OutlinedButton.icon(onPressed: onPressed, icon: const Text('G', style: TextStyle(color: Color(0xffea4335), fontSize: 25, fontWeight: FontWeight.w900)), label: const Text('Continue with Google', style: TextStyle(color: Color(0xff33415e), fontSize: 16, fontWeight: FontWeight.w700)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xffdbe4f1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)))));
}

class _AccountPurposeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AccountPurposeOption({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 78,
      decoration: BoxDecoration(
        color: selected ? const Color(0xffeff6ff) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? lightBlue : const Color(0xffdbe4f1), width: selected ? 1.5 : 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(label == 'Buy' ? Icons.home_outlined : label == 'Sell' ? Icons.sell_outlined : Icons.real_estate_agent_outlined, color: selected ? lightBlue : const Color(0xff68748e)),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: selected ? lightBlue : const Color(0xff33415e), fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
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
              categoryItem(context, Icons.terrain, 'Land'),
              categoryItem(context, Icons.home, 'House'),
              categoryItem(context, Icons.apartment, 'Apartment'),
              categoryItem(context, Icons.business, 'Commercial'),
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

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  late final List<_LiveSmartNotification> _notifications;

  @override
  void initState() {
    super.initState();
    final listings = PropertyData.all;
    _notifications = [
      _LiveSmartNotification(type: _AlertType.newProperty, title: 'New Property Added', message: 'A newly listed property is now available near Colombo.', time: '2m ago', property: listings[4]),
      _LiveSmartNotification(type: _AlertType.priceDrop, title: 'Price Drop Alert', message: 'A property you saved has a new lower price.', time: '35m ago', property: listings[5]),
      _LiveSmartNotification(type: _AlertType.nearby, title: 'Properties Near You', message: 'We found new listings around Rajagiriya and Kotte.', time: '1h ago', property: listings[18]),
      _LiveSmartNotification(type: _AlertType.newProperty, title: 'New Apartment Available', message: 'A new apartment listing is ready for you to explore.', time: '2h ago', property: listings[24]),
      _LiveSmartNotification(type: _AlertType.discount, title: 'Special Discount Available!', message: 'Explore selected land listings with updated offers.', time: 'Yesterday, 6:30 PM', property: listings[1], isRead: true),
      _LiveSmartNotification(type: _AlertType.saved, title: 'Saved Property Update', message: 'The price or availability of a saved property changed.', time: 'Yesterday, 1:15 PM', property: listings[10], isRead: true),
      _LiveSmartNotification(type: _AlertType.message, title: 'You have a new message', message: 'A property agent replied to your enquiry.', time: 'May 15, 9:45 AM', isRead: true),
      _LiveSmartNotification(type: _AlertType.reminder, title: 'Viewing Reminder', message: 'You have a property viewing scheduled tomorrow at 10:00 AM.', time: 'May 14, 8:00 PM', property: listings[14], isRead: true),
    ];
  }

  List<_LiveSmartNotification> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    if (_selectedFilter == 'New Properties') return _notifications.where((item) => item.type == _AlertType.newProperty || item.type == _AlertType.nearby).toList();
    if (_selectedFilter == 'Price Drops') return _notifications.where((item) => item.type == _AlertType.priceDrop || item.type == _AlertType.discount).toList();
    return _notifications.where((item) => item.type == _AlertType.message).toList();
  }

  void _openNotification(_LiveSmartNotification notification) {
    setState(() => notification.isRead = true);
    if (notification.property != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: notification.property!)));
      return;
    }
    if (notification.type == _AlertType.message) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MessagesScreen()));
    }
  }

  void _markAllRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read.')));
  }

  int get _unreadCount => _notifications.where((item) => !item.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f9ff),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
          children: [
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]), child: const Icon(Icons.real_estate_agent_rounded, color: Color(0xff082170))),
              const SizedBox(width: 10),
              const Text('LiveSmart', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: Color(0xff071d69))),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded, color: Color(0xff071d69))),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded, color: Color(0xff071d69))),
            ]),
            const SizedBox(height: 30),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Notifications', style: TextStyle(fontSize: 33, fontWeight: FontWeight.w800, color: Color(0xff071d69))), SizedBox(height: 5), Text('Stay updated with your property alerts', style: TextStyle(fontSize: 15, color: Color(0xff68748e)))])),
              OutlinedButton.icon(onPressed: _unreadCount == 0 ? null : _markAllRead, icon: const Icon(Icons.done_all_rounded, size: 18), label: const Text('Mark all read'), style: OutlinedButton.styleFrom(foregroundColor: lightBlue, side: const BorderSide(color: lightBlue), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                _NotificationFilter(label: 'All', icon: Icons.notifications_none_rounded, active: _selectedFilter == 'All', count: _unreadCount, onTap: () => setState(() => _selectedFilter = 'All')),
                _NotificationFilter(label: 'New Properties', icon: Icons.home_work_outlined, active: _selectedFilter == 'New Properties', count: _notifications.where((item) => !item.isRead && (item.type == _AlertType.newProperty || item.type == _AlertType.nearby)).length, onTap: () => setState(() => _selectedFilter = 'New Properties')),
                _NotificationFilter(label: 'Price Drops', icon: Icons.sell_outlined, active: _selectedFilter == 'Price Drops', count: _notifications.where((item) => !item.isRead && (item.type == _AlertType.priceDrop || item.type == _AlertType.discount)).length, onTap: () => setState(() => _selectedFilter = 'Price Drops')),
                _NotificationFilter(label: 'Messages', icon: Icons.chat_bubble_outline_rounded, active: _selectedFilter == 'Messages', count: _notifications.where((item) => !item.isRead && item.type == _AlertType.message).length, onTap: () => setState(() => _selectedFilter = 'Messages')),
              ]),
            ),
            const SizedBox(height: 24),
            const Text('Today', style: TextStyle(fontSize: 18, color: Color(0xff68748e), fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ..._filteredNotifications.where((item) => !item.isRead).map((item) => _NotificationCard(notification: item, onTap: () => _openNotification(item))),
            if (_filteredNotifications.where((item) => item.isRead).isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Earlier', style: TextStyle(fontSize: 18, color: Color(0xff68748e), fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)]),
                child: Column(children: _filteredNotifications.where((item) => item.isRead).map((item) => _NotificationEarlierRow(notification: item, onTap: () => _openNotification(item))).toList()),
              ),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xffeaf3ff), borderRadius: BorderRadius.circular(18)),
              child: Row(children: [const Icon(Icons.notifications_active_rounded, color: lightBlue, size: 34), const SizedBox(width: 13), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Never miss an update!', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xff071d69))), SizedBox(height: 3), Text('Get alerts for new properties and price changes.', style: TextStyle(fontSize: 12, color: Color(0xff68748e)))])), FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property alerts are enabled.'))), style: FilledButton.styleFrom(backgroundColor: lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Enable'))]),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AlertType { newProperty, priceDrop, nearby, discount, saved, message, reminder }

class _LiveSmartNotification {
  final _AlertType type;
  final String title;
  final String message;
  final String time;
  final Map<String, String>? property;
  bool isRead;

  _LiveSmartNotification({required this.type, required this.title, required this.message, required this.time, this.property, this.isRead = false});
}

class _NotificationFilter extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final int count;
  final VoidCallback onTap;

  const _NotificationFilter({required this.label, required this.icon, required this.active, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: active ? lightBlue : Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.white : const Color(0xff10245f), size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xff10245f), fontWeight: FontWeight.w700)),
            if (count > 0) ...[
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xfff13245), shape: BoxShape.circle),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _LiveSmartNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  IconData get _icon => switch (notification.type) { _AlertType.newProperty => Icons.home_work_outlined, _AlertType.priceDrop => Icons.price_change_outlined, _AlertType.nearby => Icons.location_on_outlined, _AlertType.discount => Icons.sell_outlined, _AlertType.saved => Icons.favorite_border_rounded, _AlertType.message => Icons.chat_bubble_outline_rounded, _AlertType.reminder => Icons.notifications_none_rounded };
  Color get _color => switch (notification.type) { _AlertType.priceDrop => const Color(0xff16a34a), _AlertType.nearby => const Color(0xff6048cc), _AlertType.discount => const Color(0xffe8495b), _AlertType.saved => const Color(0xff2ab67a), _AlertType.message => lightBlue, _AlertType.reminder => const Color(0xffec8b2d), _ => lightBlue };

  @override
  Widget build(BuildContext context) {
    final imagePath = notification.property?['image'];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)]),
        child: Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: _color.withValues(alpha: 0.11), shape: BoxShape.circle), child: Icon(_icon, color: _color, size: 29)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(notification.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xff101d48))), const SizedBox(height: 4), Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, height: 1.3, color: Color(0xff5d6982))), const SizedBox(height: 7), Text(notification.property == null ? 'Open message' : 'View Property  ›', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: lightBlue))])),
          if (imagePath != null) ...[const SizedBox(width: 8), ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 78, height: 78, child: imagePath.startsWith('lib/') ? Image.asset(imagePath, fit: BoxFit.cover) : Image.network(imagePath, fit: BoxFit.cover)))],
          const SizedBox(width: 5), Column(children: [Text(notification.time, style: const TextStyle(fontSize: 11, color: Color(0xff65718b))), const SizedBox(height: 20), Container(width: 8, height: 8, decoration: const BoxDecoration(color: lightBlue, shape: BoxShape.circle))]),
        ]),
      ),
    );
  }
}

class _NotificationEarlierRow extends StatelessWidget {
  final _LiveSmartNotification notification;
  final VoidCallback onTap;

  const _NotificationEarlierRow({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = notification.type == _AlertType.message ? Icons.chat_bubble_outline_rounded : notification.type == _AlertType.reminder ? Icons.notifications_none_rounded : notification.type == _AlertType.saved ? Icons.favorite_border_rounded : Icons.sell_outlined;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffe8eef8)))),
        child: Row(children: [Container(width: 46, height: 46, decoration: const BoxDecoration(color: Color(0xffedf4ff), shape: BoxShape.circle), child: Icon(icon, color: lightBlue)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(notification.title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xff101d48))), const SizedBox(height: 3), Text(notification.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xff65718b)))])), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(notification.time, style: const TextStyle(fontSize: 10, color: Color(0xff65718b))), const SizedBox(height: 7), const Icon(Icons.chevron_right_rounded, color: Color(0xff65718b))])]),
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
  static const _historyKey = 'livesmart_ai_search_history';
  static const _historyRetention = Duration(hours: 72);
  final TextEditingController _messageController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _lastWords = '';
  List<Map<String, String>> _assistantProperties = [];
  late final Future<void> _historyReady;
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
  List<Map<String, dynamic>> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _historyReady = _loadSearchHistory();
    _initSpeech();
    _initTts();
  }

  Future<void> _loadSearchHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final storedHistory = preferences.getStringList(_historyKey) ?? [];
    final now = DateTime.now();
    final freshHistory = <Map<String, dynamic>>[];
    for (final encodedEntry in storedHistory) {
      try {
        final decodedEntry = jsonDecode(encodedEntry);
        if (decodedEntry is! Map) continue;
        final entry = Map<String, dynamic>.from(decodedEntry);
        final timestamp = DateTime.tryParse(entry['timestamp'] as String? ?? '');
        final age = timestamp == null ? null : now.difference(timestamp);
        if (age != null && age >= Duration.zero && age <= _historyRetention) {
          freshHistory.add(entry);
        }
      } on FormatException {
        // Ignore invalid legacy entries and retain the valid history.
      }
    }
    _searchHistory = freshHistory;
    await preferences.setStringList(
      _historyKey,
      freshHistory.map(jsonEncode).toList(),
    );
    if (mounted) setState(() {});
  }

  Future<void> _saveSearchHistory(String question, String answer) async {
    final now = DateTime.now();
    _searchHistory = [
      {
        'timestamp': now.toIso8601String(),
        'question': question,
        'answer': answer,
      },
      ..._searchHistory,
    ].where((entry) {
      final timestamp = DateTime.tryParse(entry['timestamp'] as String? ?? '');
      return timestamp != null && now.difference(timestamp) <= _historyRetention;
    }).toList();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _historyKey,
      _searchHistory.map(jsonEncode).toList(),
    );
    if (mounted) setState(() {});
  }

  void _showSearchHistory() {
    _openSearchHistory();
  }

  Future<void> _openSearchHistory() async {
    await _historyReady;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.history, color: lightBlue),
                  SizedBox(width: 10),
                  Text('Search history', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('Last 72 hours', style: TextStyle(color: lightBlue, fontWeight: FontWeight.w600)),
                ]),
                SizedBox(height: 6),
                Text('Your questions and LiveSmartAI answers', style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 16),
                Expanded(
                  child: _searchHistory.isEmpty
                      ? Center(child: Text('No searches in the last 72 hours'))
                      : ListView.separated(
                          itemCount: _searchHistory.length,
                          separatorBuilder: (_, __) => Divider(height: 24),
                          itemBuilder: (context, index) {
                            final entry = _searchHistory[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('You', style: TextStyle(color: lightBlue, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text(entry['question'] as String, style: TextStyle(fontSize: 16)),
                                SizedBox(height: 10),
                                Text('LiveSmartAI', style: TextStyle(color: lightBlue, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text(entry['answer'] as String, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice search error: ${error.errorMsg}')),
        );
      },
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    final hasPermission = await _speech.hasPermission;
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required for voice search.')),
        );
      }
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice search error: ${error.errorMsg}')),
        );
      },
    );

    if (!available || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice recognition is not available on this device.')),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _lastWords = '';
    });

    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      onResult: (result) {
        if (!mounted) return;
        final transcript = result.recognizedWords.trim();
        setState(() {
          _lastWords = transcript;
          _messageController.text = transcript;
          _messageController.selection = TextSelection.collapsed(offset: transcript.length);
        });
        if (result.finalResult && transcript.isNotEmpty) {
          setState(() => _isListening = false);
          _sendMessage(transcript);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
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

    Future.delayed(Duration(milliseconds: 250), () async {
      final response = _generateResponse(text);
      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'assistant', 'text': response['message']!});
        _assistantProperties = response['properties']!;
      });
      await _saveSearchHistory(text, response['message']!);
      _speak(response['message']!);
    });
  }

  Map<String, dynamic> _generateResponse(String query) {
    final result = PropertyNlp.answer(query, PropertyData.all);
    return {
      'message': result.answer,
      'properties': result.properties,
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
                  IconButton(tooltip: 'Search history', onPressed: _showSearchHistory, icon: Icon(Icons.history, size: 27)),
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
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<_ChatThread> _threads = [
    _ChatThread(
      name: 'Dilan Perera',
      role: 'Property Agent',
      online: true,
      phone: '+94771234567',
      preview: 'Hi! Yes, the property is still available. Would you like to know more?',
      time: '9:30 AM',
      unread: 2,
      badgeColor: Color(0xff3d8df5),
      propertyTitle: 'Modern Luxury House',
      propertyLocation: 'Malabe, Colombo',
      propertyPrice: 'Rs. 120,000,000',
      propertyImage: 'lib/data/LiveSmartImages/Land_Colombo1_1.png',
      messages: [
        _Message(sender: 'agent', text: 'Hi! Yes, the property is still available.'),
        _Message(sender: 'user', text: 'Would you like to know more about the property?'),
        _Message(sender: 'agent', text: 'Yes please! Can you send me more photos and details?'),
      ],
    ),
    _ChatThread(
      name: 'Nimasha Silva',
      role: 'Property Agent',
      online: true,
      phone: '+94777654321',
      preview: 'Thank you! I will send the documents shortly.',
      time: 'Yesterday',
      unread: 0,
      badgeColor: Color(0xff9ac2ff),
      propertyTitle: 'Luxury Apartment',
      propertyLocation: 'Kandy',
      propertyPrice: 'Rs. 80,000,000',
      propertyImage: 'lib/data/LiveSmartImages/Land_Colombo1_2.jpeg',
      messages: [
        _Message(sender: 'agent', text: 'Thank you! I will send the documents shortly.'),
      ],
    ),
    _ChatThread(
      name: 'Kasun Fernando',
      role: 'Property Seller',
      online: false,
      phone: '+94770000111',
      preview: 'Is the price negotiable? Please let me know.',
      time: 'Yesterday',
      unread: 1,
      badgeColor: Color(0xff5ca5ff),
      propertyTitle: 'Cozy Family Home',
      propertyLocation: 'Gampaha',
      propertyPrice: 'Rs. 65,000,000',
      propertyImage: 'lib/data/LiveSmartImages/Land_Colombo1_3.avif',
      messages: [
        _Message(sender: 'agent', text: 'Is the price negotiable? Please let me know.'),
      ],
    ),
    _ChatThread(
      name: 'John',
      role: 'Buyer',
      online: false,
      phone: '+94779998877',
      preview: 'Hey, is the house available?',
      time: 'May 12',
      unread: 0,
      badgeColor: Colors.grey,
      propertyTitle: 'Villa in Bentota',
      propertyLocation: 'Bentota',
      propertyPrice: 'Rs. 210,000,000',
      propertyImage: 'lib/data/LiveSmartImages/Land_Colombo1_4.jpeg',
      messages: [
        _Message(sender: 'user', text: 'Hey, is the house available?'),
        _Message(sender: 'agent', text: 'Yes, it is still available for viewing.'),
      ],
    ),
  ];

  int _selectedThreadIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendMessageToThread(_ChatThread thread, {String? overrideText}) {
    final text = (overrideText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    setState(() {
      thread.messages.add(_Message(sender: 'user', text: text));
      thread.preview = text;
      thread.time = 'Now';
      thread.unread = 0;
      _messageController.clear();
    });
  }

  Future<void> _startVoiceMessage(_ChatThread thread) async {
    if (_isListening) return;

    final hasPermission = await _speech.hasPermission;
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required for voice messages.')),
        );
      }
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice message error: ${error.errorMsg}')),
        );
      },
    );

    if (!available || !mounted) return;

    setState(() {
      _isListening = true;
      _messageController.clear();
    });

    await _speech.listen(
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: 'en_US',
      onResult: (result) {
        if (!mounted) return;
        final transcript = result.recognizedWords.trim();
        if (transcript.isEmpty) return;

        setState(() {
          _messageController.text = transcript;
          _messageController.selection = TextSelection.collapsed(offset: transcript.length);
        });

        if (result.finalResult) {
          setState(() => _isListening = false);
          _speech.stop();
          _sendMessageToThread(thread, overrideText: transcript);
        }
      },
    );
  }

  Future<void> _stopVoiceMessage() async {
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _openThread(_ChatThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ChatDetailScreen(thread: thread, onCall: () => _makeCall(thread.phone), onSend: (text) => _sendMessageToThread(thread, overrideText: text), onVoice: () => _startVoiceMessage(thread), onStopVoice: _stopVoiceMessage, isListening: _isListening)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thread = _threads[_selectedThreadIndex];
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xfff3f7ff),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 5)],
                    ),
                    child: Icon(Icons.home_rounded, color: lightBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LiveSmart',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: lightBlue),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search_rounded, color: Colors.black87, size: 28),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert_rounded, color: Colors.black87, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Messages',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                'Chat with agents, sellers and property experts',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(label: 'All', active: true),
                    _FilterChip(label: 'Unread', active: false),
                    _FilterChip(label: 'Agents', active: false),
                    _FilterChip(label: 'Sellers', active: false),
                    _FilterChip(label: 'Enquiries', active: false),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isWide)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16)],
                          ),
                          child: ListView.builder(
                            itemCount: _threads.length,
                            itemBuilder: (context, index) {
                              final item = _threads[index];
                              final selected = index == _selectedThreadIndex;
                              return InkWell(
                                onTap: () => _openThread(item),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: selected ? const Color(0xffeaf3ff) : const Color(0xfff8fbff),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: selected ? lightBlue.withValues(alpha: 0.6) : Colors.transparent),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: item.badgeColor,
                                        child: Text(item.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(child: Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                                                if (item.unread > 0)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(12)),
                                                    child: Text('${item.unread}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                                  ),
                                              ],
                                            ),
                                            Text(item.role, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                            const SizedBox(height: 6),
                                            Text(item.preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        children: [
                                          Text(item.time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                          const SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () => _makeCall(item.phone),
                                            child: Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(color: lightBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                                              child: Icon(Icons.call, color: lightBlue, size: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16)],
                          ),
                          child: Column(
                            children: [
                              _ChatHeader(
                                name: thread.name,
                                role: thread.role,
                                online: thread.online,
                                onCall: () => _makeCall(thread.phone),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xffedf4ff),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        thread.propertyImage,
                                        width: 118,
                                        height: 92,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(thread.propertyTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                                          const SizedBox(height: 4),
                                          Text(thread.propertyLocation, style: const TextStyle(color: Colors.black54)),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.bed_rounded, size: 16, color: lightBlue),
                                              const SizedBox(width: 4),
                                              const Text('4 Beds'),
                                              const SizedBox(width: 12),
                                              Icon(Icons.bathtub_rounded, size: 16, color: lightBlue),
                                              const SizedBox(width: 4),
                                              const Text('3 Baths'),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(thread.propertyPrice, style: TextStyle(fontWeight: FontWeight.w800, color: lightBlue, fontSize: 17)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: thread.messages.length,
                                  itemBuilder: (context, index) {
                                    final message = thread.messages[index];
                                    final isUser = message.sender == 'user';
                                    return Align(
                                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isUser ? lightBlue : const Color(0xffeef3f9),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          message.text,
                                          style: TextStyle(fontSize: 15, color: isUser ? Colors.white : Colors.black87),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.black54)),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xfff2f6fb),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: TextField(
                                        controller: _messageController,
                                        decoration: const InputDecoration(
                                          hintText: 'Type a message...',
                                          border: InputBorder.none,
                                        ),
                                        onSubmitted: (_) => _sendMessageToThread(thread),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _startVoiceMessage(thread),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(color: _isListening ? Colors.red : Colors.white, borderRadius: BorderRadius.circular(16)),
                                      child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: _isListening ? Colors.white : lightBlue),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _sendMessageToThread(thread),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(16)),
                                      child: const Icon(Icons.send_rounded, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14)],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _threads.length,
                          itemBuilder: (context, index) {
                            final item = _threads[index];
                            final selected = index == _selectedThreadIndex;
                            return InkWell(
                              onTap: () => _openThread(item),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xffebf4ff) : const Color(0xfff7fafe),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: item.badgeColor,
                                      child: Text(item.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                                              Text(item.time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(item.role, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                          const SizedBox(height: 6),
                                          Text(item.preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => _makeCall(item.phone),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(color: lightBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                                        child: Icon(Icons.call, color: lightBlue, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatDetailScreen extends StatefulWidget {
  final _ChatThread thread;
  final VoidCallback onCall;
  final void Function(String text) onSend;
  final VoidCallback onVoice;
  final VoidCallback onStopVoice;
  final bool isListening;

  const _ChatDetailScreen({
    required this.thread,
    required this.onCall,
    required this.onSend,
    required this.onVoice,
    required this.onStopVoice,
    required this.isListening,
  });

  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _isListening = widget.isListening;
  }

  Future<void> _startVoiceMessage() async {
    if (_isListening) return;

    final hasPermission = await _speech.hasPermission;
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required for voice messages.')),
        );
      }
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice message error: ${error.errorMsg}')),
        );
      },
    );

    if (!available || !mounted) return;

    setState(() => _isListening = true);

    await _speech.listen(
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: 'en_US',
      onResult: (result) {
        if (!mounted) return;
        final transcript = result.recognizedWords.trim();
        if (transcript.isEmpty) return;

        setState(() {
          _messageController.text = transcript;
          _messageController.selection = TextSelection.collapsed(offset: transcript.length);
        });

        if (result.finalResult) {
          setState(() => _isListening = false);
          _speech.stop();
          widget.onSend(transcript);
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _stopVoiceMessage() async {
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _sendCurrentText() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;
    return Scaffold(
      backgroundColor: const Color(0xfff3f8ff),
      appBar: AppBar(
        backgroundColor: const Color(0xfff3f8ff),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: thread.badgeColor,
              child: Text(thread.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(thread.name, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w700)),
                Text(thread.role, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: widget.onCall, icon: const Icon(Icons.call, color: lightBlue)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.videocam_rounded, color: lightBlue)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(thread.propertyImage, width: 110, height: 84, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(thread.propertyTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(thread.propertyLocation, style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 6),
                          Text(thread.propertyPrice, style: TextStyle(color: lightBlue, fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: thread.messages.length,
                  itemBuilder: (context, index) {
                    final message = thread.messages[index];
                    final isUser = message.sender == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser ? lightBlue : const Color(0xffedf3ff),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(fontSize: 15, color: isUser ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.add, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendCurrentText(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isListening ? _stopVoiceMessage : _startVoiceMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : const Color(0xffebf4ff),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: _isListening ? Colors.white : lightBlue),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendCurrentText,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatThread {
  final String name;
  final String role;
  final bool online;
  final String phone;
  String preview;
  String time;
  int unread;
  final Color badgeColor;
  final String propertyTitle;
  final String propertyLocation;
  final String propertyPrice;
  final String propertyImage;
  final List<_Message> messages;

  _ChatThread({
    required this.name,
    required this.role,
    required this.online,
    required this.phone,
    required this.preview,
    required this.time,
    required this.unread,
    required this.badgeColor,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.propertyPrice,
    required this.propertyImage,
    required this.messages,
  });
}

class _Message {
  final String sender;
  final String text;

  _Message({required this.sender, required this.text});
}

class _ChatHeader extends StatelessWidget {
  final String name;
  final String role;
  final bool online;
  final VoidCallback onCall;

  const _ChatHeader({required this.name, required this.role, required this.online, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: lightBlue,
          child: Text(name.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(role, style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(width: 8),
                  if (online)
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onCall,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: lightBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.call, color: lightBlue),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;

  const _FilterChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: active ? lightBlue : Colors.white,
        border: Border.all(color: active ? lightBlue : const Color(0xffdfeaf9)),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? Colors.white : Colors.black87)),
    );
  }
}

// ================= 6. LIVE MAP SCREEN =================
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _sriLankaCenter = LatLng(7.8731, 80.7718);
  static const Map<String, LatLng> _cityCoordinates = {
    'colombo': LatLng(6.9271, 79.8612),
    'kotte': LatLng(6.8905, 79.9010),
    'rajagiriya': LatLng(6.9091, 79.8946),
    'battaramulla': LatLng(6.9022, 79.9185),
    'malabe': LatLng(6.9064, 79.9608),
    'nugegoda': LatLng(6.8649, 79.8997),
    'galle': LatLng(6.0329, 80.2170),
    'matara': LatLng(5.9549, 80.5550),
    'kandy': LatLng(7.2906, 80.6337),
    'negombo': LatLng(7.2083, 79.8358),
    'kurunegala': LatLng(7.4863, 80.3647),
    'nuwara eliya': LatLng(6.9497, 80.7891),
    'gampaha': LatLng(7.0840, 80.0098),
    'dehiwala': LatLng(6.8515, 79.8657),
    'moratuwa': LatLng(6.7730, 79.8816),
    'panadura': LatLng(6.7132, 79.9026),
    'wattala': LatLng(6.9907, 79.8913),
    'kelaniya': LatLng(6.9560, 79.9216),
    'kadawatha': LatLng(7.0011, 79.9580),
    'homagama': LatLng(6.8426, 80.0035),
  };

  GoogleMapController? _mapController;
  String _category = 'All';
  String _query = '';
  Map<String, String>? _selectedProperty;

  List<Map<String, String>> get _properties => PropertyData.all.where((property) {
    final categoryMatches = _category == 'All' || property['category'] == _category;
    final text = '${property['title']} ${property['city']} ${property['location']}'.toLowerCase();
    return categoryMatches && text.contains(_query.toLowerCase());
  }).take(40).toList();

  LatLng _locationFor(Map<String, String> property) {
    final place = '${property['city']} ${property['location']}'.toLowerCase();
    for (final entry in _cityCoordinates.entries) {
      if (place.contains(entry.key)) return entry.value;
    }
    return _sriLankaCenter;
  }

  Future<void> _selectProperty(Map<String, String> property) async {
    final location = _locationFor(property);
    await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 12));
    if (mounted) setState(() => _selectedProperty = property);
  }

  Set<Marker> _markers(List<Map<String, String>> properties) {
    return properties.map((property) {
      final selected = _selectedProperty?['id'] == property['id'];
      return Marker(
        markerId: MarkerId(property['id'] ?? property['title'] ?? ''),
        position: _locationFor(property),
        icon: BitmapDescriptor.defaultMarkerWithHue(selected ? BitmapDescriptor.hueRose : BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: property['title'], snippet: property['city']),
        onTap: () => _selectProperty(property),
      );
    }).toSet();
  }

  Widget _categoryChip(String label, IconData icon) {
    final active = _category == label;
    return InkWell(
      onTap: () => setState(() {
        _category = label;
        _selectedProperty = null;
      }),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(color: active ? lightBlue : Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: active ? Colors.white : lightBlue, size: 17), const SizedBox(width: 5), Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xff10245f), fontWeight: FontWeight.w700, fontSize: 12))]),
      ),
    );
  }

  Widget _propertyPreview(Map<String, String> property) {
    final imagePath = property['image']!;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: property))),
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 18, offset: const Offset(0, 8))]),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 94, height: 82, child: imagePath.startsWith('lib/') ? Image.asset(imagePath, fit: BoxFit.cover) : Image.network(imagePath, fit: BoxFit.cover))),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(property['title'] ?? 'Property', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xff10245f))),
            const SizedBox(height: 5),
            Text(property['city'] ?? property['location'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xff64708f))),
            const SizedBox(height: 7),
            Text(property['price'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: lightBlue)),
          ])),
          IconButton(onPressed: () => setState(() => _selectedProperty = null), icon: const Icon(Icons.close_rounded, color: Color(0xff64708f))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final properties = _properties;
    return Scaffold(
      backgroundColor: const Color(0xfff5f8ff),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: Column(children: [
              Row(children: [
                IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff10245f))),
                const Expanded(child: Column(children: [Text('Live Map', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Color(0xff10245f))), SizedBox(height: 2), Text('Explore properties around Sri Lanka', style: TextStyle(fontSize: 13, color: Color(0xff64708f)))])),
                IconButton(onPressed: () => _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_sriLankaCenter, 7.2)), icon: const Icon(Icons.my_location_rounded, color: Color(0xff10245f))),
              ]),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(hintText: 'Search location, city or landmark...', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 10),
              SizedBox(height: 38, child: ListView(scrollDirection: Axis.horizontal, children: [_categoryChip('All', Icons.home_work_outlined), _categoryChip('House', Icons.house_outlined), _categoryChip('Apartment', Icons.apartment_outlined), _categoryChip('Commercial', Icons.business_outlined), _categoryChip('Land', Icons.landscape_outlined)])),
            ]),
          ),
          Expanded(
            child: Stack(children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(target: _sriLankaCenter, zoom: 7.2),
                onMapCreated: (controller) => _mapController = controller,
                markers: _markers(properties),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              Positioned(top: 14, left: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 8)]), child: Text('${properties.length} properties shown', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xff10245f))))),
              Positioned(right: 14, bottom: _selectedProperty == null ? 22 : 142, child: FloatingActionButton.small(onPressed: () => _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_sriLankaCenter, 7.2)), backgroundColor: Colors.white, foregroundColor: lightBlue, child: const Icon(Icons.my_location_rounded))),
              if (_selectedProperty != null) Align(alignment: Alignment.bottomCenter, child: _propertyPreview(_selectedProperty!)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ================= 7. PROFILE SCREEN =================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Dilan';
  String _surname = 'Perera';
  String _email = 'dilanperera99@gmail.com';
  String _phone = '+94 77 123 4567';
  String _username = 'dilan_perera';
  String _accountRole = 'Both Buyer & Seller';
  String _gender = 'Male';
  File? _profilePhoto;
  bool _hasUnsavedChanges = false;

  String get _fullName => '$_name $_surname';

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final photoPath = preferences.getString('profile_photo_path');
    if (!mounted) return;

    setState(() {
      _name = preferences.getString('profile_name') ?? _name;
      _surname = preferences.getString('profile_surname') ?? _surname;
      _email = preferences.getString('profile_email') ?? _email;
      _phone = preferences.getString('profile_phone') ?? _phone;
      _username = preferences.getString('profile_username') ?? _username;
      _accountRole = preferences.getString('profile_account_role') ?? _accountRole;
      _gender = preferences.getString('profile_gender') ?? _gender;
      if (photoPath != null && File(photoPath).existsSync()) {
        _profilePhoto = File(photoPath);
      }
    });
  }

  Future<void> _saveProfile() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('profile_name', _name);
    await preferences.setString('profile_surname', _surname);
    await preferences.setString('profile_email', _email);
    await preferences.setString('profile_phone', _phone);
    await preferences.setString('profile_username', _username);
    await preferences.setString('profile_account_role', _accountRole);
    await preferences.setString('profile_gender', _gender);
    if (_profilePhoto != null) {
      await preferences.setString('profile_photo_path', _profilePhoto!.path);
    }
    if (!mounted) return;

    setState(() => _hasUnsavedChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your profile changes have been saved.')),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (photo == null || !mounted) return;

    setState(() {
      _profilePhoto = File(photo.path);
      _hasUnsavedChanges = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo selected. Tap Save Changes to keep it.')),
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final surnameController = TextEditingController(text: _surname);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);
    final usernameController = TextEditingController(text: _username);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffd8e1ee),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Edit Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                _ProfileTextField(controller: nameController, label: 'Name'),
                _ProfileTextField(controller: surnameController, label: 'Surname'),
                _ProfileTextField(controller: emailController, label: 'Email', keyboardType: TextInputType.emailAddress),
                _ProfileTextField(controller: phoneController, label: 'Contact number', keyboardType: TextInputType.phone),
                _ProfileTextField(controller: usernameController, label: 'Username'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _name = nameController.text.trim().isEmpty ? _name : nameController.text.trim();
                        _surname = surnameController.text.trim().isEmpty ? _surname : surnameController.text.trim();
                        _email = emailController.text.trim().isEmpty ? _email : emailController.text.trim();
                        _phone = phoneController.text.trim().isEmpty ? _phone : phoneController.text.trim();
                        _username = usernameController.text.trim().isEmpty ? _username : usernameController.text.trim();
                        _hasUnsavedChanges = true;
                      });
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Apply Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully.')));
    }
  }

  Future<void> _changePassword() async {
    final passwordController = TextEditingController();
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, passwordController.text.trim().length >= 6),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (!mounted || changed == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(changed ? 'Password updated.' : 'Use at least 6 characters for the password.')),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showNotice(String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title will be available shortly.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f9ff),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                    ),
                    child: Icon(Icons.real_estate_agent_rounded, color: const Color(0xff092273), size: 30),
                  ),
                  const SizedBox(width: 10),
                  const Text('LiveSmart', style: TextStyle(color: Color(0xff071d69), fontSize: 28, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(onPressed: () => _showNotice('Notifications'), icon: const Icon(Icons.notifications_none_rounded, color: Color(0xff071d69))),
                  IconButton(onPressed: () => _showNotice('Settings'), icon: const Icon(Icons.settings_outlined, color: Color(0xff071d69))),
                ],
              ),
              const SizedBox(height: 30),
              const Text('My Profile', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Color(0xff071d69))),
              const SizedBox(height: 5),
              const Text('Manage your account and\npersonal information', style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xff64708f))),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xff0866f4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: lightBlue.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 9))],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 390;
                    final avatar = Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: compact ? 43 : 48,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: compact ? 38 : 43,
                            backgroundColor: const Color(0xffe4edf9),
                            backgroundImage: _profilePhoto == null ? null : FileImage(_profilePhoto!),
                            child: _profilePhoto == null ? Icon(Icons.person_rounded, size: compact ? 50 : 58, color: const Color(0xff315c9f)) : null,
                          ),
                        ),
                        Positioned(
                          bottom: -3,
                          right: -3,
                          child: InkWell(
                            onTap: _pickProfilePhoto,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: lightBlue, width: 2)),
                              child: Icon(Icons.camera_alt_outlined, size: 20, color: lightBlue),
                            ),
                          ),
                        ),
                      ],
                    );
                    final details = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: compact ? 20 : 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.location_on_outlined, color: Colors.white, size: 18), SizedBox(width: 4), Flexible(child: Text('Colombo, Sri Lanka', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 14)))]),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.verified_rounded, color: lightBlue, size: 17), SizedBox(width: 4), Text('Verified User', style: TextStyle(color: lightBlue, fontWeight: FontWeight.w700, fontSize: 12))]),
                        ),
                      ],
                    );
                    final editButton = OutlinedButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(foregroundColor: lightBlue, backgroundColor: Colors.white, side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(alignment: Alignment.centerRight, child: editButton),
                          const SizedBox(height: 4),
                          Row(children: [avatar, const SizedBox(width: 16), Expanded(child: details)]),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        avatar,
                        const SizedBox(width: 18),
                        Expanded(child: details),
                        const SizedBox(width: 8),
                        Align(alignment: Alignment.topRight, child: editButton),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              _ProfileSection(
                icon: Icons.person_rounded,
                title: 'Personal Information',
                children: [
                  _ProfileRow(icon: Icons.badge_outlined, label: 'Name', value: _name, onTap: _editProfile),
                  _ProfileRow(icon: Icons.badge_outlined, label: 'Surname', value: _surname, onTap: _editProfile),
                  _ProfileRow(icon: Icons.mail_outline_rounded, label: 'Email', value: _email, onTap: _editProfile),
                  _ProfileRow(icon: Icons.phone_outlined, label: 'Contact Number', value: _phone, onTap: _editProfile),
                  _ProfileChoiceRow(label: 'Status', icon: Icons.manage_accounts_outlined, options: const ['Buyer', 'Seller', 'Both Buyer & Seller'], selected: _accountRole, onSelected: (value) => setState(() {
                    _accountRole = value;
                    _hasUnsavedChanges = true;
                  })),
                  _ProfileRow(icon: Icons.person_outline_rounded, label: 'Username', value: _username, onTap: _editProfile, isLast: true),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileSection(
                icon: Icons.shield_outlined,
                title: 'Account & Security',
                children: [
                  _ProfileRow(icon: Icons.lock_outline_rounded, label: 'Password', value: '........', onTap: _changePassword),
                  _ProfileRow(icon: Icons.lock_reset_rounded, label: 'Change Password', value: 'Change / Edit', onTap: _changePassword, isAction: true, isLast: true),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileSection(
                icon: Icons.tune_rounded,
                title: 'Preferences',
                children: [
                  _ProfileChoiceRow(label: 'Gender', icon: Icons.wc_rounded, options: const ['Male', 'Female', 'Other'], selected: _gender, onSelected: (value) => setState(() {
                    _gender = value;
                    _hasUnsavedChanges = true;
                  }), isLast: true),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileSection(
                children: [
                  _ProfileRow(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () => _showNotice('Help & Support')),
                  _ProfileRow(icon: Icons.article_outlined, label: 'Terms & Conditions', onTap: () => _showNotice('Terms & Conditions')),
                  _ProfileRow(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () => _showNotice('Privacy Policy'), isLast: true),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _hasUnsavedChanges ? _saveProfile : null,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_hasUnsavedChanges ? 'Save Changes' : 'All Changes Saved', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xffdbe8fa),
                    disabledForegroundColor: const Color(0xff6c7d98),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xffee3151), backgroundColor: const Color(0xffffedf0), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final List<Widget> children;

  const _ProfileSection({this.icon, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)]),
      child: Column(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Row(children: [Icon(icon, color: lightBlue), const SizedBox(width: 14), Text(title!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xff071d69)))]),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isAction;
  final bool isLast;

  const _ProfileRow({required this.icon, required this.label, this.value, required this.onTap, this.isAction = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xffe8eef8)))),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff3974bf), size: 23),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff071d69)))),
            if (value != null)
              Flexible(
                child: Container(
                  padding: isAction ? const EdgeInsets.symmetric(horizontal: 10, vertical: 7) : null,
                  decoration: isAction ? BoxDecoration(color: const Color(0xffeaf3ff), borderRadius: BorderRadius.circular(10)) : null,
                  child: Text(value!, overflow: TextOverflow.ellipsis, style: TextStyle(color: isAction ? lightBlue : const Color(0xff68748e), fontWeight: isAction ? FontWeight.w700 : FontWeight.w500)),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xff73809a)),
          ],
        ),
      ),
    );
  }
}

class _ProfileChoiceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isLast;

  const _ProfileChoiceRow({required this.icon, required this.label, required this.options, required this.selected, required this.onSelected, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 15),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xffe8eef8)))),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          final selector = SizedBox(
            height: 38,
            child: Row(
              children: options.map((option) {
                final active = option == selected;
                return Expanded(
                  child: InkWell(
                    onTap: () => onSelected(option),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: active ? lightBlue : Colors.white, border: Border.all(color: active ? lightBlue : const Color(0xffdce5f2)), borderRadius: BorderRadius.circular(8)),
                      child: Text(option, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? Colors.white : const Color(0xff62708b), fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  ),
                );
              }).toList(),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(icon, color: const Color(0xff3974bf), size: 23), const SizedBox(width: 16), Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff071d69)))]),
                const SizedBox(height: 12),
                selector,
              ],
            );
          }

          return Row(
            children: [
              Icon(icon, color: const Color(0xff3974bf), size: 23),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff071d69))),
              const SizedBox(width: 12),
              Expanded(child: selector),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  const _ProfileTextField({required this.controller, required this.label, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
