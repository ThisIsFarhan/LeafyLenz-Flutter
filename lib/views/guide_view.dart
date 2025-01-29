import 'package:flutter/material.dart';
import 'package:leafy_lenz/services/db_services.dart';
import 'package:leafy_lenz/utils/wrapper.dart';

import '../services/auth_services.dart';

class GuideDetailsScreen extends StatefulWidget {
  final String title;
  final String description;
  final String timestamp;
  final String guideId;

  const GuideDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.guideId,
  });

  @override
  State<GuideDetailsScreen> createState() => _GuideDetailsScreenState();
}

class _GuideDetailsScreenState extends State<GuideDetailsScreen> {
  final _auth = AuthService();
  final _db = DataBaseService();
  bool isDeleting = false;

  Future<void> deleteGuide() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          title: const Text(
            "Delete Guide",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent, // Highlight the warning
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this guide? This action cannot be undone.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  isDeleting = true;
                });
                String? userId = _auth.getUserId();
                await _db.delGuide(userId!, widget.guideId);
                Navigator.of(context).pop(); // Close the dialog
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
                "Delete",
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
          "Plant Guide",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.green[700]),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await deleteGuide();
              setState(() {
                isDeleting = false;
                Navigator.pop(context);
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return Wrapper();}));
              });
            },
            icon: const Icon(Icons.delete, color: Colors.green),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Created on: ${widget.timestamp}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          ),
          if (isDeleting)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ]
      ),
    );
  }
}
