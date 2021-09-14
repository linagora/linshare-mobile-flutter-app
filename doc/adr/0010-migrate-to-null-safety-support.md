# 10. migrate-to-null-safety-support

Date: 2021-05-10

## Status

Accepted

## Context

- Upload the latest stable Flutter version (2.0.5) and Dart (2.12.2)
- Be familiar and apply new version change from dependency libraries

## Decision

- Upgrade Flutter SDK and Dart environment
- Update dependency libraries version to support null-safety

## Implementation

Follow official guideline: [https://dart.dev/null-safety/migration-guide](https://dart.dev/null-safety/migration-guide)

1. Upgrade Flutter and Dart SDK environment

- Android Studio:
    > Tool > Flutter > Flutter Upgrade

- Terminal:
    > flutter upgrade

2. Check libraries support null-safety to review which libraries will be upgrade

    > flutter pub outdated --mode=null-safety

3. Upgrade library version

    > flutter pub upgrade --null-safety

4. Using the migration tool

    > dart migrate
    
    Some optional command can use while migrating:
    > dart migrate --skip-import-check
    > dart migrate --skip-import-check --ignore-errors

5. Open generated url in web-browser for reviewing and applying for all changes


## Consequences

- ADVANTAGE:
    - Update the latest change from dependency libraries which may contains new features/bug fixes in new version

- DISADVANTAGE:
    - Some libraries haven't updated to support null-safety yet. This make some other dependencies libraries on them can not work. For eg: 
       
        - **intl_translation: 0.17.10+1**
            ```shell script
                Because intl_translation 0.17.10+1 depends on intl >=0.15.3 <0.17.0 and linshare_flutter_app depends on intl 0.17.0, intl_translation 0.17.10+1 is forbidden.
                So, because linshare_flutter_app depends on intl_translation 0.17.10+1, version solving failed.
                pub get failed (1; So, because linshare_flutter_app depends on intl_translation 0.17.10+1, version solving failed.)
            ```
        
            &rarr; Solution: Use `dependency_overrides`
            ```yaml
                dependency_overrides:
                  # intl
                  intl: 0.17.0
                
                  # build_runner dependencies
                  crypto: 3.0.0
                  args: 2.0.0
                  dart_style: 2.0.0
                  analyzer: 1.4.0
                  convert: 3.0.0
                  petitparser: 4.1.0
            ``` 
      
    - Some libraries supported null-safety but still have unresolved errors. For eg:
        
        - **flutter_uploader: 3.0.0-beta.1**
            ```shell script
            E/UploadWorker(26371): exception encounteredprotocol
            E/UploadWorker(26371): java.net.ProtocolException: unexpected end of stream
            ```
            Check the issue [#162](https://github.com/fluttercommunity/flutter_uploader/issues/162)
        
            &rarr; Solution: Use `flutter_uploader: 1.2.1`
