library coveralls_dart.src.services.travis;

/// Returns the current branch name for the provided [environment] as defined
/// by Travis.
///
/// If none exists, return `null`.
String getBranch(Map<String, String> environment) =>
    environment["TRAVIS_BRANCH"];

String getServiceName(Map<String, String> environment) {
  if (!environment.containsKey('TRAVIS')) return null;

  var repoSlug = environment['TRAVIS_REPO_SLUG'];
  if (repoSlug == null) return null;

  var ref = getBranch(environment);

  if (ref == null) {
    ref = environment['TRAVIS_COMMIT'];
  }

  if (ref != null) {
    return 'travis: $repoSlug @ $ref';
  }

  return 'travis: $repoSlug';
}
