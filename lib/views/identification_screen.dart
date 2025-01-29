import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leafy_lenz/services/auth_services.dart';
import 'package:leafy_lenz/services/db_services.dart';
import 'generate_guide_screen.dart';
import 'dart:developer' as devtools;

class IdentificationScreen extends StatefulWidget {

  const IdentificationScreen({super.key});

  @override
  State<IdentificationScreen> createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {

  File? filePath;
  String label = '';
  double conf = 0.0;
  final _auth = AuthService();
  final _store = DataBaseService();
  String?  uid;
  late Stream<DocumentSnapshot> mycoins;
  int currentCoins = 0;

  RewardedAd? rewardedAd;
  int rewardscore = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Tflite.close();
    _tfliteInit();
    _initializeUid();
    loadrewardads();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Tflite.close();
    print("Model closed 1");
    super.dispose();
  }

  loadrewardads(){
    RewardedAd.load(
        adUnitId: "ca-app-pub-3940256099942544/5224354917",
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad){
              setState(() {
                rewardedAd = ad;
              });
            },
            onAdFailedToLoad: (error){
              setState(() {
                rewardedAd = null;
              });
            }
        )
    );
  }

  showads(){
    if (rewardedAd != null){
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad){
          setState(() {
            rewardedAd!.dispose();
            loadrewardads();
          });
        },
        onAdFailedToShowFullScreenContent: (ad, error){
          rewardedAd!.dispose();
          loadrewardads();
        },
      );
      rewardedAd!.show(onUserEarnedReward: (ad, reward){
        setState(() {
          _store.incrementCoins(uid!);
        });
      });
    }
  }


  Future<void> _tfliteInit() async{
    String? res = await Tflite.loadModel(
        model: "asset/model_unquant.tflite",
        labels: "asset/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
  }

  Future<void> pickImageGallery(String uid) async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);


    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );
    if (recognitions == null) {
      return;
    }
    await _store.decrementCoinsSafely(uid);
    devtools.log(recognitions.toString());
    setState(() {
      conf = recognitions[0]['confidence'];
      label = recognitions[0]['label'];
    });
  }

  //Function to capture an image using the camera
  Future<void> captureImage(String uid) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        filePath = File(image.path);
      });

      var recognitions = await Tflite.runModelOnImage(
          path: image.path,   // required
          imageMean: 0.0,   // defaults to 117.0
          imageStd: 255.0,  // defaults to 1.0
          numResults: 2,    // defaults to 5
          threshold: 0.2,   // defaults to 0.1
          asynch: true      // defaults to true
      );

      if (recognitions == null) {
        return;
      }
      await _store.decrementCoinsSafely(uid);
      devtools.log(recognitions.toString());
      setState(() {
        conf = recognitions[0]['confidence'];
        label = recognitions[0]['label'];
      });
    }
  }

  _initializeUid()  {
    uid = _auth.getUserId();
    if (uid != null) {
      setState(() {
        mycoins = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('details')
            .doc('info')
            .snapshots();
      });
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Plant Identification", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.green[700]),),
        backgroundColor: Colors.white,
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: mycoins,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("....");
              }
              if (snapshot.hasError) {
                return const Icon(Icons.error, color: Colors.red);
              }
              if(snapshot.hasData){
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final coins = data?['coins'] ?? 0;
                currentCoins = coins;

                return Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.yellow[700]), // Coin icon
                    const SizedBox(width: 5),
                    Text(
                      '$coins', // Adjust based on your data structure
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.green[600]),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: const Row(
                                children: [
                                  Icon(Icons.monetization_on, color: Colors.green, size: 30),
                                  SizedBox(width: 10),
                                  Text("Add Coins"),
                                ],
                              ),
                              content: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue, size: 24),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "To add coins, you need to watch an ad. Do you want to proceed?",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                    showads();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green, // Green button color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                                  ),
                                  child: const Text('Watch Ad', style: TextStyle(color: Colors.white),),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              }
              return const Text("Error");
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Title and Description
                Text(
                  "Identify your plants \n 5 coins!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Select an image of your plant to generate a personalized care guide.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Display the selected image (optional)
                if (filePath != null)
                  PredictionWindow(filePath: filePath, label: label, conf: conf)
                else
                  Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset("asset/leaf.png", fit: BoxFit.fitHeight,)
                      ),
                  ),
                  const SizedBox(height: 10,),

                // Buttons for Upload and Capture
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10,),

                    ElevatedButton.icon(onPressed: (){
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context){
                            double screenHeight = MediaQuery.of(context).size.height;
                            return Container(
                              padding: const EdgeInsets.all(20),
                              height: screenHeight * 0.35,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Select Image',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: (){
                                      if(currentCoins > 0){
                                        pickImageGallery(uid!);
                                        Navigator.pop(context);
                                      }
                                      else{
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // Icon at the top
                                                    Icon(
                                                      Icons.warning_amber_rounded,
                                                      size: 60,
                                                      color: Colors.orange[700],
                                                    ),
                                                    const SizedBox(height: 16),

                                                    // Title Text
                                                    Text(
                                                      "OUT OF COINS",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.red[700],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 10),

                                                    // Content Text
                                                    Text(
                                                      "Do you want to watch an ad to get 5 coins?",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[700],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 20),

                                                    // Action Buttons
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        // Cancel Button
                                                        ElevatedButton(
                                                          onPressed: () => Navigator.pop(context, 'Cancel'),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.grey[300],
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            "Cancel",
                                                            style: TextStyle(color: Colors.black),
                                                          ),
                                                        ),

                                                        // OK Button
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            showads();
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.green[600],
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            "Watch Ad",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );

                                      }
                                    },
                                    child: Card(
                                      elevation: 5,
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      child: ListTile(
                                        leading: Icon(Icons.photo_library, color: Colors.green[600]),
                                        title: const Text('Choose from Gallery'),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      if(currentCoins > 0){
                                        Navigator.pop(context);
                                        captureImage(uid!);
                                      }
                                      else{
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // Icon at the top
                                                    Icon(
                                                      Icons.warning_amber_rounded,
                                                      size: 60,
                                                      color: Colors.orange[700],
                                                    ),
                                                    const SizedBox(height: 16),

                                                    // Title Text
                                                    Text(
                                                      "OUT OF COINS",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.red[700],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 10),

                                                    // Content Text
                                                    Text(
                                                      "Do you want to watch an ad to get 5 coins?",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[700],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 20),

                                                    // Action Buttons
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        // Cancel Button
                                                        ElevatedButton(
                                                          onPressed: () => Navigator.pop(context, 'Cancel'),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.grey[300],
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            "Cancel",
                                                            style: TextStyle(color: Colors.black),
                                                          ),
                                                        ),

                                                        // OK Button
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            showads();
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.green[600],
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            "Watch Ad",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Card(
                                      elevation: 5,
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      child: ListTile(
                                        leading: Icon(Icons.camera_alt, color: Colors.green[600]),
                                        title: const Text('Capture Image'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                      );
                    }, label: const Text("Scan Plant", style: TextStyle(fontSize: 18),),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Button to proceed to the Guide Generation screen
                ElevatedButton(
                  onPressed: filePath != null
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GuideGenerationScreen(plantName: label), // Example name
                      ),
                    );
                  }
                      : null, // Disabled when no image is selected
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Generate Guide",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PredictionWindow extends StatelessWidget {
  const PredictionWindow({
    super.key,
    required this.filePath,
    required this.label,
    required this.conf,
  });

  final File? filePath;
  final String label;
  final double conf;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: FileImage(filePath!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),),
            const SizedBox(height: 7,),
            Text("Confidence: ${(conf * 100).toStringAsFixed(2)} %", style: const TextStyle(color: Colors.black, fontSize: 18),),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
