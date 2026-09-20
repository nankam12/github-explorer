import 'package:flutter/material.dart';

import '../models/github_user.dart';
import '../services/github_api.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'profile_screen.dart';

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
    });

    try {
      final user = await _githubApi.fetchUser(_usernameController.text);
      if (!mounted) {
        return;
      }
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } on GithubApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Explorer'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Search a GitHub username to explore their profile and repositories.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.search,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'GitHub username',
                    hintText: 'octocat',
                    prefixIcon: Icon(Icons.person_search),
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
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const LoadingView(message: 'Looking up this GitHub user...');
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: _searchUser,
      );
    }

    if (_user != null) {
      return ProfileScreen(
        key: ValueKey(_user!.login),
        user: _user!,
      );
    }

    return const EmptyView(
      icon: Icons.search,
      message: 'Search for a GitHub user to see their profile.',
    );
  }
}
