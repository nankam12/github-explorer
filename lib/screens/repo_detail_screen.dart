import 'package:flutter/material.dart';

import '../models/github_repo.dart';
import '../open_url.dart';
import '../services/github_api.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/language_chip.dart';
import '../widgets/loading_view.dart';
import '../widgets/stat_item.dart';

class RepoDetailScreen extends StatefulWidget {
  const RepoDetailScreen({super.key, required this.repo});

  final GithubRepo repo;

  @override
  State<RepoDetailScreen> createState() => _RepoDetailScreenState();
}

class _RepoDetailScreenState extends State<RepoDetailScreen> {
  final GithubApi _githubApi = GithubApi();

  late GithubRepo _repo;
  bool _isLoadingDetails = false;
  String? _detailsError;

  bool _isLoadingLanguages = false;
  String? _languagesError;
  List<RepoLanguage> _languages = [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repo;
    _loadDetails();
    _loadLanguages();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoadingDetails = true;
      _detailsError = null;
    });

    try {
      final repo = await _githubApi.fetchRepo(_repo.ownerLogin, _repo.name);
      if (!mounted) {
        return;
      }
      setState(() {
        _repo = repo;
        _isLoadingDetails = false;
      });
    } on GithubApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _detailsError = error.message;
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _loadLanguages() async {
    setState(() {
      _isLoadingLanguages = true;
      _languagesError = null;
    });

    try {
      final languages = await _githubApi.fetchLanguages(
        _repo.ownerLogin,
        _repo.name,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _languages = languages;
        _isLoadingLanguages = false;
      });
    } on GithubApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _languagesError = error.message;
        _isLoadingLanguages = false;
      });
    }
  }

  Future<void> _openOnGithub() async {
    final opened = await openExternalUrl(_repo.htmlUrl);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this repository on GitHub.')),
      );
    }
  }

  String _formatUpdatedAt(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) {
      return value.isEmpty ? 'Unknown' : value;
    }
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final description = (_repo.description == null || _repo.description!.isEmpty)
        ? 'No description provided.'
        : _repo.description!;
    final language = (_repo.language == null || _repo.language!.isEmpty)
        ? 'Unknown'
        : _repo.language!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_repo.name),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_detailsError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ErrorView(
                    message: _detailsError!,
                    onRetry: _loadDetails,
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isLoadingDetails)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(),
                        ),
                      Text(
                        _repo.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _repo.fullName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(description),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Owner',
                        value: _repo.ownerLogin,
                      ),
                      _InfoRow(
                        icon: Icons.code,
                        label: 'Primary language',
                        value: language,
                      ),
                      _InfoRow(
                        icon: Icons.account_tree_outlined,
                        label: 'Default branch',
                        value: _repo.defaultBranch,
                      ),
                      _InfoRow(
                        icon: Icons.update,
                        label: 'Last updated',
                        value: _formatUpdatedAt(_repo.updatedAt),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatItem(
                              icon: Icons.star_border,
                              label: 'Stars',
                              value: '${_repo.starCount}',
                            ),
                          ),
                          Expanded(
                            child: StatItem(
                              icon: Icons.fork_right,
                              label: 'Forks',
                              value: '${_repo.forkCount}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatItem(
                              icon: Icons.visibility_outlined,
                              label: 'Watchers',
                              value: '${_repo.watcherCount}',
                            ),
                          ),
                          Expanded(
                            child: StatItem(
                              icon: Icons.bug_report_outlined,
                              label: 'Open issues',
                              value: '${_repo.openIssuesCount}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _openOnGithub,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open on GitHub'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Languages',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildLanguages(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguages() {
    if (_isLoadingLanguages) {
      return const LoadingView(message: 'Loading languages...');
    }

    if (_languagesError != null) {
      return ErrorView(
        message: _languagesError!,
        onRetry: _loadLanguages,
      );
    }

    if (_languages.isEmpty) {
      return const EmptyView(
        icon: Icons.code_off,
        message: 'No language data is available for this repository.',
      );
    }

    return Column(
      children: [
        for (final language in _languages)
          LanguageChip(
            name: language.name,
            percent: language.percent,
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
