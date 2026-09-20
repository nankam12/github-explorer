import 'package:flutter/material.dart';

import 'models/github_repo.dart';
import 'models/github_user.dart';
import 'services/github_api.dart';
import 'widgets/repo_card.dart';

void main() {
  runApp(const GithubExplorerApp());
}

class GithubExplorerApp extends StatelessWidget {
  const GithubExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final GithubApi _githubApi = GithubApi();

  bool _isLoading = false;
  String? _errorMessage;
  GithubUser? _user;

  bool _isLoadingRepos = false;
  String? _reposErrorMessage;
  List<GithubRepo> _repos = [];

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _user = null;
      _isLoadingRepos = false;
      _reposErrorMessage = null;
      _repos = [];
    });

    try {
      final user = await _githubApi.fetchUser(_usernameController.text);
      setState(() {
        _user = user;
        _isLoading = false;
      });
      await _loadRepos(user.login);
    } on GithubApiException catch (error) {
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRepos(String username) async {
    setState(() {
      _isLoadingRepos = true;
      _reposErrorMessage = null;
      _repos = [];
    });

    try {
      final repos = await _githubApi.fetchRepos(username);
      setState(() {
        _repos = repos;
        _isLoadingRepos = false;
      });
    } on GithubApiException catch (error) {
      setState(() {
        _reposErrorMessage = error.message;
        _isLoadingRepos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('GitHub Explorer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'GitHub username',
                hintText: 'octocat',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchUser(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isLoading ? null : _searchUser,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildResult()),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 16,
          ),
        ),
      );
    }

    if (_user != null) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _UserCard(user: _user!),
            const SizedBox(height: 24),
            Text(
              'Repositories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildRepoSection(),
          ],
        ),
      );
    }

    return const Center(
      child: Text(
        'Search for a GitHub user to see their profile.',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRepoSection() {
    if (_isLoadingRepos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_reposErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          _reposErrorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 16,
          ),
        ),
      );
    }

    if (_repos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'This user has no public repositories yet.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        for (final repo in _repos) RepoCard(repo: repo),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final GithubUser user;

  @override
  Widget build(BuildContext context) {
    final displayName = (user.name == null || user.name!.isEmpty)
        ? user.login
        : user.name!;
    final bio = (user.bio == null || user.bio!.isEmpty)
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
              displayName,
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
            Text(
              bio,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Followers',
                    value: user.followers.toString(),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Following',
                    value: user.following.toString(),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Repos',
                    value: user.publicRepos.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
