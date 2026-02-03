import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../transactions/transaction_repository.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _operator = "JIO";
  bool _loading = false;
  String? _lockedMobile;
  bool _loadingUser = true;


  // Single plan (locked)
  final int _amount = 379;
  final String _validity = "28 Days";
  final String _benefits = "Unlimited Calls • 2GB/day • 100 SMS/day";
  
  Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final data = doc.data();

  setState(() {
    _lockedMobile = data?['lockedMobile'];
    _loadingUser = false;
  });
}


  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _proceedToPay() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      if (_lockedMobile == null) {
       _show("No locked mobile number found");
       return;
   }

   final txnId = await TransactionRepository().createTransaction(
     uid: user.uid,
     mobile: _lockedMobile!, // ✅ REAL NUMBER
     operator: _operator,
     amount: _amount,
   );

      _show("Payment successful! Transaction ID: $txnId");
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Payment Successful"),
            content: Text("Your recharge for $_lockedMobile is being processed.\nTransaction ID: $txnId"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _show("Failed to create transaction");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
  
  @override
  void initState() {
  super.initState();
  _loadUserData();
}

  Widget _lockedNumberCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1F1E),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recharge Number",
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          _lockedMobile ?? "—",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
     return const Scaffold(
       body: Center(child: CircularProgressIndicator()),
     );
   }
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0E),
      appBar: AppBar(
        title: const Text("Mobile Recharge"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
	    _lockedNumberCard(),
	    const SizedBox(height: 24),
            _sectionTitle("Select Operator"),
            _operatorDropdown(),

            const SizedBox(height: 24),

            _sectionTitle("Recommended Plan"),
            _planCard(),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                ),
                onPressed: _loading ? null : _proceedToPay,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Proceed to Pay ₹379",
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _operatorDropdown() {
    return DropdownButton<String>(
      value: _operator,
      dropdownColor: const Color(0xFF1A1F1E),
      style: const TextStyle(color: Colors.white),
      items: const [
        DropdownMenuItem(value: "JIO", child: Text("Jio")),
        DropdownMenuItem(value: "AIRTEL", child: Text("Airtel")),
        DropdownMenuItem(value: "VI", child: Text("VI")),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _operator = value);
        }
      },
    );
  }

  Widget _planCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00C853)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "₹$_amount • $_validity",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _benefits,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _operatorPlanNote(),
            style: const TextStyle(
              color: Color(0xFF00C853),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _operatorPlanNote() {
    switch (_operator) {
      case "JIO":
        return "Best for Jio users • 5G where available";
      case "AIRTEL":
        return "Airtel unlimited calls + data";
      case "VI":
        return "VI unlimited benefits";
      default:
        return "";
    }
  }
}

