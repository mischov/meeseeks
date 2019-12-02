# Contributing

## Bug Reports

If submitting a bug report please search open and closed issues first.

## Pull Requests

If you want to add new or change existing behavior, please submit an issue explaining what you want to add or change and why **before** submitting a PR.

In order to submit a pull request:

1. Fork the project
2. Create a topic branch off of `master`, following [branch naming](#branch-naming) conventions
3. Push the topic branch to your fork
4. Open pull request, following [PR formatting](#pr-formatting) conventions

Please ensure that you also follow project conventions around [code style](#code-style), [testing](#testing), and [commit messages](#commit-messages).

By submitting a PR, you agree to license your work under the license of this project.

## Conventions

### Branch Naming

Please start your branch name with one of `feature`, `fix`, or `chore` as applicable, then a `/`, then a succinct description of what the branch is about (for example, `chore/contribution-guidelines`).

- `feature` indicates the addition of new functionality or enhancement of existing functionality
- `fix` indicates a fix for a bug or other existing problem
- `chore` indicates changes that don't modify how the project works, such as refactoring or adding additional tests/documentation

### Code Style

Please run `mix format` prior to committing.

### Testing

If you're submitting a bug fix, please include a test or tests that would have caught the problem.

If you're submitting new features, please add tests (and documentation) as appropriate.

### Commit Messages

Commit messages should attempt to follow [the seven rules of a great Git commit message](https://chris.beams.io/posts/git-commit/#seven-rules):

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how

### PR Formatting

The title of the PR should succinctly describe what the PR accomplishes, while the body should briefly detail how that was accomplished if it isn't evident in the title.

If the PR is related to an issue or issues reference them in the first line ("PR for issue #123."), but don't use keywords that would automatically close the issue (like "closes #123" or "fixes #123").

If a PR makes any breaking changes make sure those changes are highlighted in the body.
