library coveralls_dart.src.services.travis;

/// Returns the current branch name for the provided [environment] as defined
/// by Travis.
///
/// If none exists, return `null`.
String getBranch(Map<String, String> environment) =>
    environment["TRAVIS_BRANCH"];

String getServiceName(Map<String, String> environment) {
  if (environment['TRAVIS'] != 'true') return null;

  var repoSlug = environment['TRAVIS_REPO_SLUG'];
  if (repoSlug == null) return null;

  var branch = getBranch(environment);

  if (branch != null) {
    return "travis: $repoSlug @ $branch";
  }

  var commit = environment['TRAVIS_COMMIT'];
  if (commit != null) {
    return 'travis: $repoSlug @ $commit';
  }

  return 'travis: $repoSlug';
}
