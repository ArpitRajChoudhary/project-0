import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth/login_page.dart';
import 'home/home_page.dart';
import 'subscription/subscription_intro_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        // Not logged in
        if (user == null) {
          return const LoginPage();
        }

        // Logged in → now check subscription state
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // New Gmail OR profile not initialized yet
            if (!userSnapshot.hasData ||
                userSnapshot.data!.data() == null) {
              return const SubscriptionIntroPage();
            }

            final data =
                userSnapshot.data!.data() as Map<String, dynamic>;

            final hasSub =
                data['hasActiveSubscription'] == true;

            if (hasSub) {
              return const HomePage();
            } else {
              return const SubscriptionIntroPage();
            }
          },
        );
      },
    );
  }
}

