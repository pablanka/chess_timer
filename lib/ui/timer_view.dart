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
  CountDownController _lightTimerController;
  CountDownController _darkTimerController;
  bool _isLightTimerActive = true;
  bool _isDarkTimerActive = false;
  TimerButtonSound _timerButtonSound;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _lightTimerController = CountDownController();
    _darkTimerController = CountDownController();
    _timerButtonSound = TimerButtonSound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildLightTimer(context),
          ),
          Expanded(
            child: _buildDarkTimer(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLightTimer(BuildContext context) {
    final lightTimerTheme = _buildLightTimerTheme(context);

    return Transform.rotate(
      angle: pi,
      child: Timer(
        isActive: _isLightTimerActive,
        duration: Duration(minutes: 10),
        colorTheme: lightTimerTheme,
        controller: _lightTimerController,
        onTap: _switchActive,
        sound: _timerButtonSound,
      ),
    );
  }

  Widget _buildDarkTimer(BuildContext context) {
    final darkTimerTheme = _buildDarkTimerTheme(context);
    return Timer(
      isActive: _isDarkTimerActive,
      duration: Duration(minutes: 10),
      colorTheme: darkTimerTheme,
      controller: _darkTimerController,
      onTap: _switchActive,
      sound: _timerButtonSound,
    );
  }

  void _switchActive() {
    setState(() {
      _isLightTimerActive = !_isLightTimerActive;
      _isDarkTimerActive = !_isDarkTimerActive;

      _setTimerActive(_lightTimerController, _isLightTimerActive);
      _setTimerActive(_darkTimerController, _isDarkTimerActive);
    });
  }

  void _setTimerActive(CountDownController timerController, bool isActive) {
    if (isActive) {
      timerController.resume();
    } else {
      timerController.pause();
    }
  }

  TimerTheme _buildLightTimerTheme(BuildContext context) {
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

  TimerTheme _buildDarkTimerTheme(BuildContext context) {
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
