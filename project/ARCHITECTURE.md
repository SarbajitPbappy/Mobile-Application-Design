# Architecture Documentation

## Overview

The Campus Food Waste Connector app follows a clean architecture pattern with clear separation of concerns:

- **Models**: Data structures
- **Services**: Backend communication (Firebase)
- **Providers**: State management (using Provider pattern)
- **Screens**: UI components organized by user role
- **Utils**: Constants and helper functions

## Architecture Layers

### 1. Data Layer (Models)

**Location**: `lib/models/`

- **user_model.dart**: User data structure with role-based fields
- **surplus_post_model.dart**: Surplus food post structure
- **reservation_model.dart**: Reservation structure with QR code data

All models include:
- `toMap()`: Convert to Firestore-compatible format
- `fromMap()`: Create from Firestore data
- `copyWith()`: Immutable updates

### 2. Service Layer

**Location**: `lib/services/`

#### AuthService
- Handles Firebase Authentication
- User profile CRUD operations
- Points management

#### FirestoreService
- Surplus posts queries (active, by cafeteria, bulk)
- Reservation management
- Leaderboard queries
- Impact statistics

### 3. State Management (Providers)

**Location**: `lib/providers/`

#### AuthProvider
- Manages authentication state
- Current user data
- Login/logout operations

#### SurplusProvider
- Active surplus posts list
- Create/update posts

#### ReservationProvider
- User reservations
- Create reservations
- Complete reservations (QR scan)
- Points awarding logic

### 4. Presentation Layer (Screens)

**Location**: `lib/screens/`

#### Authentication Flow
1. **SplashScreen**: Initial screen, checks auth status
2. **RoleSelectionScreen**: Choose user role
3. **LoginScreen**: Email/password login
4. **RegisterScreen**: New user registration

#### Student Screens
- **StudentHomeScreen**: Browse available surplus food
- **PostDetailsScreen**: View post details and reserve
- **StudentReservationsScreen**: List of user's reservations
- **QrCodeScreen**: Display QR code for pickup
- **StudentProfileScreen**: Profile, points, stats

#### Cafeteria Screens
- **CafeteriaDashboardScreen**: Overview, quick actions, active posts
- **CreateSurplusPostScreen**: Form to create new post
- **ScanQrScreen**: QR code scanner for pickup confirmation

#### NGO Screens
- **NgoHomeScreen**: List of bulk surplus posts (20+ portions)

#### Shared Screens
- **LeaderboardScreen**: Top students and cafeterias
- **ImpactScreen**: Overall impact statistics

## Data Flow

### Creating a Surplus Post (Cafeteria)
```
CreateSurplusPostScreen
  → SurplusProvider.createPost()
    → FirestoreService.createSurplusPost()
      → Firestore Database
```

### Reserving Food (Student)
```
PostDetailsScreen
  → ReservationProvider.createReservation()
    → FirestoreService.createReservation()
      → FirestoreService.updateSurplusPost() (reduce available portions)
        → Firestore Database
```

### Completing Pickup (Cafeteria)
```
ScanQrScreen
  → ReservationProvider.getReservationByQrCode()
    → ReservationProvider.completeReservation()
      → FirestoreService.updateReservation()
      → AuthService.updateUserPoints() (student)
      → AuthService.updateUserPoints() (cafeteria)
        → Firestore Database
```

## State Management Pattern

The app uses **Provider** pattern for state management:

1. **Providers** extend `ChangeNotifier`
2. **Screens** use `Consumer` or `Provider.of()` to access state
3. **State changes** trigger UI updates via `notifyListeners()`

Example:
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text(authProvider.currentUser?.name ?? 'Guest');
  },
)
```

## Firebase Integration

### Authentication
- Email/Password authentication
- User profiles stored in Firestore `users` collection
- Auth state listener in `AuthProvider`

### Firestore Structure
```
users/
  {userId}/
    - id, name, email, role, points, etc.

surplus_posts/
  {postId}/
    - id, cafeteriaId, title, portions, status, etc.

reservations/
  {reservationId}/
    - id, postId, studentId, quantity, qrCodeData, status, etc.
```

### Real-time Updates
- Uses Firestore `snapshots()` for real-time data
- Streams automatically update UI when data changes

## Navigation Flow

```
SplashScreen
  ↓ (not authenticated)
RoleSelectionScreen
  ↓ (select role)
LoginScreen / RegisterScreen
  ↓ (authenticated)
Role-specific Home Screen
  ├─ StudentHomeScreen
  ├─ CafeteriaDashboardScreen
  └─ NgoHomeScreen
```

## Points System

### Awarding Points
- **Students**: +10 points per completed pickup
- **Cafeterias**: +5 points per donated portion

### Points Calculation
- Triggered when reservation status changes to `completed`
- Points added via `AuthService.updateUserPoints()`
- Uses Firestore `FieldValue.increment()` for atomic updates

## QR Code System

### Generation
- QR code data = reservation ID (UUID)
- Generated when reservation is created
- Displayed in `QrCodeScreen` using `qr_flutter` package

### Scanning
- Uses `mobile_scanner` package
- Scans QR code data
- Looks up reservation in Firestore
- Validates status before completing

## Error Handling

- Try-catch blocks in service methods
- User-friendly error messages via SnackBar
- Loading states in providers
- Null checks for user authentication

## Future Enhancements

1. **Image Upload**: Add food photos to posts
2. **Push Notifications**: Notify users of new posts
3. **Maps Integration**: Show pickup locations on map
4. **Admin Dashboard**: Analytics and user management
5. **Offline Support**: Cache data for offline access

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Service methods
- Provider state changes

### Widget Tests
- Screen rendering
- User interactions
- Navigation flows

### Integration Tests
- Complete user flows
- Firebase operations
- QR code scanning

## Performance Considerations

1. **Stream Subscriptions**: Properly disposed in `dispose()` methods
2. **Image Loading**: Lazy loading for food images
3. **List Pagination**: Limit query results for large datasets
4. **Caching**: Consider local caching for frequently accessed data

## Security Considerations

1. **Firestore Rules**: Implement proper security rules for production
2. **Input Validation**: Validate all user inputs
3. **Authentication**: Require authentication for all operations
4. **Role-based Access**: Verify user roles before allowing actions

