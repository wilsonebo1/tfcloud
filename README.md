# DataRobot Install Guides

This repository contains documentation for installing and administering DataRobot clusters.

Documentation is split into several "guides", denoted by their separate directories:

* `backup-restore`: Guide for backing up and restoring data for DataRobot installs
* `installation`: Guide for installing/configuring/upgrading docker-based DataRobot installs (with or without hadoop and/or kubernetes)
* `rpm-installation`: Guide for installing/configuring/upgrading RPM-based DataRobot installs (with or without hadoop)

Each guide builds separate PDFs which are manually uploaded to [Enterprise Release pages](https://datarobot.atlassian.net/wiki/spaces/ONPREM/pages/9732170/Enterprise+Releases).

## Contributing

This repository uses release-branching (separate `release/*` branches for each release).

*NOTE*: Only file referenced in `SUMMARY.md` will end up in rendered PDFs!

Recommended workflow:

* Clone this repository
* Determine which release you are making changes for, start by checking out that release (e.g. `git checkout origin/release/<release>`)
* Create a new branch off targeted release for ticket being worked on (e.g. `git checkout -B <your-name>/<ticket-id>`)
* Edit files
* Test and view rendered PDFs (`./build.sh test`)
* Verify PDF files look as expected and links are updated and working properly
* Make commits (e.g. `git commit -am "<some commit message>"`)
* Push branch (e.g. `git push origin <your-name>/<ticket-id>`)
* Open a Pull Request in Github from your branch to target branch (`master` or `release/*` branch)
* If changes need to be in other releases or future, then use `jarvis please cherry-pick this to <release>` on PR to cherry-pick to desired branch(es)

*NOTE*: Before opening a PR, please verify also that `./build.sh test` creates valid PDF files that look appropriate.

Always ensure all links are updated and working properly.

### Github-Flavored Markdown

Files in this repo must abide [Github-Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Platform Guide Installer Toolkit

Starting with 7.0, as part of the test/publish of PDFs, the jenkins jobs which test and publish guide PDFs will checkout `DataRobot` repo
at the branch/reference in the `DataRobot.VERSION` file. Typically, this file will match the release branch of `admin-guide` repo (e.g.
the `DataRobot.VERSION` file will have `release/7.0` in it for the `release/7.0` branch of this repo). However, after branch cut, and
before final release, this target may not match (e.g. before we cut a `release/*` branch off of this repo).

During `./build.sh test`, files from `$WORKSPACE/DataRobot/dev-docs/docs/platform_guide/installer-toolkit` are copied into
`installation/installer-toolkit`. All files there can be referenced and included in the rendered Install Guide PDF.

*NOTE*: Files copied in must _still_ be referenced somewhere in `SUMMARY.md` to end up in the rendered PDFS.

## Publishing

When PRs to release branches are merged, PDFs are created by the [Admin_Guide_Publish](https://jenkins.hq.datarobot.com/job/Admin_Guide_Publish/) job.

*NOTE*: Starting in 7.0, files from the [Platform Guide](https://github.com/datarobot/DataRobot/tree/master/dev-docs/docs/platform_guide) are copied into building the PDFs. When the jenkins job is run, the `DataRobot` repo is cloned and checked out at the branch/reference in the `DataRobot.VERSION` file, or `master` (if the branch of `admin-guide` predates this file).

*NOTE*: Rendered PDFs must be manually uploaded to the appropriate [Enterprise Release pages](https://datarobot.atlassian.net/wiki/spaces/ONPREM/pages/9732170/Enterprise+Releases).
