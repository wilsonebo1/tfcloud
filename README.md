# DataRobot Enterprise Installation and Administration Manual

This repository contains documentation for installing and administering DataRobot Enterprise clusters.

## Structure

To avoid putting too much in a single PDF or book, this documentation is split into several sections, denoted by their separate folders.

### Installation

Instructions for installing and upgrading DataRobot are found in `installation/`.
This includes advanced configuration options and instructions for Linux-only as well as Cloudera installations.

### Administration

This documentation is for all post-installation cluster administration tasks.
These can include restarting services, recovering from common failure modes, backing up and restoring data, and more.

## Publishing

Currently these docs are not published, but we'll update this section once we have a better clue.
Chances are they will go on Confluence pages and be served on a support page.
We can also easily run an HTTP server with the docs for internal usage and we may also include PDF's or an HTTP server in the on-prem application itself.

You can build them locally using GitBook quite easily.

## Dependencies

These docs are built using [GitBook](https://gitbook.com).

Please refer to the [GitBook Toolchain Documentation](https://toolchain.gitbook.com/) for help installing and using GitBook.

You will need to install Calibre `ebook-convert` to create `PDF` files.
See [GitBook Documentation for installing ebook-convert](https://toolchain.gitbook.com/ebook.html).

# Contributing

Thanks for your interest in contributing to the DataRobot Enterprise Installation Guide.

Please refer to this page for instructions on making useful contributions.

## Quick Guide

Clone this GitHub repository and create a new branch for your changes:

```bash
cd ~/workspace
git clone git@github.com:datarobot/admin-guide.git
cd admin-guide
git checkout -b <ticket ID>/<short description>
# Edit files
# test files
gitbook serve  # load http://localhost:4000 in your browser
gitbook pdf    # Verify book.pdf renders properly
git commit -am 'some commit message'
git push origin <branch name>
# Open GitHub PR and wait for review.
```

## Versions
First, ensure you are editing the right version of the documentation.

Right now, development is on `master`.
Once the 3.1 docs are published, we will create a `release/3.1` branch for 3.1 docs, while `master` will refer to future, 3.2 docs.

To switch branches, use `git checkout <branch name>`.

## Development

GitBook makes development quite easy.
In the root of this repository, simply run `gitbook serve` to run a local server where you can view changes.
Your browser will automatically refresh when files are changed.

Before making a commit, verify also that `gitbook pdf` creates a valid PDF file that looks appropriate.

Always ensure all links are updated and working properly.

## Style Guide

* One line per sentence.

* Use triple backticks for code blocks, and include syntax highlighting directives when applicable.

## Misc Help

### Links

Links can be a little tricky.
For help with relative linking in GitBook, see [this example book](https://seadude.gitbooks.io/learn-gitbook/content/).

Note that your `SUMMARY.md` file must have a reference to a markdown file you want to link to.
