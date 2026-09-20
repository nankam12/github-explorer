class GithubRepo {
  final String name;
  final String fullName;
  final String? description;
  final String? language;
  final int starCount;
  final int forkCount;
  final int watcherCount;
  final int openIssuesCount;
  final String defaultBranch;
  final String updatedAt;
  final String ownerLogin;
  final String htmlUrl;

  const GithubRepo({
    required this.name,
    required this.fullName,
    required this.description,
    required this.language,
    required this.starCount,
    required this.forkCount,
    required this.watcherCount,
    required this.openIssuesCount,
    required this.defaultBranch,
    required this.updatedAt,
    required this.ownerLogin,
    required this.htmlUrl,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    final name = json['name'] as String;
    final fullName = json['full_name'] as String? ?? name;
    final ownerLogin = owner?['login'] as String? ?? fullName.split('/').first;

    return GithubRepo(
      name: name,
      fullName: fullName,
      description: json['description'] as String?,
      language: json['language'] as String?,
      starCount: _asInt(json['stargazers_count']),
      forkCount: _asInt(json['forks_count'] ?? json['forks']),
      watcherCount: _asInt(
        json['subscribers_count'] ?? json['watchers_count'] ?? json['watchers'],
      ),
      openIssuesCount: _asInt(json['open_issues_count'] ?? json['open_issues']),
      defaultBranch: json['default_branch'] as String? ?? 'main',
      updatedAt: json['updated_at'] as String? ?? '',
      ownerLogin: ownerLogin,
      htmlUrl: json['html_url'] as String? ?? 'https://github.com/$fullName',
    );
  }
}

class GithubRepoPage {
  final List<GithubRepo> repos;
  final bool hasMore;

  const GithubRepoPage({
    required this.repos,
    required this.hasMore,
  });
}

class RepoLanguage {
  final String name;
  final int bytes;
  final double percent;

  const RepoLanguage({
    required this.name,
    required this.bytes,
    required this.percent,
  });
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
