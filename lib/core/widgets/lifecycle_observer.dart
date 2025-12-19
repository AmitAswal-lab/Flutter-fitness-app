import 'package:flutter/material.dart';

/// A widget that detects when the app resumes from background
/// and calls [onResume] callback
class LifecycleObserver extends StatefulWidget {
  final Widget child;
  final VoidCallback? onResume;
  final VoidCallback? onPause;

  const LifecycleObserver({
    super.key,
    required this.child,
    this.onResume,
    this.onPause,
  });

  @override
  State<LifecycleObserver> createState() => _LifecycleObserverState();
}

class _LifecycleObserverState extends State<LifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.onResume?.call();
    } else if (state == AppLifecycleState.paused) {
      widget.onPause?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
