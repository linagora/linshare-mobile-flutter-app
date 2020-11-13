# 7. path-provider-library

Date: 2020-11-13

## Status

Pending

## Context

Android and iOS have different folder architectures. 
Therefore we need to provide *path folder* according to user's plateform.

`path-provider` library only provide *Download Folder* for Android Version.

## Decision

We decided to use `path-provider` if the user is on Android, and use an other library (TBD) if the user is on iOS.

## Consequences

Users can download file with LinShare with the same application on both platforms.
