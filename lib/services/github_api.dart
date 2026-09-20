import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/github_repo.dart';
import '../models/github_user.dart';

class GithubApiException implements Exception {
  final String message;

  const GithubApiException(this.message);

  @override
  String toString() => message;
}

class GithubApi {
  static const String _baseUrl = 'https://api.github.com';
  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'github_explorer',
  };

  Future<GithubUser> fetchUser(String username) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw const GithubApiException('Please enter a GitHub username.');
    }

    final uri = Uri.parse('$_baseUrl/users/${Uri.encodeComponent(trimmedUsername)}');

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return GithubUser.fromJson(json);
      }

      if (response.statusCode == 404) {
        throw GithubApiException('User "$trimmedUsername" was not found.');
      }

      if (response.statusCode == 403) {
        throw const GithubApiException(
          'GitHub rate limit reached. Please try again later.',
        );
      }

      throw GithubApiException(
        'Could not load user. Status code: ${response.statusCode}.',
      );
    } on GithubApiException {
      rethrow;
    } catch (_) {
      throw const GithubApiException(
        'Could not connect to GitHub. Check your internet connection.',
      );
    }
  }

  Future<List<GithubRepo>> fetchRepos(String username) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw const GithubApiException('Please enter a GitHub username.');
    }

    final uri = Uri.parse(
      '$_baseUrl/users/${Uri.encodeComponent(trimmedUsername)}/repos',
    ).replace(
      queryParameters: const {
        'page': '1',
        'per_page': '10',
        'sort': 'updated',
      },
    );

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .map((item) => GithubRepo.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (response.statusCode == 404) {
        throw GithubApiException(
          'Repositories for "$trimmedUsername" were not found.',
        );
      }

      if (response.statusCode == 403) {
        throw const GithubApiException(
          'GitHub rate limit reached. Please try again later.',
        );
      }

      throw GithubApiException(
        'Could not load repositories. Status code: ${response.statusCode}.',
      );
    } on GithubApiException {
      rethrow;
    } catch (_) {
      throw const GithubApiException(
        'Could not load repositories. Check your internet connection.',
      );
    }
  }
}
