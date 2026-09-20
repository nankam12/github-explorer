import 'package:flutter/material.dart';

import '../models/github_repo.dart';
import '../models/github_user.dart';
import '../services/github_api.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/repo_card.dart';
import '../widgets/user_header.dart';
import 'repo_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final GithubUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GithubApi _githubApi = GithubApi();

  bool _isLoadingRepos = false;
  bool _isLoadingMore = false;
  String? _reposErrorMessage;
  List<GithubRepo> _repos = [];
  int _page = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadRepos();
  }

  Future<void> _loadRepos({bool loadMore = false}) async {
    if (loadMore && (_isLoadingMore || !_hasMore)) {
      return;
    }

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoadingRepos = true;
        _reposErrorMessage = null;
        _repos = [];
        _page = 1;
        _hasMore = false;
      }
    });

    try {
      final nextPage = loadMore ? _page + 1 : 1;
      final result = await _githubApi.fetchRepos(
        widget.user.login,
        page: nextPage,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (loadMore) {
          _repos = [..._repos, ...result.repos];
        } else {
          _repos = result.repos;
        }
        _page = nextPage;
        _hasMore = result.hasMore && result.repos.isNotEmpty;
        _isLoadingRepos = false;
        _isLoadingMore = false;
      });
    } on GithubApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _reposErrorMessage = error.message;
        _isLoadingRepos = false;
        _isLoadingMore = false;
      });
    }
  }

  void _openRepo(GithubRepo repo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RepoDetailScreen(repo: repo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        UserHeader(user: widget.user),
        const SizedBox(height: 24),
        Text('Repositories', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          '${widget.user.publicRepos} public repositories on GitHub',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _buildRepoSection(),
      ],
    );
  }

  Widget _buildRepoSection() {
    if (_isLoadingRepos) {
      return const LoadingView(message: 'Loading repositories...');
    }

    if (_reposErrorMessage != null && _repos.isEmpty) {
      return ErrorView(
        message: _reposErrorMessage!,
        onRetry: _loadRepos,
      );
    }

    if (_repos.isEmpty) {
      return const EmptyView(
        icon: Icons.folder_off_outlined,
        message: 'This user has no public repositories yet.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_reposErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _reposErrorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        for (final repo in _repos)
          RepoCard(
            repo: repo,
            onTap: () => _openRepo(repo),
          ),
        if (_hasMore) ...[
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _isLoadingMore ? null : () => _loadRepos(loadMore: true),
            icon: _isLoadingMore
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.expand_more),
            label: Text(_isLoadingMore ? 'Loading...' : 'Load more'),
          ),
        ],
      ],
    );
  }
}
