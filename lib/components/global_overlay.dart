import 'package:flutter/material.dart';

class GlobalOverlay {
  static OverlayEntry? _holder;

  static late Widget view;

  static void remove() {
    _holder?.remove();
    _holder = null;
  }

  static void show({required BuildContext context, required Widget view}) {
    GlobalOverlay.view = view;

    remove();
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(bottom: 0, child: view);
      },
    );

    Overlay.of(context).insert(overlayEntry);

    _holder = overlayEntry;
  }

  static void refresh() {
    _holder?.markNeedsBuild();
  }
}
