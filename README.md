# Multi-Modal Recognition Flutter App

This Flutter application demonstrates text recognition and speech-to-text capabilities. Using Google's ML Kit for text recognition and the `speech_to_text` package, the app can extract text from both camera images and gallery photos, and convert spoken words into text.

## Features

- **Text Recognition**: Extract text from images using the device camera or stored photos from the gallery, powered by Google ML Kit's Text Recognition.
- **Speech-to-Text**: Convert spoken words into text using the `speech_to_text` package.
- **Offline Functionality**: All features are available without requiring an internet connection.

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Arshad-02/Multi-modal-app.git
   cd multi-modal-app.git
   ```

2. **Install Dependencies**

   Ensure you have Flutter installed on your machine. Then, run the following command to install the project dependencies:

   ```bash
   flutter pub get
   ```

3. **Configure the Project**

   - **Android**: Ensure you have the required permissions for camera and storage access in your `AndroidManifest.xml` file.

     ```xml
     <uses-permission android:name="android.permission.CAMERA"/>
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
     ```

## Usage

1. **Text Recognition**

   - **From Camera**: Tap the camera icon to take a picture and extract text.
   - **From Gallery**: Tap the gallery icon to select an image from your device and extract text.

2. **Speech-to-Text**

   - Tap the microphone icon and speak into your device to convert speech to text.

## Packages Used

- [google_ml_kit](https://pub.dev/packages/google_ml_kit): For text recognition from images.
- [speech_to_text](https://pub.dev/packages/speech_to_text): For converting speech to text.
- [image_picker](https://pub.dev/packages/image_picker): For accessing camera and storage.

## Screenshots
<div style="display: flex; justify-content: space-between;">
  <img src="https://github.com/user-attachments/assets/dc231215-2dc9-4fa6-a2b1-693173ef06f3" width="30%" alt="Screenshot 1">
  <img src="https://github.com/user-attachments/assets/53db773a-8721-490e-82b5-387894f4b108" width="30%" alt="Screenshot 2">
  <img src="https://github.com/user-attachments/assets/5fd1a94c-68e4-44b2-a5bc-b8a31ebc48d0" width="30%" alt="Screenshot 3">
</div>









