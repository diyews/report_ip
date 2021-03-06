import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:github/github.dart';
import 'package:report_ip/src/sync_github.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('token', abbr: 't', help: 'Personal access token')
    ..addOption('interval',
        abbr: 'i', help: 'Interval of update, in minutes', defaultsTo: '30')
    ..addFlag('once', help: 'Run just one time', negatable: false)
    ..addFlag('help', abbr: 'h', help: 'Usage', negatable: false);

  final ArgResults parserResult = parser.parse(arguments);
  if (parserResult['help']) {
    return print(parser.usage);
  }

  final owner = parserResult.arguments[0];
  final repoName = parserResult.arguments[1];
  final interval = int.parse(parserResult['interval']);

  final RepositorySlug repositorySlug = RepositorySlug(owner, repoName);

  GitHub github = GitHub(auth: Authentication.withToken(parserResult['token']));

  final repo = await github.repositories.getRepository(repositorySlug);
  final defaultBranch = repo.defaultBranch;
  final sha =
      (await github.repositories.getBranch(repositorySlug, defaultBranch))
          .commit!
          .sha!;

  if (parserResult['once']) {
    syncGithub(github, repositorySlug, sha).whenComplete(() {
      github.dispose();
    });
  } else {
    doLoop(github, repositorySlug, sha, interval: interval);
  }
}

Future<Timer> doLoop(GitHub gitHub, RepositorySlug slug, String sha,
    {required int interval}) async {
  /* about 3~6 seconds */
  try {
    await syncGithub(gitHub, slug, sha);
  } catch (e) {
    stderr.writeln(e);
  }

  return Timer(Duration(minutes: interval),
      () => doLoop(gitHub, slug, sha, interval: interval));
}
