# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedTidb<T>(...)` — wraps a otel_tidb call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutTidbInstrumentation()` / `Async()`.
