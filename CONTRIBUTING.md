# Contributing

## Setup

```
flutter pub get
flutter run
```

## Before submitting a pull request

- Run `flutter analyze` and fix all issues.
- Run `flutter test` and ensure all tests pass.
- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.
- Keep pull requests focused (one feature or fix per PR).
- All code, comments, and documentation must be in English.

## Commit format

```
<type>(<scope>): <description>
```

Types: `feat`, `fix`, `refactor`, `style`, `test`, `docs`, `chore`, `perf`, `ci`, `revert`, `build`

Examples:

```
feat: intercept Instagram mic button with native audio recorder
fix: prevent hardware back button from exiting the app
docs: add release README
```

## Code style

This project follows the [engineering guide](./engineering-guide.local.md/README.md). Key rules:

- Functions: max 30 lines.
- Files: max 500 lines.
- Function parameters: max 3.
- Guard clauses over nested conditionals.
- Comments document the "why", not the "what".

## License

MIT
