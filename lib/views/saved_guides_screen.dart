import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:leafy_lenz/services/auth_services.dart';
import 'package:lottie/lottie.dart';

import '../services/db_services.dart';
import 'guide_view.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _auth = AuthService();
  final _store = DataBaseService();
  List<Map<String, dynamic>> guides = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchGuides();
  }

  Future<void> fetchGuides() async {
    try {
      final userId = _auth.getUserId();
      if (userId != null) {
        final fetchedGuides = await _store.fetchGuides(userId);
        setState(() {
          guides = fetchedGuides;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching guides: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              fetchGuides(); // Trigger a refresh of the guides list
            },
            icon: const Icon(Icons.refresh, color: Colors.green),
          ),
        ],
        title: Text(
          "Leafy Lenz",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.green[700]),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green)
        ),
      )
          : guides.isEmpty
          ? buildIntroductoryScreen()
          : buildGuideCards(),
    );
  }


  Widget buildIntroductoryScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to LeafyLenz!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 30),
            // Lottie animation for an engaging visual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Lottie.asset(
                  'asset/boy-watering-plant.json', // Replace with your Lottie animation file path
                  height: 150,
                  repeat: true, frameRate: FrameRate.max
                ),
                Lottie.asset(
                  'asset/girl-watering-plant.json', // Replace with your Lottie animation file path
                  height: 150,
                  repeat: true,frameRate: FrameRate.max
                ),
              ]
            ),

            const SizedBox(height: 15),
            // Informative and motivational description
            const Text(
              "It seems like you haven’t created any guides yet.\nLet’s get started! Scan your plants using AI to generate personalized care guides.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            // Action button to prompt users to create guides
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green[600], // Green background color
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to the Guide Section",
                    style: TextStyle(
                      color: Colors.white, // White text
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Start saving your plant guides by clicking the 'identify' button below.",
                    style: TextStyle(
                      color: Colors.white, // White text
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }


  Widget buildGuideCards() {
    return ListView.builder(
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final guide = guides[index];

        return Card(
          elevation: 6, // Add elevation for a more prominent look
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[300]!], // Gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuideDetailsScreen(
                      title: guide['title'] ?? "Unknown Plant",
                      description: guide['description'] ?? "No description provided.",
                      timestamp: guide['timestamp'] ?? "No timestamp available",
                      guideId: guide['id'] ?? "No guide id available",
                    ),
                  ),
                );
              },
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: Icon(
                      Icons.eco,
                      color: Colors.green[600],
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      guide['title'] ?? "Unknown Plant",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Title text color
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide['description'] ?? "No description provided.",
                      maxLines: 3, // Limit to 3 lines
                      overflow: TextOverflow.ellipsis, // Display '...' at the end
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70, // Description text color
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                        const SizedBox(width: 5),
                        Text(
                          "Created on: ${guide['timestamp'] ?? 'No timestamp available'}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.green,
                  size: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }




}
