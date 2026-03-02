import '../auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionIntroPage extends StatefulWidget {
  const SubscriptionIntroPage({super.key});

  @override
  State<SubscriptionIntroPage> createState() => _SubscriptionIntroPageState();
}

class _SubscriptionIntroPageState extends State<SubscriptionIntroPage> {
  bool _loading = false;

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
  }

  Future<void> _getStarted() async {
    if (_loading) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'subscriptionState': 'PENDING'});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to proceed")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0E),
      
      appBar: AppBar(
  	title: const Text("Subscription"),
  	actions: [
  	  IconButton(
  	    icon: const Icon(Icons.logout),
  	    onPressed: () => _logout(context),
  	  )
 	 ],
	),
	  
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get Started",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "• One mobile number only\n"
              "• Valid for 12 months\n"
              "• Unlimited recharges on this number\n"
              "• Number cannot be changed",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                ),
                onPressed: _loading ? null : _getStarted,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Get Started",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
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

