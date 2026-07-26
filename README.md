// final verify turn 1
# Music Explorer App

A Flutter application for discovering and managing music using the iTunes API. Built with clean architecture principles and MVC pattern using GetX for state management.

## Features

### Home Screen
- Search songs using iTunes API
- Display songs with album artwork, title, and artist name
- Infinite scroll with automatic pagination
- Pull-to-refresh functionality
- Shimmer loading animations
- Error handling with retry functionality

### Song Detail Screen
- Large album artwork display
- Complete song information (title, artist, album, genre)
- Audio preview player with:
  - Play/Pause controls
  - Progress slider
  - Duration display
- Add/Remove from favorites with visual feedback

### Favorites Screen
- View all saved favorite songs
- Real-time updates when favorites are added/removed
- Swipe-to-delete functionality
- Offline access to favorites using Hive local storage
- Pull-to-refresh
- Empty state with helpful message

### Additional Features
- Dark and Light theme support with toggle
- Smooth navigation between screens
- Cached network images for better performance
- Material Design 3 UI

## Architecture

The project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/
│   ├── di/
│   │   └── injection.dart          # Dependency injection setup
│   └── theme/
│       └── app_theme.dart          # Theme configuration
├── data/
│   ├── datasources/
│   │   ├── local_data_source.dart  # Hive local storage
│   │   └── remote_data_source.dart # iTunes API calls
│   ├── models/
│   │   ├── song_model.dart         # Data model with JSON serialization
│   │   └── song_model.g.dart       # Generated Hive adapter
│   └── repositories/
│       └── song_repository_impl.dart # Repository implementation
├── domain/
│   ├── entities/
│   │   └── song.dart               # Domain entity
│   └── repositories/
│       └── song_repository.dart    # Repository interface
├── presentation/
│   ├── controllers/
│   │   ├── favorites_controller.dart
│   │   ├── home_controller.dart
│   │   ├── song_detail_controller.dart
│   │   └── theme_controller.dart
│   ├── screens/
│   │   ├── favorites_screen.dart
│   │   ├── home_screen.dart
│   │   ├── main_navigation_screen.dart
│   │   └── song_detail_screen.dart
│   └── widgets/
│       ├── shimmer_song_card.dart
│       └── song_card.dart
└── main.dart
```

## Packages Used

- **get**: State management and navigation
- **http**: API networking
- **hive** & **hive_flutter**: Local database for favorites
- **audioplayers**: Audio preview playback
- **shimmer**: Loading skeleton animations
- **cached_network_image**: Image caching
- **equatable**: Value equality for entities

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation


1.Install dependencies
```bash
flutter pub get
```

2.Generate Hive adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3.Run the app
```bash
flutter run
```

## API Reference

This app uses the iTunes Search API:
- Base URL: `https://itunes.apple.com`
- Endpoint: `/search?term={query}&entity=song&limit={limit}&offset={offset}`
- No API key required

## Project Structure

### Clean Architecture Layers

1. **Domain Layer** (Business Logic)
   - Pure Dart entities
   - Repository interfaces
   - No dependencies on other layers

2. **Data Layer** (Data Management)
   - Remote data source (API)
   - Local data source (Hive)
   - Repository implementations
   - Data models with serialization

3. **Presentation Layer** (UI)
   - Controllers (MVC pattern with GetX)
   - Screens
   - Widgets
   - Theme configuration

### MVC Pattern with GetX

- **Model**: Domain entities and data models
- **View**: Flutter widgets and screens
- **Controller**: GetX controllers managing state and business logic

## Features Implementation Details

### Infinite Scroll
- Implemented using ScrollController
- Automatically loads more content when user scrolls near the bottom
- Shows loading indicator while fetching more songs

### Local Storage
- Uses Hive for efficient local storage
- Favorites persist across app restarts
- Type-safe storage with generated adapters

### Audio Playback
- Plays 30-second preview clips
- Real-time progress tracking
- Seek functionality

### Theme Switching
- Light and Dark themes
- Preference saved locally
- Smooth transition between themes

### Error Handling
- Network error handling
- User-friendly error messages
- Retry functionality

## Build and Run

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```
