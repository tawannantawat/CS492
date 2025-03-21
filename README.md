# Cheese Sheet - Lecture Notes Marketplace

**Cheese Sheet** is a secure marketplace for buying and selling **Lecture Notes** while preventing unauthorized sharing.  

---

## 📌 Required Tools for Running the Project

This project is developed using Flutter. To run the code, you need to install the following tools:

- **[Flutter SDK](https://flutter.dev/docs/get-started/install)**
- **[Android Studio](https://developer.android.com/studio)**
- **[Java Development Kit (JDK)](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)**
- **[Git](https://git-scm.com/downloads)**

---

## 🚀 How to Run the Project

To run the project, use the following commands in **Terminal or Command Prompt**:

```sh
# Clone the project from GitHub
git clone https://github.com/tawannantawat/CS492.git
cd CS492

# Install dependencies
flutter pub get

# Run the application
flutter run

🔥 Firebase Configuration
Before running the project, you must correctly set up Firebase, or the app will not connect to the backend.

Steps to Set Up Firebase
Go to the Firebase Console
Create a new project and add an application for Android and iOS
Download the configuration files:
📂 For Android → google-services.json
📂 For iOS → GoogleService-Info.plist
Place the files inside:
🗂 Android → android/app/
🗂 iOS → iOS/Runner/
Use Firebase CLI to connect the project to Firebase.
📖 For more details, check the official docs:
🔗 Firebase Flutter Setup

🛠 Supabase Configuration
This project uses Supabase for database and storage. Follow these steps to configure it:

Steps to Set Up Supabase
Go to the Supabase Console
Create a new project and copy:
🌍 Project URL
🔑 Anon/Public API Key
Paste these values into:
📄 lib/config.dart
📄 .env
Use Supabase CLI to manage the database.
📖 For more details, check the official docs:
🔗 Supabase Getting Started
