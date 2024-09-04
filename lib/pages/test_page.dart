import 'dart:async';
import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class AnimatedContainerExample extends StatefulWidget {
  const AnimatedContainerExample({super.key});

  @override
  _AnimatedContainerExampleState createState() => _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  bool isBlue = true;
  int currentIndex = 0;
  List<String> items = [
    '000000000000',
    '111111111111',
    '222222222222',
    '333333333333',
    '444444444444'
  ];

  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Animator Example')),
      body: Container(
        child: ClipRect( // Membatasi area animasi
          child: SizedBox(
            height: 20,
            child: WidgetAnimator(incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(
                    offset: const Offset(0, 7),
                    duration: const Duration(milliseconds: 500), // Ubah durasi sesuai kebutuhan
                  ),
                  onIncomingAnimationComplete: (p0) async {
                    await Future.delayed(const Duration(milliseconds: 1000)); // Delay selama 1 detik
                    setState(() {
                      isBlue = !isBlue;
                      currentIndex = (currentIndex + 1) % items.length; // Update index
                    });
                  },
                  outgoingEffect: WidgetTransitionEffects.outgoingSlideOutToTop(
                    offset: const Offset(0, -7),
                    duration: const Duration(milliseconds: 500), // Ubah durasi sesuai kebutuhan
                  ),
                  onOutgoingAnimationComplete: (p0) async {
                  },
              child: (isBlue)
                  ? Container(key: const ValueKey('blue'), color: Colors.transparent, alignment: Alignment.center, child: Text(items[currentIndex], style: const TextStyle(color: Colors.black)))
                  : Container(key: const ValueKey('red'), color: Colors.transparent, alignment: Alignment.center, child: Text(items[currentIndex], style: const TextStyle(color: Colors.black))),
            ),
          ),
        ),
      ),
    );
  }
}
