# CHANGELOG - 3.0.1 #

### Since 3.0.0 ###

* Fixed "ambiguous arguments" problem ([GH-145](https://github.com/jdigger/git-process/issues/145))

### Since 2.0.5 ###

* Updated Ruby support to 2.x ([GH-140](https://github.com/jdigger/git-process/issues/140))
    * Fixed a number of comparability issues with Ruby 2.x, such as [GH-139](https://github.com/jdigger/git-process/issues/139) and [GH-132](https://github.com/jdigger/git-process/issues/132)
    * Ruby < 2.0 is no longer supported
* Updated Gem libraries to latest versions (2016-03-18)
    * Most notably, upgraded to Octokit 4.3 for support of the latest GitHub APIs
* Implemented support for GitHub two-factor authentication ([GH-141](https://github.com/jdigger/git-process/issues/141))
* Added Faraday logging to help debug issues when communicating with GitHub

### Since 2.0.4 ###

* Updated to replace '/' with '-' when generating the sync control filename. ([GH-130](https://github.com/jdigger/git-process/issues/130))
* Deprecated support for Ruby 1.8. (Should continue to work, but now that OS X has moved to Ruby 2.0 there's no longer much reason to support such an old version and it was making tests break.)

### Since 2.0.3 ###

* Fixed incompatibility with git 1.7 ([GH-128](https://github.com/jdigger/git-process/issues/128))

### Since 2.0.2 ###

* Locked down dependencies due to a change in the "faraday" packages.

### Since 2.0.1 ###

* Added "extra safe" code for deleting on Windows ([GH-121](https://github.com/jdigger/git-process/issues/121))
* Unknown variable for handling uncommited changes for sync ([GH-123](https://github.com/jdigger/git-process/issues/123))
* git-sync -r now keeps rebase on instead of acting as a switch ([GH-122](https://github.com/jdigger/git-process/issues/122))

### Since 2.0.0 ###

* Changed git-pull-request to git-pull-req

### Since 1.1.4 ###

* **Changed git-sync to default to rebasing.** ([GH-112](https://github.com/jdigger/git-process/issues/112))
* git-sync now can take a branch name to check it out for work ([GH-117](https://github.com/jdigger/git-process/issues/117))
* Change to use the "native" manpage-based help system for `git help`.
  ([GH-113](https://github.com/jdigger/git-process/issues/113))
* `git new-fb` now defaults to doing a `git fetch` before creating the feature branch if a remote is defined.
  ([GH-118](https://github.com/jdigger/git-process/issues/118))
* Removed **--interactive** option from git-to-master
* Updated README and related files.
* Retries closing a pull request if it gets a 422. ([GH-102](https://github.com/jdigger/git-process/issues/102))
* Fixed typo in merge error. ([GH-114](https://github.com/jdigger/git-process/issues/114))

### Since 1.1.3 ###

* Improved URI handling of repo names. ([GH-108](https://github.com/jdigger/git-process/issues/108))

### Since 1.1.2 ###

* Fixed undefined local variable error when asking about removing local integration branch.

### Since 1.1.0 ###

* Fixed scoping in "git-sync"

### Since 1.0.8 ###

* Adds `git pull-request {repoName}/{branchNumber}` ([GH-92](https://github.com/jdigger/git-process/issues/92))
    * If a number is given to "git-pull-request", or a number with a server preceding it (e.g., "origin/23"), then
      this assumes that the number refers to an existing pull request identified by that number. In that case, the
      branch associated with the HEAD of the pull request is checked out.
* Adds `git to-master {repoName}/{branchNumber}` ([GH-94](https://github.com/jdigger/git-process/issues/94))
    * If a number is given to "git-to-master", or a number with a server preceding it (e.g., "origin/23"), then
      this assumes that the number refers to an existing pull request identified by that number. In that case, the
      branch associated with the HEAD of the pull request is checked out before doing the rest of the "to-master".
* `git new-fb` changes to work better with integration branch ([GH-99](https://github.com/jdigger/git-process/issues/99),
  [GH-103](https://github.com/jdigger/git-process/issues/103) and [GH-105](https://github.com/jdigger/git-process/issues/105))
* Added pull-request URL to `git pull-request` output ([GH-104](https://github.com/jdigger/git-process/issues/104))
* Shows a cleaned up version of fetch's output. ([GH-85](https://github.com/jdigger/git-process/issues/85))
* Changed to use HTTPS instead of HTTP by default for GitHub API usage.
* Implementation details
    * GitProc::PullRequest has #checkout_pull_request to checkout the HEAD branch of a pull request at any "remote"
      that has been configured, setting the upstream to the pull request's BASE branch
    * GitHubService module no longer uses module-level instance variables, which were causing problems with testing
    * GitHub::PullRequest can now ask for a pull request by id
    * Adds ability to set the upstream/tracking on a branch
    * Upgrades to Octokit 1.24 and no longer overrides the Connection class
      ([GH-74](https://github.com/jdigger/git-process/issues/74))
    * Adds module GitHubTestHelper
    * Made GitLib and AbstractMergeErrorBuilder classes instead of modules
    * Extracted GitCofig and GitRemote out of GitLib
    * Changed to use GitLogger as a logging fascade
    * GitProcess now takes a GitLib instead of a directory
    * GitHubService refactoring; includes extracting GitHubService::Configuration and GitHub::CreatePullRequest.
    * Supports RSpec default module for GitRepoHelper. Any RSpec context can declare :git_repo_helper as metadata to get
      standard GitRepoHelper lifecycle support as part of [GH-97](https://github.com/jdigger/git-process/issues/97).
    * Refactored GitHubService into GitHubService::Configuration
    * Refatored GitHub::PullRequest
    * Refatored GitLib#branch(..) and GitLib#command(..)

### Since 1.0.7 ###

* Fixed bug in git_status. [GH-93](https://github.com/jdigger/git-process/issues/93)

### Since 1.0.6 ###

* Fixed bug caused by CLI conflict on -i. [GH-13](https://github.com/jdigger/git-process/issues/13)

### Since 1.0.5 ###

* Adds option to make rebase the default for git-sync. [GH-82](https://github.com/jdigger/git-process/issues/82)
* git-sync is now "safer" when working with other people on the same branch. [GH-80](https://github.com/jdigger/git-process/issues/80)
* Interactive rebase is now an option for git-to-master. [GH-13](https://github.com/jdigger/git-process/issues/13)
* Simplified/improved arguments for git-pull-request [GH-86](https://github.com/jdigger/git-process/issues/86)
* Adds some more known statuses. [GH-84](https://github.com/jdigger/git-process/issues/84), [GH-88](https://github.com/jdigger/git-process/issues/88)

### Since 1.0.4 ###

* Do not try to fetch/push when doing sync if there is not remote. ([GH-70](https://github.com/jdigger/git-process/issues/70))
* git-sync now merges in upstream changes. ([GH-79](https://github.com/jdigger/git-process/issues/79))
* Simplified Windows installation instructions. ([GH-76](https://github.com/jdigger/git-process/issues/76),
  [GH-77](https://github.com/jdigger/git-process/issues/77))

### Since 1.0.3 ###

* Gets rid of infinite loop in Highline library. ([GH-72](https://github.com/jdigger/git-process/issues/72))

### Since 1.0.2 ###

* Removes the last of the gem dependencies that require native code. This makes it fully compatible
  with systems like Windows.
* Adds an option to explicitly set the remote server name.

### Since 1.0.1 ###

* Changes to dependencies to allow this to work on both Ruby 1.8 and 1.9

### Since 0.9.7 ###

* Adds --keep option to git-to-master
* Fixes problem trying to add/remove an empty list of files
* Documentation updates

### Since 0.9.7 ###

* Adds --keep option to git-to-master
* Fixes problem trying to add/remove an empty list of files
* Documentation updates

### Since 0.9.6 ###

* Cleans up Gem dependencies

### Since 0.9.5 ###

* Cleans up some error messages
* Improved documentation
* Adds support for spaces and renames in Status
* No longer complains if it can't find _parking_
* Prompts to remove the local version of the integration branch
* Adds help for handling changed files
