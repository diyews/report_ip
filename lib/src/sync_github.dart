import 'dart:convert';

import 'package:github/github.dart';

import 'get_ip.dart';

Future syncGithub(GitHub gitHub, RepositorySlug slug, String sha) async {
  await resetBranchX(gitHub, slug, sha);
  final contentSha = await getContentSha(gitHub, slug);

  final ip = await getIp();

  final updated = await gitHub.repositories.updateFile(slug, 'README.md',
      'Update IP', base64.encode(utf8.encode(ip)), contentSha,
      branch: 'x');
}

Future resetBranchX(GitHub gitHub, RepositorySlug slug, String sha) async {
  final branch = await gitHub.repositories.getBranch(slug, 'x');
  if (branch.name != null) {
    final res = await gitHub.git.deleteReference(slug, 'heads/x');
  }
  final created = await gitHub.git.createReference(slug, 'refs/heads/x', sha);
}

Future<String> getContentSha(GitHub gitHub, RepositorySlug slug) async {
  final x = await gitHub.repositories.getReadme(slug);
  return x.sha!;
}
