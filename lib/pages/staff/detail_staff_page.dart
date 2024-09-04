import 'package:flutter/material.dart';

class DetailStaffPage extends StatelessWidget {
  final String userId;
  final String farmName;
  final Map<String, dynamic> staffData;

  const DetailStaffPage({super.key, 
    required this.userId,
    required this.farmName,
    required this.staffData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Column(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('path_to_image'), // replace with actual path or use NetworkImage for URL
            ),
            const SizedBox(height: 10),
            Text(
              staffData['name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(staffData['email'] ?? 'No email'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bekerja di $farmName',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Role: ${staffData['role'] ?? 'No role'}'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Logic untuk edit role
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Join Date: ${staffData['join_date'] ?? 'No date'}'),
          ],
        ),
      ),
    );
  }
}
