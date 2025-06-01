import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan4/app/modules/login/views/login_view.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return SignupScreen();
  }
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final SignupController signupController = Get.find<SignupController>();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (!signupController.acceptTerms.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harap setujui syarat dan ketentuan'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await signupController.signUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // Navy blue
              Color(0xFF3B82F6), // Blue
              Color(0xFF60A5FA), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 20,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Color(0xFFF8FAFC)],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Back Button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed('/login');
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF3B82F6).withOpacity(0.1),
                                  border: Border.all(
                                    color: Color(0xFF3B82F6).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF3B82F6),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Logo dan Header
                          TweenAnimationBuilder(
                            duration: Duration(milliseconds: 800),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1E3A8A),
                                        Color(0xFF3B82F6),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFF3B82F6,
                                        ).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.person_add,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 24),

                          // Title
                          Text(
                            'Buat Akun Baru',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Bergabung dengan Portal Sekolah',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),

                          SizedBox(height: 32),

                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Full Name Field
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller:
                                        signupController.fullNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nama Lengkap',
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: Color(0xFF3B82F6),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFF3B82F6),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama lengkap tidak boleh kosong';
                                      }
                                      if (value.length < 2) {
                                        return 'Nama lengkap minimal 2 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                SizedBox(height: 20),

                                // Email Field
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller:
                                        signupController.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Color(0xFF3B82F6),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFF3B82F6),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email tidak boleh kosong';
                                      }
                                      if (!RegExp(
                                        r'^[^@]+@[^@]+\.[^@]+',
                                      ).hasMatch(value)) {
                                        return 'Format email tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                SizedBox(height: 20),

                                // Password Field
                                Obx(
                                  () => AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller:
                                          signupController.passwordController,
                                      obscureText: signupController
                                          .isPasswordHidden
                                          .value,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: Color(0xFF3B82F6),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            signupController
                                                    .isPasswordHidden
                                                    .value
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: signupController
                                              .togglePasswordVisibility,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF3B82F6),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password tidak boleh kosong';
                                        }
                                        if (value.length < 6) {
                                          return 'Password minimal 6 karakter';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                // Confirm Password Field
                                Obx(
                                  () => AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: signupController
                                          .confirmPasswordController,
                                      obscureText: signupController
                                          .isConfirmPasswordHidden
                                          .value,
                                      decoration: InputDecoration(
                                        labelText: 'Konfirmasi Password',
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: Color(0xFF3B82F6),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            signupController
                                                    .isConfirmPasswordHidden
                                                    .value
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: signupController
                                              .toggleConfirmPasswordVisibility,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF3B82F6),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Konfirmasi password tidak boleh kosong';
                                        }
                                        if (value !=
                                            signupController
                                                .passwordController
                                                .text) {
                                          return 'Password tidak cocok';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),

                                SizedBox(height: 24),

                                // Terms and Conditions
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => Checkbox(
                                        value:
                                            signupController.acceptTerms.value,
                                        onChanged: signupController.toggleTerms,
                                        activeColor: Color(0xFF3B82F6),
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'Saya setuju dengan ',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Syarat & Ketentuan',
                                                style: TextStyle(
                                                  color: Color(0xFF3B82F6),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(text: ' dan '),
                                              TextSpan(
                                                text: 'Kebijakan Privasi',
                                                style: TextStyle(
                                                  color: Color(0xFF3B82F6),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 32),

                                // Sign Up Button
                                Obx(
                                  () => SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed:
                                          signupController.isLoading.value
                                          ? null
                                          : _handleSignup,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF1E3A8A),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 8,
                                        shadowColor: Color(
                                          0xFF1E3A8A,
                                        ).withOpacity(0.3),
                                      ),
                                      child: signupController.isLoading.value
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text('Mendaftar...'),
                                              ],
                                            )
                                          : Text(
                                              'DAFTAR',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 24),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'atau',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 24),

                                // Google Sign Up Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed:
                                        signupController.signUpWithGoogle,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Color(0xFF3B82F6),
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.g_mobiledata,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Daftar dengan Google',
                                          style: TextStyle(
                                            color: Color(0xFF1E3A8A),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32),

                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text(
                                  'Masuk Sekarang',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
