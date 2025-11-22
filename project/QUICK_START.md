# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Install Dependencies
```bash
cd F:\flutterproject\project
flutter pub get
```

### 2. Firebase Setup (Required)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Authentication** → **Email/Password**
4. Create **Firestore Database** (test mode)
5. Add Android app → Download `google-services.json`
6. Place file in: `android/app/google-services.json`

### 3. Run the App
```bash
flutter run
```

## 🧪 Quick Test

1. **Register as Cafeteria**:
   - Select "Cafeteria" role
   - Register with email/password
   - Create a surplus post

2. **Register as Student**:
   - Select "Student" role
   - Register with email/password
   - Browse and reserve food

3. **Test QR Pickup**:
   - Student: View QR code in "My Reservations"
   - Cafeteria: Scan QR code from "Scan QR" screen
   - Verify points are awarded

## ⚠️ Important Notes

- **Camera Permission**: Required for QR scanning (automatically requested)
- **Firebase**: Must be configured before running
- **Test Mode**: Firestore is in test mode (update rules for production)

## 📚 Documentation

- **SETUP_GUIDE.md**: Detailed setup instructions
- **ARCHITECTURE.md**: Technical documentation
- **README.md**: Project overview

## 🐛 Troubleshooting

**Firebase errors?**
- Check `google-services.json` is in `android/app/`
- Verify Firebase services are enabled

**Build errors?**
```bash
flutter clean
flutter pub get
flutter run
```

**QR scanner not working?**
- Grant camera permission when prompted
- Test on physical device (emulator may have issues)

## ✅ Checklist

- [ ] Flutter SDK installed
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project created
- [ ] `google-services.json` added
- [ ] Authentication enabled
- [ ] Firestore database created
- [ ] App runs successfully

---

**Ready to go!** 🎉

