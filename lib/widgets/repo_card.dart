import 'package:flutter/material.dart';

import '../models/github_repo.dart';

class RepoCard extends StatelessWidget {
  const RepoCard({super.key, required this.repo});

  final GithubRepo repo;

  @override
  Widget build(BuildContext context) {
    final description = (repo.description == null || repo.description!.isEmpty)
        ? 'No description provided.'
        : repo.description!;
    final language = (repo.language == null || repo.language!.isEmpty)
        ? 'Unknown'
        : repo.language!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repo.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    language,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.star_border, size: 18),
                const SizedBox(width: 4),
                Text(repo.starCount.toString()),
                const SizedBox(width: 16),
                const Icon(Icons.fork_right, size: 18),
                const SizedBox(width: 4),
                Text(repo.forkCount.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
