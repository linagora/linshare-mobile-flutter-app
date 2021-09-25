import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  AsyncCallback? resumeCallBack;
  AsyncCallback? inActiveCallBack;
  AsyncCallback? pausedCallBack;
  AsyncCallback? detachedCallBack;

  LifecycleEventHandler setResumeCallback(AsyncCallback resumeCallBack) {
    this.resumeCallBack = resumeCallBack;
    return this;
  }

  LifecycleEventHandler setInActiveCallBack(AsyncCallback inActiveCallBack) {
    this.inActiveCallBack = inActiveCallBack;
    return this;
  }

  LifecycleEventHandler setPausedCallBack(AsyncCallback pausedCallBack) {
    this.pausedCallBack = pausedCallBack;
    return this;
  }

  LifecycleEventHandler setDetachedCallBack(AsyncCallback detachedCallBack) {
    this.detachedCallBack = detachedCallBack;
    return this;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack!();
        }
        break;
      case AppLifecycleState.inactive:
        if (inActiveCallBack != null) {
          await inActiveCallBack!();
        }
        break;
      case AppLifecycleState.paused:
        if (pausedCallBack != null) {
          await pausedCallBack!();
        }
        break;
      case AppLifecycleState.detached:
        if (detachedCallBack != null) {
          await detachedCallBack!();
        }
        break;
    }
  }
}
