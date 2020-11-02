# 4. upgrade-file-picker-library-version

Date: 2020-11-02

## Status

Accepted

## Context

In LinShare Flutter application, we can select file from system file manager by library `file_picker`
The current version is `2.0.7` is not supporting well for Android and iOs,
in Android when get fileName we will have fileName along with fileExtension
in iOS when get fileName we will have only fileName

## Decision

We decided to use newer version `2.0.11`, with this, both Android and iOS now have fileName along with fileExtension

## Consequences

Base on our implementation, the application is working well on both Android and IOS
