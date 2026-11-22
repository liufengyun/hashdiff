# Releasing Hashdiff

`master` is protected, so releases go through a pull request: update the
changelog and version on a release branch, open a PR, and merge it once CI
passes. Tag and publish the gem from the merged commit on `master`.

## Prepare the release

1. Start with a clean working tree and bring `master` up to date:

   ```sh
   git checkout master
   git pull --ff-only origin master
   git fetch --tags origin
   git status --short
   ```

2. Review changes since the previous release, replacing `v1.2.1` with the
   previous release tag:

   ```sh
   git log --oneline v1.2.1..HEAD
   git diff v1.2.1..HEAD -- lib spec
   ```

3. Update `Hashdiff::VERSION` in `lib/hashdiff/version.rb`. The gemspec reads
   this constant; it does not have a separate version to update.

4. Add a section at the top of `changelog.md` with the matching version and
   release date (`YYYY-MM-DD`). Summarize changes users will notice and link to
   the relevant pull requests and contributors.

## Validate and open a release PR

The commands below use 1.2.2 as an example; substitute the version being released.

1. Install development dependencies and run the same checks as CI (RSpec and
   RuboCop):

   ```sh
   bundle install
   bundle exec rake
   ```

2. Create a release branch, then stage and review the release files. The
   gemspec uses `git ls-files`, so stage any new files that should be packaged.
   Optionally run `gem build hashdiff.gemspec` to check that the gem builds.
   Generated `.gem` files are ignored and should not be committed.

   ```sh
   git checkout -b release-1.2.2
   git add changelog.md lib/hashdiff/version.rb
   git diff --cached --check
   git diff --cached
   ```

3. Commit, push the branch, and open a pull request against `master`:

   ```sh
   git commit -m "Release 1.2.2"
   git push -u origin release-1.2.2
   gh pr create --base master --title "Release 1.2.2" \
     --body "Bump version to 1.2.2 and update the changelog."
   ```

4. Wait for CI to pass on the PR, get any required review, and merge it.

## Publish the gem

Merging the PR runs CI on `master`; it does not publish to RubyGems. When
publishing the gem, wait for CI to pass on `master` and use a maintainer account
with RubyGems push access. Tag the merged commit on `master` (not the release
branch, since a squash or merge commit has a different hash), then build and
publish the gem from it:

```sh
git checkout master
git pull --ff-only origin master
git log -1 --oneline   # confirm this is the merged release commit
git tag v1.2.2
git push origin v1.2.2
gem build hashdiff.gemspec
gem push hashdiff-1.2.2.gem
```

Branch protection on `master` does not block pushing tags, unless the repository
also has tag protection rules. After publishing, delete the local release branch
(use `git branch -D` if the PR was squash-merged, since Git won't see it as merged).

Confirm that RubyGems lists the new version. If a version has already been
published, prepare a new version rather than reusing it or moving its release tag.
