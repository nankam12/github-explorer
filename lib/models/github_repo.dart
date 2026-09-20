class GithubRepo {
  final String name;
  final String? description;
  final String? language;
  final int starCount;
  final int forkCount;

  const GithubRepo({
    required this.name,
    required this.description,
    required this.language,
    required this.starCount,
    required this.forkCount,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      name: json['name'] as String,
      description: json['description'] as String?,
      language: json['language'] as String?,
      starCount: json['stargazers_count'] as int,
      forkCount: json['forks_count'] as int,
    );
  }
}
