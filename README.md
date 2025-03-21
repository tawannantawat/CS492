# cheese_sheet

# Required Tools for Running the Project

This project is developed using Flutter. To run the code, you need to install the following tools:

- **[Flutter SDK](https://flutter.dev/docs/get-started/install)**
- **Android Studio** (For device emulation and code management)
- **Java Development Kit (JDK)** (For compiling Android applications)
- **Git** (For cloning the repository)

---

# How to Run the Project

To run the project, use the following commands in Terminal or Command Prompt:

```sh
# Clone the project from GitHub
git clone https://github.com/tawannantawat/CS492.git
cd CS492

# Install dependencies
flutter pub get

# Run the application
flutter run


#Firebase and Supabase Configuration
Before running the project, you must correctly set up Firebase and Supabase, or the app will not connect to the backend.

Setting up Firebase
Follow these steps to configure Firebase:

Go to the Firebase Console
Create a new project and add an application for Android and iOS
Download the google-services.json (Android) and GoogleService-Info.plist (iOS) files
Place the files inside android/app and iOS/Runner
Use Firebase CLI to connect the project to Firebase
For more details, check the official documentation:
🔗 Firebase Flutter Setup
