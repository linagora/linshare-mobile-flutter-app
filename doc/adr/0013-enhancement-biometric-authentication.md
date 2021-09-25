# 13. enhancement_biometric_authentication

Date: 2021-09-25

## Status

Accepted

## Context

Current biometric authentication behavior is not enough powerful for security when user turns back to application (foreground) from background 
(in the case logged-in and already configured biometric authentication).

## Decision

Adding biometric authentication prompt when turning back application after dimmed application in background for X minute 
(X is configured by an option setting in the Biometric Authentication screen)

### Solutions
- Detecting application in foreground/background:

   - `WidgetsBindingObserver`: 
     Working well when detect app on foreground or background. 
     But when app picking files for uploading, this solution is failed. 
     The reason is that it only listens the state changes of the embedding Activity/ViewController. 
     So, when app opens a new activity/view controller (file picking or other similar functions later),
     the listener will be invoked. This make us to do more stuffs for checking conditions (1)

   - `SystemChannels`: 
     Actually this is lower layer used by `WidgetsBindingObserver`. So, it makes the same result.

   **(1)** Additional state on UIState for detecting some special cases (inside app, outside app, etc).
  
- Use [RestartableTimer](https://pub.dev/documentation/async/latest/async/RestartableTimer-class.html) by supported `reset()` method.
We need to reset timer when app comes back to foreground.

- Listen Biometric Setting Timeout changes: 
Use a [StreamSubscription](https://api.dart.dev/stable/2.13.4/dart-async/StreamSubscription-class.html) for listening `biometricAuthenticationSettingState`'s viewState changes.

## Consequences

- App will be more secure with enhancement of biometric authentication whenever comes back to foreground.
