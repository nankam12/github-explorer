class GithubUser {
  final String login;
  final String? name;
  final String? bio;
  final String avatarUrl;
  final String htmlUrl;
  final int followers;
  final int following;
  final int publicRepos;

  const GithubUser({
    required this.login,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.followers,
    required this.following,
    required this.publicRepos,
  });

  String get displayName {
    if (name == null || name!.trim().isEmpty) {
      return login;
    }
    return name!;
  }

  factory GithubUser.fromJson(Map<String, dynamic> json) {
    final login = json['login'] as String;
    return GithubUser(
      login: login,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String? ?? 'https://github.com/$login',
      followers: _asInt(json['followers']),
      following: _asInt(json['following']),
      publicRepos: _asInt(json['public_repos']),
    );
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
