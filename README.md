# Stage

A Flutter project for managing and displaying movies.

## Project Overview

This project is a movie management application built with Flutter. It allows users to browse movies, view detailed information, mark movies as favorites, and access favorite movies offline.

## How to Run the Application

### Prerequisites

- Install [Flutter](https://docs.flutter.dev/get-started/install) (version 3.0 or higher).
- Ensure you have an API key for accessing the movie database.

### Steps to Run

1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Create a .env file in the root directory and add your API key:

   ```bash
   API_KEY=your_api_key_here
   ```

3. Run the application:

   ```bash
   flutter run
   ```

## How to Run Tests

### Unit Tests

Run unit tests using:

    flutter test test/blocs/movie_list/movie_list_bloc_test.dart

    flutter test test/blocs/movie_details/movie_details_bloc_test.dart

    flutter test test/repositories/movie_repositories/movie_repository.dart

### Integration Tests

Run integration tests using:

    flutter test test/integration/movie_list_screen_test.dart

    flutter test test/integration/movie_detail_screen_test.dart
