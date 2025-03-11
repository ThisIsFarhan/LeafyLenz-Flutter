import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:leafy_lenz/services/db_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../services/auth_services.dart';


class GuideGenerationScreen extends StatefulWidget {
  final String plantName; // Pass the detected plant name
  const GuideGenerationScreen({super.key, required this.plantName});

  @override
  State<GuideGenerationScreen> createState() => _GuideGenerationScreenState();
}

class _GuideGenerationScreenState extends State<GuideGenerationScreen> {
  final _auth = AuthService();
  final _store = DataBaseService();
  String guideTitle = '';
  String guideDescription = '';
  bool isLoading = true;
  bool isSaving = false;
  var uuid = const Uuid();
  DateTime now = DateTime.now();
  final api = "";




  @override
  void initState() {
    super.initState();
    generatePlantGuide();
  }

  // Simulate LLM call for generating a plant guide
  Future<void> generatePlantGuide() async {
    setState(() {
      isLoading = true;
    });
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: api,
    );
    final prompt = '''
      I am building a care guide database for various flowers. I will provide you with the name of a flower, and your task is to generate a concise yet detailed care guide for it.

      generate the guide for ${widget.plantName}
      The response should include:
      The sunlight requirements (e.g., full sun, partial shade).
      The watering schedule (e.g., frequent, occasional, avoid overwatering).
      Soil type and nutrients (e.g., well-drained, rich in organic matter).
      Any seasonal care tips (e.g., pruning, repotting, fertilizing).
      Please provide the guide in 2-4 sentences, ensuring it is easy to understand and actionable. Do not include any unrelated information. Output only the care guide.
    ''';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    print(response.text);

    setState(() {
          guideTitle = "Care Guide for ${widget.plantName}";
          guideDescription = response.text!;
          isLoading = false;
        });
    //Placeholder: Simulate API call or LLM response
    // await Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     guideTitle = "Care Guide for ${widget.plantName}";
    //     guideDescription =
    //     "The ${widget.plantName} requires moderate sunlight, regular watering, and a balanced fertilizer. "
    //         "Make sure the soil is well-drained, and avoid overwatering to prevent root rot.";
    //     isLoading = false;
    //   });
    // });
  }


  //Function to share the guide
  void shareGuide() {
    final String guideContent =
        "$guideTitle\n\n$guideDescription\n\nShared via LeafyLenz 🌱";
    Share.share(guideContent, subject: guideTitle);
  }

  Future<bool> checkDuplicateGuide(String title) async {
    String? uid = _auth.getUserId();
    List<Map<String, dynamic>> guides = await _store.fetchGuides(uid!);
    bool titleExists = guides.any((guide) => guide['title'] == title);
    print(titleExists);
    return titleExists;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Plant Care Guide",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),),
              SizedBox(height: 5,),
              Text("Generating your guide....."),
            ],
          )) // Loading state
          : Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guide Title
                    Text(
                      guideTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Guide Description
                    Container(
                      height: MediaQuery.of(context).size.height*0.5,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          guideDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Buttons: Save and Share
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed:() async {
                            setState(() {
                              isSaving = true;
                            });
                            try {
                              String? userId = _auth.getUserId();
                              String guideId = uuid.v4();
                              if(!(await checkDuplicateGuide(guideTitle))){
                                _store.addGuide(userId!, guideId, {
                                  "id": guideId,
                                  "title": guideTitle,
                                  "description": guideDescription,
                                  "timestamp": DateFormat('yyyy-MM-dd – kk:mm:ss').format(now),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guide saved!")));
                                setState(() {
                                  isSaving = false;
                                });
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guide already exists!")));

                                setState(() {
                                  isSaving = false;
                                });

                              }
                            }catch (e) {
                              // TODO
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error Saving the guide!")));
                              setState(() {
                                isSaving = false;
                              });
                            }
                          },
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text("Save Guide"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: shareGuide,
                          icon: const Icon(Icons.share),
                          label: const Text("Share Guide"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSaving)
                Container(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                        ),
                        SizedBox(height: 5,),
                        Text("Saving....")
                      ],
                    ),
                  ),
                ),
            ]
          ),
    );
  }
}

