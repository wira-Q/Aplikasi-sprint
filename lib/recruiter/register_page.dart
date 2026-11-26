
import 'package:flutter/material.dart';
import 'onboarding1_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final picController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    picController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration inputStyle({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Arial',
        color: Colors.grey,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.black87,
        size: 18,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF667FC0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF2863E9),
          width: 1.5,
        ),
      ),
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 13,
            color: Color(0xFF222222),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: label == 'Email'
              ? TextInputType.emailAddress
              : TextInputType.text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontFamily: 'Arial',
          ),
          decoration: inputStyle(
            hint: hint,
            icon: icon,
            suffix: isPassword
                ? IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, ukuran) {
            final bool isDesktop = ukuran.maxWidth > 700;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER BIRU
                  Container(
                    width: double.infinity,
                    height: isDesktop ? 300 : 255,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF243F8F),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: isDesktop ? 100 : 85,
                          height: isDesktop ? 100 : 85,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 23,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Create a new account to get started\n'
                          'and access our features',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // FORM PUTIH
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 28,
                      vertical: 30,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                        bottom: Radius.circular(25),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 450,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PIC
                            buildField(
                              label: 'PIC',
                              controller: picController,
                              hint: 'Fill your PIC',
                              icon: Icons.person,
                            ),

                            const SizedBox(height: 15),

                            // EMAIL
                            buildField(
                              label: 'Email',
                              controller: emailController,
                              hint: 'Fill your email',
                              icon: Icons.email,
                            ),

                            const SizedBox(height: 15),

                            // PASSWORD
                            buildField(
                              label: 'Password',
                              controller: passwordController,
                              hint: 'Enter your password',
                              icon: Icons.key,
                              isPassword: true,
                              obscureText: obscurePassword,
                              onToggle: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),

                            const SizedBox(height: 15),

                            // CONFIRM PASSWORD
                            buildField(
                              label: 'Confirm Password',
                              controller: confirmPasswordController,
                              hint: 'Confirm your password',
                              icon: Icons.key,
                              isPassword: true,
                              obscureText: obscureConfirmPassword,
                              onToggle: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),

                            const SizedBox(height: 25),

                            // BUTTON SIGN UP
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (picController.text.trim().isEmpty ||
                                      emailController.text.trim().isEmpty ||
                                      passwordController.text.isEmpty ||
                                      confirmPasswordController
                                          .text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill in all fields!',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (passwordController.text !=
                                      confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password does not match!',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // PINDAH KE ONBOARDING 1
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Onboarding1Page(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2863E9),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFF1745A0),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // LINK LOGIN
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 11,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Sign In here',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 11,
                                        color: Color(0xFF243F8F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}