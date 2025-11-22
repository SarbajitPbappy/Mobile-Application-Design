# Campus Food Waste Connector

A Flutter Android application that reduces food waste in university cafeterias by connecting cafeterias (donors), students (receivers), and NGOs/food banks (bulk receivers).

## Features

### Core Features (MVP)
- **Role-based Authentication**: Students, Cafeterias, and NGOs can register and login
- **Surplus Food Posting**: Cafeterias can post surplus food with details (title, description, quantity, category, pickup location, time window)
- **Food Browsing & Reservation**: Students can browse available surplus food, filter by category, and reserve portions
- **QR Code System**: Students get QR codes for reservations, cafeterias can scan to complete pickups
- **Gamification**: Points system for students and cafeterias, leaderboards, and impact tracking
- **NGO Bulk Pickup**: NGOs can view and accept bulk surplus food (20+ portions)

### User Roles

#### Student (Receiver)
- Browse surplus food items
- Reserve portions
- View QR codes for pickup
- Earn points for each successful pickup
- View profile with points and stats
- Access leaderboards

#### Cafeteria Staff / Food Provider (Donor)
- Post surplus food details
- Manage active surplus posts
- Scan QR codes during pickup
- Earn points as "sustainable donor"
- View dashboard with stats

#### NGO / Food Bank (Bulk Receiver)
- See "bulk surplus" events (20+ portions)
- Accept bulk pickup requests
- View impact statistics

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Cloud Messaging (for notifications - optional)
- **State Management**: Provider
- **Key Packages**:
  - `firebase_core`, `firebase_auth`, `cloud_firestore`
  - `qr_flutter` (generate QR codes)
  - `mobile_scanner` (scan QR codes)
  - `provider` (state management)
  - `uuid` (generate unique IDs)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── surplus_post_model.dart
│   └── reservation_model.dart
├── services/                 # Backend services
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── surplus_provider.dart
│   └── reservation_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── role_selection_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── student/
│   │   ├── student_home_screen.dart
│   │   ├── post_details_screen.dart
│   │   ├── student_reservations_screen.dart
│   │   ├── qr_code_screen.dart
│   │   └── student_profile_screen.dart
│   ├── cafeteria/
│   │   ├── cafeteria_dashboard_screen.dart
│   │   ├── create_surplus_post_screen.dart
│   │   └── scan_qr_screen.dart
│   ├── ngo/
│   │   └── ngo_home_screen.dart
│   ├── leaderboard_screen.dart
│   └── impact_screen.dart
└── utils/
    └── constants.dart        # App constants
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase account

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication (Email/Password)
   - Create a Firestore database

2. **Add Firebase to Android**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/` directory

3. **Firebase Configuration**
   - The app will automatically use the `google-services.json` file
   - Make sure Authentication and Firestore are enabled in Firebase Console

### Installation

1. **Clone/Download the project**
   ```bash
   cd F:\flutterproject\project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Data Model

### Users Collection
```dart
{
  id: string,
  name: string,
  email: string,
  role: 'student' | 'cafeteria' | 'ngo' | 'admin',
  studentId?: string,
  department?: string,
  organizationName?: string,
  location?: string,
  points: number,
  createdAt: timestamp,
  isVerified: boolean
}
```

### Surplus Posts Collection
```dart
{
  id: string,
  cafeteriaId: string,
  title: string,
  description?: string,
  category: 'veg' | 'nonVeg',
  totalPortions: number,
  availablePortions: number,
  pickupLocation: string,
  startTime: timestamp,
  endTime: timestamp,
  forNgo: boolean,
  status: 'active' | 'partiallyReserved' | 'fullReserved' | 'expired',
  createdAt: timestamp,
  imageUrl?: string
}
```

### Reservations Collection
```dart
{
  id: string,
  postId: string,
  studentId: string,
  quantity: number,
  status: 'reserved' | 'completed' | 'cancelled' | 'expired',
  qrCodeData: string,
  createdAt: timestamp,
  completedAt?: timestamp
}
```

## Points System

- **Students**: +10 points per completed pickup
- **Cafeterias**: +5 points per donated portion
- Points are automatically awarded when a reservation is completed

## Future Enhancements

- Push notifications for new surplus posts
- Map view with markers for cafeterias
- Multi-language support
- Dark mode
- Image upload for food posts
- Admin dashboard for analytics
- User verification system

## Notes

- The app requires Firebase to be properly configured
- Make sure to add your `google-services.json` file before running
- For production, configure Firebase security rules for Firestore
- QR code scanning requires camera permissions

## License

This project is created for educational purposes.
