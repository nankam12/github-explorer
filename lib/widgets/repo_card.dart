import 'package:flutter/material.dart';

import '../models/github_repo.dart';

class RepoCard extends StatelessWidget {
  const RepoCard({
    super.key,
    required this.repo,
    this.onTap,
  });

  final GithubRepo repo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final description = (repo.description == null || repo.description!.isEmpty)
        ? 'No description provided.'
        : repo.description!;
    final language = (repo.language == null || repo.language!.isEmpty)
        ? 'Unknown'
        : repo.language!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.book_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      repo.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.code, size: 18),
                      const SizedBox(width: 4),
                      Text(language),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_border, size: 18),
                      const SizedBox(width: 4),
                      Text('${repo.starCount}'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fork_right, size: 18),
                      const SizedBox(width: 4),
                      Text('${repo.forkCount}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
