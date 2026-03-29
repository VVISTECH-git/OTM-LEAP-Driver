import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leapdriver/core/theme/app_colors.dart';

/// Decorative login screen — shown when app is opened normally.
/// Drivers do NOT use this screen to authenticate.
/// Real entry point is always the SMS deep link → LoadDetailScreen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final instanceController = TextEditingController();
  final userIdController   = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword     = true;

  late AnimationController _formController;
  late AnimationController _logoController;
  late Animation<double>   _formAnimation;
  late Animation<double>   _logoAnimation;

  @override
  void initState() {
    super.initState();
    _formController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _logoController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _formAnimation =
        CurvedAnimation(parent: _formController, curve: Curves.easeOut);
    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.easeOut);

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 200), _formController.forward);
  }

  @override
  void dispose() {
    _formController.dispose();
    _logoController.dispose();
    instanceController.dispose();
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginTapped() {
    final c = context.colors;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please use the shipment link sent to your phone.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: c.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                _buildLogo(c),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(dynamic c) {
    return FadeTransition(
      opacity: _logoAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_logoAnimation),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.local_shipping,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Driver',
                    style: TextStyle(
                      color: c.navColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  TextSpan(
                    text: 'App',
                    style: TextStyle(
                      color: c.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FadeTransition(
      opacity: _formAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_formAnimation),
        child: Column(
          children: [
            _buildTextField(
              controller: instanceController,
              label: 'Instance URL',
              icon: Icons.link,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: userIdController,
              label: 'Username',
              icon: Icons.person,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscurePassword,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final c = context.colors;
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: c.navColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onLoginTapped,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}