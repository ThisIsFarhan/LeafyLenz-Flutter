# LeafyLenz - Plant Care Guide App

LeafyLenz is a **Flutter-based mobile application** that identifies rare plants using an **image classification model** and provides **AI-generated care guides** using **Gemini 1.5 Flash**. The app is backed by **Firebase**, ensuring seamless user authentication, real-time data storage, and cloud-based processing.

## Features
- **Rare Plant Identification:** Uses a trained **image classification model** to detect plant species.
- **AI-Generated Care Guides:** Provides detailed **care instructions** for rare plants using **Gemini 1.5 Flash**.
- **Firebase Authentication:** Secure user login and profile management.
- **Coin-Based Reward System:** Users earn coins for app engagement.
- **AdMob Integration:** Monetized with **Google AdMob ads** while maintaining a smooth user experience.

## Tech Stack
- **Flutter (Dart)**
- **Firebase (Auth, Firestore, Storage)**
- **Gemini 1.5 Flash (Generative AI Model)**
- **TensorFlow Lite (TFLite) / MediaPipe for Image Classification**
- **AdMob for Monetization**

## Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/ThisIsFarhan/LeafyLenz-Flutter.git
   ```
2. Open the project in **Android Studio** or **VS Code**.
3. Install dependencies:
   ```sh
   flutter pub get
   ```
4. Run the application:
   ```sh
   flutter run
   ```

## Usage
1. Capture or upload an image of a **plant**.
2. The app will **identify the plant** and generate a **care guide**.
3. Users can **earn coins by watching ads** and can scan more plants for generating guides.
4. **AdMob ads** are shown for monetization without disrupting the user experience.

