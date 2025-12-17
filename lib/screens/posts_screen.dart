import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final int _limit = 10;
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    final int start = (_page - 1) * _limit;
    final url = 'https://jsonplaceholder.typicode.com/posts?_start=$start&_limit=$_limit';
    debugPrint('Fetching posts: $url');
    final response = await http.get(Uri.parse(url));
    debugPrint('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> fetched = json.decode(response.body);
      debugPrint('Fetched ${fetched.length} posts');
      setState(() {
        _posts.addAll(fetched);
        _isLoading = false;
        _hasMore = fetched.length == _limit;
        if (_hasMore) _page++;
      });
    } else {
      debugPrint('Failed to fetch posts: ${response.body}');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _fetchPosts();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              backgroundColor: Colors.deepPurple,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Posts'),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _posts.length) {
                    final post = _posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        title: Text(post['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(post['body']),
                        leading: CircleAvatar(child: Text(post['id'].toString())),
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
                childCount: _posts.length + (_hasMore ? 1 : 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
