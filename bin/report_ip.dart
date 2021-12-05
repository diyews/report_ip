import 'dart:async';

import 'package:args/args.dart';
import 'package:github/github.dart';
import 'package:report_ip/src/sync_github.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()..addOption('token', abbr: 't');

  final ArgResults parserResult = parser.parse(arguments);
  final owner = parserResult.arguments[0];
  final repoName = parserResult.arguments[1];
  final RepositorySlug repositorySlug = RepositorySlug(owner, repoName);

  GitHub github = GitHub(auth: Authentication.withToken(parserResult['token']));

  final repo = await github.repositories.getRepository(repositorySlug);
  final defaultBranch = repo.defaultBranch;
  final sha =
      (await github.repositories.getBranch(repositorySlug, defaultBranch))
          .commit!
          .sha!;

  doLoop(github, repositorySlug, sha);
}

Future<Timer> doLoop(GitHub gitHub, RepositorySlug slug, String sha) async {
  /* about 3~6 seconds */
  await syncGithub(gitHub, slug, sha);

  return Timer(Duration(seconds: 15), () => doLoop(gitHub, slug, sha));
}
