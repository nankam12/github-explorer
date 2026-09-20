# GitHub Explorer

GitHub Explorer is a Flutter web app that searches public GitHub users and browses their repositories. It uses the GitHub REST API to load profile information, paginated repository lists, and repository details. I built this as a student/internship portfolio project to practice API integration, navigation, and clean UI in Flutter.

## Features

- Search GitHub users by username
- View profile information (avatar, name, bio, followers, following, public repos)
- Browse a user’s public repositories
- Load more repositories as you scroll through results
- Open a repository detail screen
- See a language breakdown with percentages
- Open a profile or repository on GitHub
- Loading, empty, and error states
- Responsive layout for Flutter web

## Tech Stack

- Flutter
- Dart
- GitHub REST API
- `http`
- `url_launcher`

## Screenshots

### Profile and repositories

*Add a screenshot of a searched user profile and their repository list.*

### Repository details

*Add a screenshot of the repository detail screen.*

### Language breakdown

*Add a screenshot of the language percentages on a repository.*

## Getting Started

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd github_explorer
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app in Chrome:

   ```bash
   flutter run -d chrome
   ```

## Project Structure

```text
lib/
  models/      Data classes for GitHub users, repositories, and languages
  services/    GitHub REST API requests and error handling
  screens/     Search, profile, and repository detail screens
  widgets/     Reusable UI such as repo cards and loading/error views
```

## API

The app uses the public [GitHub REST API](https://docs.github.com/en/rest) without authentication. Unauthenticated requests are rate-limited (about 60 requests per hour), so searches may fail temporarily if that limit is reached.

## Future Improvements

- GitHub authentication for a higher rate limit
- Search and filter repositories by name or language
- Save favorite users or repositories
- Deeper repository analytics, such as commit activity
