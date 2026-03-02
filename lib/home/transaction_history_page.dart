import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0E),
      appBar: AppBar(
        title: const Text("Transactions"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No transactions yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final status = data['status'];

              Color statusColor =
                  status == 'SUCCESS' ? Colors.green :
                  status == 'FAILED' ? Colors.red :
                  Colors.orange;
		  final timestamp = data['createdAt'];
  		  DateTime? date;

		  if (timestamp != null) {
		    date = timestamp.toDate();
	 	  }

		  return Card(
		    color: const Color(0xFF1A1F1E),
		    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
		    child: ListTile(
		      title: Text(
		        "₹${data['amount']}",
		        style: const TextStyle(color: Colors.white),
		      ),
		      subtitle: Column(
		        crossAxisAlignment: CrossAxisAlignment.start,
		        children: [
		          Text(
        		    status,
		            style: TextStyle(color: statusColor),
		          ),
		          if (date != null)
		            Text(
		              "${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute}",
		              style: const TextStyle(color: Colors.grey),
		            ),
		          if (data['txnid'] != null)
		            Text(
		              "Txn: ${data['txnid']}",
		              style: const TextStyle(color: Colors.grey),
		            ),
		        ],
		      ),
		    ),
		  );

            },
          );
        },
      ),
    );
  }
}

