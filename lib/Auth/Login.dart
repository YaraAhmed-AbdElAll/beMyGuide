import 'package:app/Auth/SignUp.dart';
import 'package:app/Components/CustomIcon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Components/CustomTextFormField.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  final String userType;
  const Login({super.key, required this.userType});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isLoadingWithGoogle = false;

  // Sign in with Google
  Future<void> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return;

  setState(() => isLoadingWithGoogle = true);

  final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  final user = userCredential.user;
  final uid = user!.uid;

  // تحقق إذا المستخدم موجود في Firestore
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (!doc.exists) {
    // لو مش موجود، ضيفه
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      "firstName": googleUser.displayName?.split(' ').first ?? '',
      "lastName": googleUser.displayName?.split(' ').last ?? '',
      "email": googleUser.email,
      "userType": widget.userType, // النوع اللي مررته من الصفحة السابقة
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  setState(() => isLoadingWithGoogle = false);

  // بعد كده تنقليه للصفحة المناسبة
  if (widget.userType == 'user') {
    Navigator.of(context).pushReplacementNamed('userHome');
  } else {
    Navigator.of(context).pushReplacementNamed('volunteerHome');
  }
}
  // Sign in with Facebook
  Future<void> signInWithFacebook() async {
  final LoginResult loginResult = await FacebookAuth.instance.login(
    permissions: ['email', 'public_profile'],
  );

  if (loginResult.status == LoginStatus.success) {
    final userData = await FacebookAuth.instance.getUserData();
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    final user = userCredential.user;

    if (user != null) {
      String uid = user.uid;
      String fullName = userData['name'] ?? '';
      List<String> names = fullName.split(' ');
      String firstName = names.isNotEmpty ? names[0] : '';
      String lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
      String email = userData['email'] ?? '';

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'userType': widget.userType,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    Navigator.of(context).pushReplacementNamed('userHome');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Facebook login failed: ${loginResult.message}')),
    );
  }
}

  // Password Reset
  Future<void> resetPassword() async {
    if (email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email address"),
         
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'),),
      );
    }
  }

  // Login with Email & Password
  Future<void> loginWithEmail() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      setState(() => isLoading = false);

      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        Navigator.of(context).pushReplacementNamed('home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email first.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "Email",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Customtextformfield(
                        hintext: "Enter your email",
                        obscuretext: false,
                        myController: email,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Please enter your email" : null,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Customtextformfield(
                        hintext: "Enter your password",
                        obscuretext: true,
                        myController: password,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter your password';
                          if (val.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: resetPassword,
                          child: Text(
                            "Forget Password?",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 165, 177, 182),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(300, 50)
                          ),
                          onPressed: loginWithEmail,
                          child: const Text('Login',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      const SizedBox(height: 15),
                       Align(
                        alignment: Alignment.center,
                         child: Text(
                          "OR login with",
                          style: TextStyle(color:  const Color.fromARGB(255, 165, 177, 182),fontSize: 16,fontWeight: FontWeight.bold),
                                               ),
                       ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Customicon(
                            myIcon: FontAwesomeIcons.facebook,
                            iconColor: Colors.blue.shade700,
                            onPressed: signInWithFacebook,
                          ),
                          const SizedBox(width: 30),
                          Customicon(
                            myIcon: FontAwesomeIcons.google,
                            iconColor: Colors.red,
                            onPressed: isLoadingWithGoogle ? null : signInWithGoogle,
                            isLoading: isLoadingWithGoogle,
                          ),
                          const SizedBox(width: 30),
                          Customicon(
                            myIcon: FontAwesomeIcons.apple,
                            iconColor: Colors.grey.shade900,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
