import 'package:chess_timer/ui/palette.dart';
import 'package:chess_timer/ui/timer_view.dart';
import 'package:flutter/material.dart';

class ChessTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess timer',
      theme: ThemeData(
        primaryColor: Palette.primary,
      ),
      home: TimerView(),
    );
  }
}
