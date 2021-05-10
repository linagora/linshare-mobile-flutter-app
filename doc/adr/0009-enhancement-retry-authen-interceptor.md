# 9. enhancement-retry-authen-interceptor

Date: 2021-05-10

## Status

Accepted

## Context

- The current `retry` logic is limited in the number of `retry` for failed requests. For example, at a screen where more than 3 different requests fail, the chance of each request being retried is very little, since they share a variable that counts the number of retry times.
- Using a (in memory) counter variable for `retry` is risky and difficult to control

## Decision

1. Send the `retry` counter into request header for each request
2. Retrieve the `retry` count from request data
3. Validate with the maximum allowed. If `retry` in the limit, increment it then re-send a request network with updated `retry` counter

```
{
    ...
    SET retriesCount from request extra map with key RETRY_KEY
    IF _isAuthenticationError(dioError, retriesCount) THEN
        INCREMENT retriesCount
        ADD retriesCount to header with key RETRY_KEY
        CALL request again
    ENDIF
    ...
}
```

## Consequences

- The chance of each request being retried is increased
- `Retry` counter is controlled inside the request