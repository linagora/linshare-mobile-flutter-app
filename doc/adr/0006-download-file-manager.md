# 6. download-file-manager

Date: 2020-11-13

## Status

Accepted

## Context

In LinShare Flutter application, we can download files one by one from "My Space", "Received Shares" or "Shared Spaces" with the library `flutter_downloader` by adding it to the queue :

```
TaskId enqueue(String url, String saveDir, String header...)
```

We can also clear or cancel file queue with dedicated functions.

## Decision

We decided that LinShare could currently download a file one by one.

## Consequences

Since the UI only allow to download one file at the time for now, there is no consequence.