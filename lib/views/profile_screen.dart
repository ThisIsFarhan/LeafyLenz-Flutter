import 'package:flutter/material.dart';
import 'package:leafy_lenz/services/auth_services.dart';
import 'package:leafy_lenz/services/db_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _store = DataBaseService();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final data = await _store.fetchUserDetails(_auth.getUserId()!);
    setState(() {
      userData = data;
    });
  }

  Future<void> signOut() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          title: const Text(
            "Sign Out",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent, // Highlight the warning
            ),
          ),
          content: const Text(
            "Are you sure you want to sign out?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _auth.signout();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Sign Out",
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.green[700]),
        ),
        backgroundColor: Colors.white,
        actions: [
          Icon(Icons.monetization_on, color: Colors.yellow[700]), // Coin icon
          const SizedBox(width: 5),
          Text(
            '${userData?['coins'] ?? "Loading..."}', // Adjust based on your data structure
            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: const Icon(Icons.logout, color: Colors.green),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
              ),
              // Profile Header Section
              _buildProfileHeader(),

              const SizedBox(height: 30),

              // Profile Details Section
              _buildProfileDetails(),

              const SizedBox(height: 35),

              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Divider(),
              ),

              // Action Buttons
              //_buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Circular Avatar Placeholder
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.green[600],
          child: Text(
            userData?['name']?.substring(0, 1).toUpperCase() ?? "?",
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 15),
        // User Name
        Text(
          userData?['name'] ?? "Loading...",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      children: [
        // Name Card
        ProfileInfoCard(
          label: "Name",
          value: userData?['name'] ?? "Loading...",
        ),
        const SizedBox(height: 15),

        // Email Card
        ProfileInfoCard(
          label: "Email",
          value: userData?['email'] ?? "Loading...",
        ),
        const SizedBox(height: 15),

        // Gender Card
        ProfileInfoCard(
          label: "Gender",
          value: userData?['gender'] ?? "Loading...",
        ),
        const SizedBox(height: 15),

        // Age Card
        ProfileInfoCard(
          label: "Age",
          value: userData?['age'] ?? "Loading...",
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Edit Profile Button
        ElevatedButton(
          onPressed: () {}, // No listeners for now
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Edit Profile",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 15),

        // View Guides Button
        ElevatedButton(
          onPressed: () {}, // No listeners for now
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "View Guides",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
          ],
        ),
      ),
    );
  }
}
