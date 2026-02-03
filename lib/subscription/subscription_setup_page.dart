import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/auth_service.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';

class SubscriptionSetupPage extends StatefulWidget {
  const SubscriptionSetupPage({super.key});

  @override
  State<SubscriptionSetupPage> createState() =>
      _SubscriptionSetupPageState();
}

class _SubscriptionSetupPageState extends State<SubscriptionSetupPage> {
  final TextEditingController _mobileController =
      TextEditingController();

  bool _loading = false;

  // ✅ PROPER LOGOUT METHOD (OUTSIDE build)
  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _activateSubscription() async {
    if (_loading) return;

    final mobile = _mobileController.text.trim();

    if (mobile.length != 10) {
      _show("Enter valid 10-digit mobile number");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      final now = DateTime.now();
      final endDate =
          DateTime(now.year + 1, now.month, now.day);

      // Create subscription
      final subRef =
          FirebaseFirestore.instance.collection('subscriptions').doc();

      await subRef.set({
        'uid': user.uid,
        'mobile': mobile,
        'status': 'ACTIVE',
        'startDate': now,
        'endDate': endDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'hasActiveSubscription': true,
        'subscriptionId': subRef.id,
        'lockedMobile': mobile,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }

    } catch (e) {
      _show("Failed to activate subscription");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0E),
      appBar: AppBar(
        title: const Text("Subscription Setup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Mobile Number",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This number will be locked for 12 months",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "10-digit mobile number",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _loading ? null : _activateSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : const Text(
                        "Proceed to Payment",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

