import 'dart:math';

import 'package:chess_timer/ui/timer_widget.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

class TimerView extends StatefulWidget {
  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  CountDownController _topTimerController;
  CountDownController _bottomTimerController;
  bool isTopTimerActive = true;
  bool isBottomTimerActive = false;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _topTimerController = CountDownController();
    _bottomTimerController = CountDownController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildTopTimer(context),
          ),
          Expanded(
            child: _buildBottomTimer(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTimer(BuildContext context) {
    final topTimerTheme = _buildTopTimerTheme(context);

    return Transform.rotate(
      angle: pi,
      child: Timer(
        isActive: isTopTimerActive,
        duration: Duration(minutes: 10),
        colorTheme: topTimerTheme,
        controller: _topTimerController,
        onTap: _switchActive,
      ),
    );
  }

  Widget _buildBottomTimer(BuildContext context) {
    final bottomTimerTheme = _buildBottomTimerTheme(context);
    return Timer(
      isActive: isBottomTimerActive,
      duration: Duration(minutes: 10),
      colorTheme: bottomTimerTheme,
      controller: _bottomTimerController,
      onTap: _switchActive,
    );
  }

  void _switchActive() {
    setState(() {
      isTopTimerActive = !isTopTimerActive;
      isBottomTimerActive = !isBottomTimerActive;

      _setTimerActive(_topTimerController, isTopTimerActive);
      _setTimerActive(_bottomTimerController, isBottomTimerActive);
    });
  }

  void _setTimerActive(CountDownController timerController, bool isActive) {
    if (isActive) {
      timerController.resume();
    } else {
      timerController.pause();
    }
  }

  TimerTheme _buildTopTimerTheme(BuildContext context) {
    final theme = Theme.of(context);
    return TimerTheme(
      enabledButtonColor: theme.primaryColor,
      disabledButtonColor: theme.primaryColor.withOpacity(.5),
      enabledBackgroundColor: Colors.white,
      disabledBackgroundColor: Colors.white,
      enabledProgressColor: Colors.white,
      disabledProgressColor: Colors.white.withOpacity(.5),
      enabledProgressBackgroundColor: Colors.white.withOpacity(.30),
      disabledProgressBackgroundColor: Colors.white.withOpacity(.12),
    );
  }

  TimerTheme _buildBottomTimerTheme(BuildContext context) {
    final theme = Theme.of(context);
    return TimerTheme(
      enabledButtonColor: Colors.white,
      disabledButtonColor: Colors.white.withOpacity(.5),
      enabledBackgroundColor: theme.primaryColor,
      disabledBackgroundColor: theme.primaryColor,
      enabledProgressColor: theme.primaryColor,
      disabledProgressColor: theme.primaryColor.withOpacity(.5),
      enabledProgressBackgroundColor: theme.primaryColor.withOpacity(.30),
      disabledProgressBackgroundColor: theme.primaryColor.withOpacity(.12),
    );
  }

  @override
  void dispose() {
    Wakelock.enable();
    super.dispose();
  }
}
