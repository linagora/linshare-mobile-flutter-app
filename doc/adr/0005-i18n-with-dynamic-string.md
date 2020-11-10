# 5. i18n with dynamic string

Date: 2020-11-10

## Status

Accepted

## Context

We need to provide i18n string with some requirements:

- dynamic string

- support plurals

## Decision

Need to implement it with `intl` 

## Consequences

Set up:

1. Add localization dependencies
```
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations: # add this
    sdk: flutter # add this
# other lines
dev_dependencies:  
  intl_translation: {lastest version}
```

2. Localization class

3. The `.arb` (Application Resource Bundle) file
```
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localizations.dart
```
Requirement:
- folder l10n is created
- last parameter (localizations.dart) is the file that contains `Intl.message`

```
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n \
   --no-use-deferred-loading lib/localization.dart lib/l10n/intl_*.arb
``` 