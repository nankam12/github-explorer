class GithubUser {
  final String login;
  final String? name;
  final String? bio;
  final String avatarUrl;
  final int followers;
  final int following;
  final int publicRepos;

  const GithubUser({
    required this.login,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.followers,
    required this.following,
    required this.publicRepos,
  });

  factory GithubUser.fromJson(Map<String, dynamic> json) {
    return GithubUser(
      login: json['login'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String,
      followers: json['followers'] as int,
      following: json['following'] as int,
      publicRepos: json['public_repos'] as int,
    );
  }
}
