import 'dart:convert';

import 'package:http/http.dart' as http;

/// Pushes an exported project to a GitHub repository as one commit, using
/// the REST git-data API with a personal access token (fine-grained token
/// with "Contents: read and write" on the repository).
class GitHubExporter {
  final String token;
  final String owner;
  final String repo;

  GitHubExporter({required this.token, required this.owner, required this.repo});

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json',
      };

  Uri _url(String path) => Uri.parse('https://api.github.com/repos/$owner/$repo$path');

  Future<Map<String, dynamic>> _get(String path) async {
    final r = await http.get(_url(path), headers: _headers);
    if (r.statusCode >= 300) throw GitHubException(r.statusCode, r.body);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _send(String method, String path, Map<String, dynamic> body) async {
    final request = http.Request(method, _url(path))
      ..headers.addAll(_headers)
      ..body = jsonEncode(body);
    final r = await http.Response.fromStream(await request.send());
    if (r.statusCode >= 300) throw GitHubException(r.statusCode, r.body);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static bool _isText(List<int> bytes) {
    try {
      utf8.decode(bytes);
      return !bytes.contains(0);
    } catch (_) {
      return false;
    }
  }

  /// Commits [files] to [branch] (created from the default branch if needed).
  /// Returns the commit URL. [onProgress] gets a short status line.
  Future<String> push(Map<String, List<int>> files, {required String branch, required String message, void Function(String)? onProgress}) async {
    onProgress?.call('Reading repository…');
    final repoInfo = await _get('');
    final defaultBranch = repoInfo['default_branch'] as String? ?? 'main';

    String? parentSha;
    var branchExists = true;
    try {
      parentSha = (await _get('/git/ref/heads/$branch'))['object']['sha'] as String;
    } on GitHubException catch (e) {
      if (e.statusCode != 404) rethrow;
      branchExists = false;
      try {
        parentSha = (await _get('/git/ref/heads/$defaultBranch'))['object']['sha'] as String;
      } on GitHubException catch (e) {
        // An empty repository has no branches yet.
        if (e.statusCode != 404 && e.statusCode != 409) rethrow;
      }
    }

    final tree = <Map<String, dynamic>>[];
    var done = 0;
    for (final entry in files.entries) {
      if (_isText(entry.value)) {
        tree.add({'path': entry.key, 'mode': '100644', 'type': 'blob', 'content': utf8.decode(entry.value)});
      } else {
        final blob = await _send('POST', '/git/blobs', {'content': base64Encode(entry.value), 'encoding': 'base64'});
        tree.add({'path': entry.key, 'mode': '100644', 'type': 'blob', 'sha': blob['sha']});
      }
      done++;
      if (done % 20 == 0) onProgress?.call('Uploading files… $done/${files.length}');
    }

    onProgress?.call('Creating commit…');
    // A full tree (no base_tree) makes the branch match the export exactly.
    final newTree = await _send('POST', '/git/trees', {'tree': tree});
    final commit = await _send('POST', '/git/commits', {
      'message': message,
      'tree': newTree['sha'],
      if (parentSha != null) 'parents': [parentSha],
    });
    final sha = commit['sha'] as String;

    if (branchExists) {
      await _send('PATCH', '/git/refs/heads/$branch', {'sha': sha, 'force': false});
    } else {
      await _send('POST', '/git/refs', {'ref': 'refs/heads/$branch', 'sha': sha});
    }
    return 'https://github.com/$owner/$repo/commit/$sha';
  }
}

class GitHubException implements Exception {
  final int statusCode;
  final String body;

  GitHubException(this.statusCode, this.body);

  @override
  String toString() {
    String? message;
    try {
      message = (jsonDecode(body) as Map)['message'] as String?;
    } catch (_) {}
    if (statusCode == 401) return 'GitHub rejected the token (401).';
    if (statusCode == 403 || statusCode == 404) return 'No access to the repository ($statusCode). Check the owner/name and that the token can write contents.';
    return 'GitHub error $statusCode${message != null ? ': $message' : ''}';
  }
}
