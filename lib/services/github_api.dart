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
  static const int reposPerPage = 10;
  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'github_explorer',
  };

  Future<GithubUser> fetchUser(String username) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw const GithubApiException('Please enter a GitHub username.');
    }

    final uri = Uri.parse(
      '$_baseUrl/users/${Uri.encodeComponent(trimmedUsername)}',
    );
    final response = await _get(uri);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return GithubUser.fromJson(json);
      } catch (_) {
        throw const GithubApiException(
          'Could not read this GitHub user. Please try again.',
        );
      }
    }

    _throwForStatus(
      response,
      notFoundMessage: 'User "$trimmedUsername" was not found.',
      failedMessage: 'Could not load this GitHub user. Please try again.',
    );
  }

  Future<GithubRepoPage> fetchRepos(String username, {int page = 1}) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw const GithubApiException('Please enter a GitHub username.');
    }

    final uri = Uri.parse(
      '$_baseUrl/users/${Uri.encodeComponent(trimmedUsername)}/repos',
    ).replace(
      queryParameters: {
        'page': '$page',
        'per_page': '$reposPerPage',
        'sort': 'updated',
        'direction': 'desc',
        'type': 'owner',
      },
    );
    final response = await _get(uri);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as List<dynamic>;
        final repos = json
            .map((item) => GithubRepo.fromJson(item as Map<String, dynamic>))
            .toList();
        return GithubRepoPage(
          repos: repos,
          hasMore: repos.isNotEmpty && _hasNextPage(response, repos.length),
        );
      } catch (error) {
        if (error is GithubApiException) {
          rethrow;
        }
        throw const GithubApiException(
          'Could not read repositories. Please try again.',
        );
      }
    }

    _throwForStatus(
      response,
      notFoundMessage: 'Repositories for "$trimmedUsername" were not found.',
      failedMessage: 'Could not load repositories. Please try again.',
    );
  }

  Future<GithubRepo> fetchRepo(String owner, String repo) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repo)}',
    );
    final response = await _get(uri);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return GithubRepo.fromJson(json);
      } catch (_) {
        throw const GithubApiException(
          'Could not read this repository. Please try again.',
        );
      }
    }

    _throwForStatus(
      response,
      notFoundMessage: 'Repository "$owner/$repo" was not found.',
      failedMessage: 'Could not load this repository. Please try again.',
    );
  }

  Future<List<RepoLanguage>> fetchLanguages(String owner, String repo) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repo)}/languages',
    );
    final response = await _get(uri);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return _languagesFromJson(json);
      } catch (_) {
        throw const GithubApiException(
          'Could not read language data. Please try again.',
        );
      }
    }

    _throwForStatus(
      response,
      notFoundMessage: 'Language data for "$owner/$repo" was not found.',
      failedMessage: 'Could not load language data. Please try again.',
    );
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return await http.get(uri, headers: _headers);
    } catch (_) {
      throw const GithubApiException(
        'Could not connect to GitHub. Check your internet connection.',
      );
    }
  }

  bool _hasNextPage(http.Response response, int itemCount) {
    final linkHeader = response.headers['link'] ?? response.headers['Link'];
    if (linkHeader != null) {
      return linkHeader.contains('rel="next"') ||
          linkHeader.contains("rel='next'");
    }
    return itemCount == reposPerPage;
  }

  List<RepoLanguage> _languagesFromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const [];
    }

    final entries = json.entries.map((entry) {
      return MapEntry(entry.key, _asInt(entry.value));
    }).toList();

    final totalBytes = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    if (totalBytes == 0) {
      return const [];
    }

    entries.sort((a, b) => b.value.compareTo(a.value));

    return [
      for (final entry in entries)
        RepoLanguage(
          name: entry.key,
          bytes: entry.value,
          percent: (entry.value / totalBytes) * 100,
        ),
    ];
  }

  Never _throwForStatus(
    http.Response response, {
    required String notFoundMessage,
    required String failedMessage,
  }) {
    if (response.statusCode == 404) {
      throw GithubApiException(notFoundMessage);
    }
    if (response.statusCode == 403) {
      throw const GithubApiException(
        'GitHub rate limit reached. Please try again later.',
      );
    }
    throw GithubApiException(failedMessage);
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
