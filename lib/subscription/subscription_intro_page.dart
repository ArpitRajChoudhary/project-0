import '../auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'subscription_setup_page.dart';

class SubscriptionIntroPage extends StatelessWidget {
  const SubscriptionIntroPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionSetupPage(),
                    ),
                  );
                },
                child: const Text(
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

