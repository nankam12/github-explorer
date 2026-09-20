import 'package:flutter/material.dart';

import '../models/github_user.dart';
import '../open_url.dart';
import 'stat_item.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key, required this.user});

  final GithubUser user;

  Future<void> _openProfile(BuildContext context) async {
    final opened = await openExternalUrl(user.htmlUrl);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open GitHub profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bio = (user.bio == null || user.bio!.trim().isEmpty)
        ? 'No bio available.'
        : user.bio!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.login}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(bio, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    icon: Icons.people_outline,
                    label: 'Followers',
                    value: '${user.followers}',
                  ),
                ),
                Expanded(
                  child: StatItem(
                    icon: Icons.person_outline,
                    label: 'Following',
                    value: '${user.following}',
                  ),
                ),
                Expanded(
                  child: StatItem(
                    icon: Icons.folder_outlined,
                    label: 'Public repos',
                    value: '${user.publicRepos}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openProfile(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open GitHub profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
