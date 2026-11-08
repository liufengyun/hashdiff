# Releasing Hashdiff

Prepare releases directly on `master`: update the changelog and version, make a
release commit, and push it to `origin/master`. Previous releases followed this
process (for example, `8846a2c` for 1.2.1). A release PR is not required.

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

## Validate and push

The commands below use 1.2.2 as an example; substitute the version being released.

1. Install development dependencies and run the same checks as CI (RSpec and
   RuboCop):

   ```sh
   bundle install
   bundle exec rake
   ```

2. Stage and review the release files, then build the gem. The gemspec uses
   `git ls-files`, so stage any new files that should be packaged before building.
   Generated `.gem` files are ignored and should not be committed.

   ```sh
   git add changelog.md lib/hashdiff/version.rb RELEASE.md
   git diff --cached --check
   git diff --cached
   gem build hashdiff.gemspec
   ```

3. Commit and push directly to `master`, then check the GitHub Actions result:

   ```sh
   git commit -m "Release 1.2.2"
   git push origin master
   ```

## Publish the gem

Pushing to `master` runs CI; it does not publish to RubyGems. When publishing the
gem, wait for CI to pass and use a maintainer account with RubyGems push access.
From the release commit, tag the release and publish the gem built above:

```sh
git tag v1.2.2
git push origin v1.2.2
gem push hashdiff-1.2.2.gem
```

Confirm that RubyGems lists the new version. If a version has already been
published, prepare a new version rather than reusing it or moving its release tag.
