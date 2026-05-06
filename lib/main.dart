import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect 4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // Apply the transition globally
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: WarpZoomTransitionsBuilder(),
            TargetPlatform.iOS: WarpZoomTransitionsBuilder(),
            TargetPlatform.macOS: WarpZoomTransitionsBuilder(),
            TargetPlatform.windows: WarpZoomTransitionsBuilder(),
          },
        ),
      ),
      home: const MenuScreen(),
    );
  }
}

/// Custom Page Transition Which Zooms in, blurs, and zooms out
class WarpZoomTransitionsBuilder extends PageTransitionsBuilder {
  const WarpZoomTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 1. Curved animation to smooth out the entry
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutQuart,
    );

    // 2. Drive the scaling factor from 0.75 (zoomed out/tiny) to 1.0 (normal size)
    final Animation<double> scale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(curvedAnimation);

    // 3. Drive the blur factor from 25.0 (highly blurred) to 0.0 (perfectly clear)
    final Animation<double> blur = Tween<double>(
      begin: 25.0,
      end: 0.0,
    ).animate(curvedAnimation);

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blur.value,
            sigmaY: blur.value,
          ),
          child: ScaleTransition(
            scale: scale,
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
