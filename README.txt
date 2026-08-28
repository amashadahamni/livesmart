LiveSmart - Project Run Instructions
=====================================

1. Project Overview
-------------------
LiveSmart is a Flutter property-search application for Sri Lankan properties.
It includes:
- Home page property categories and popular locations.
- LiveSmartAI typed and voice property search.
- Natural-language filtering by property type, transaction type, city,
  bedrooms, and budget.
- Property images, favourites, and full property details.
- Live Map using Google Maps with property city pins.
- Firebase authentication and Google sign-in.
- Text-to-speech responses and speech-to-text voice search.
- Property data imported from LiveSmartFinalExcel3 - Final.xlsx.

2. Main Feature: LiveSmartAI
-----------------------------
The main feature of this application is the LiveSmartAI property assistant.
From the home page, open LiveSmartAI using the AI option below the search
button in the navigation area. The user can then either type a request into
the message box or tap the microphone and give a voice command.

The AI understands property type, transaction type, city, bedrooms, and
budget. It displays matching results with the property image, city, price,
bedrooms, bathrooms, and a favourite button. Tap a result to open its full
individual property details page.

The following examples can be used to test the main AI feature:

    Hi / Hello
    Land for sale in Colombo?
    House for sale in Colombo under 100 Million Rupees
    Apartment for rent in Colombo?
    Commercial for rent?

For each property search, review the returned property cards. Test the
favourite button, then tap a property card to view its complete details.
Repeat the same examples using the microphone to test voice commands.

3. Requirements
---------------
Install the following before running the project:
- Flutter SDK compatible with Dart SDK 3.12.2 or later.
- Android Studio with Android SDK and an Android emulator or USB-connected
  Android phone.
- Java 17, normally supplied by Android Studio.
- An internet connection for Google Maps, Firebase, sign-in, and online data.

Check the installation with:

    flutter doctor

4. Install Dependencies
-----------------------
Open a terminal in the project root folder, the folder containing pubspec.yaml,
and run:

    flutter pub get

5. Run on an Android Phone
--------------------------
1. Enable Developer Options and USB debugging on the Android phone.
2. Connect the phone to the computer with USB.
3. Accept the USB debugging permission on the phone.
4. Check that Flutter detects the phone:

    flutter devices

5. Run the application:

    flutter run

To select a particular device, use its device ID from flutter devices:

    flutter run -d DEVICE_ID

The application starts on the home page. From there, the marker can open
LiveSmartAI, Live Map, favourites, notifications, and property categories.

6. Google Maps Setup
--------------------
The Android Maps key is read from android/app/google-services.json by the
Android Gradle configuration. The Android manifest uses this key for the
Google Maps SDK.

For Google Maps tiles to appear, the Google Cloud project connected to the
key must have the following enabled:
- Maps SDK for Android.
- Billing for the Google Cloud project.
- The Android application restriction must allow package:
  com.example.livesmart

If a separate local key is required, add this line to android/local.properties:

    MAPS_API_KEY=YOUR_GOOGLE_MAPS_ANDROID_KEY

Do not commit private API keys or passwords to the repository.

7. Firebase Setup
-----------------
The Android Firebase configuration is stored in:

    android/app/google-services.json

Firebase Authentication and Google Sign-In require the Firebase project to be
configured for the application package com.example.livesmart. The device must
have internet access when using those services.

8. Run Tests
------------
Run all Flutter tests with:

    flutter test

The current widget and NLP tests can be run directly with:

    flutter test test/widget_test.dart

9. Analyze the Code
-------------------
Run the Dart analyzer with:

    flutter analyze

Existing informational warnings may be reported by Flutter plugins or older
APIs. Compilation errors should be fixed before submission.

10. Build a Standalone Android APK
---------------------------------
To create an APK that can run directly on an Android phone without the phone
remaining connected to the development computer, run:

    flutter build apk --release

The APK is generated at:

    build/app/outputs/flutter-apk/app-release.apk

Install that APK on an Android phone, then open LiveSmart from the phone's
app launcher. A standalone installation does not require Flutter or a laptop
to remain connected. Internet access is still required for Google Maps,
Firebase, Google Sign-In, and voice services.

11. Main Project Files
---------------------
- lib/main.dart: application screens, navigation, LiveSmartAI, and Live Map.
- lib/data/property_data.dart: property model and data access.
- lib/data/property_data_excel3.dart: imported Excel3 property records.
- lib/services/property_nlp.dart: natural-language property filtering.
- lib/LiveSmartFinalExcel3 - Final.xlsx: source workbook.
- test/widget_test.dart: widget and NLP tests.
- pubspec.yaml: Flutter dependencies and bundled assets.
