import 'dart:math';

import 'package:chess_timer/ui/timer_widget.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

class TimerView extends StatefulWidget {
  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  CountDownController _lightTimerController;
  CountDownController _darkTimerController;
  bool _isLightTimerActive = false;
  bool _isDarkTimerActive = false;
  bool _timersFlipped = false;
  bool _isStarted = false;
  TimerButtonSound _timerButtonSound;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _lightTimerController = CountDownController();
    _darkTimerController = CountDownController();
    _timerButtonSound = TimerButtonSound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildTimers(context),
          Align(
            alignment: Alignment.center,
            child: _buildButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimers(BuildContext context) {
    return Transform.rotate(
      angle: _timersFlipped ? pi : 0,
      child: Column(
        children: [
          Expanded(child: _buildLightTimer(context)),
          Expanded(child: _buildDarkTimer(context)),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!_isStarted) _buildFlipTimersButton(),
        if (!_isStarted) _buildStartButton(),
        if (_isStarted) _buildStopButton(),
      ],
    );
  }

  Widget _buildFlipTimersButton() {
    final theme = Theme.of(context);
    return RaisedButton(
      shape: CircleBorder(),
      child: Icon(Icons.flip_camera_android, color: Colors.white),
      padding: const EdgeInsets.all(10),
      onPressed: _flipTimers,
      color: theme.accentColor,
    );
  }

  Widget _buildStartButton() {
    final theme = Theme.of(context);
    final size = 70.0;
    return Transform.rotate(
      angle: _timersFlipped ? pi : 0,
      child: Container(
        width: size,
        height: size,
        child: RaisedButton(
          shape: CircleBorder(),
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: size / 2,
          ),
          padding: const EdgeInsets.all(10),
          onPressed: _startTimers,
          color: theme.accentColor,
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    final theme = Theme.of(context);
    return Transform.rotate(
      angle: _timersFlipped ? pi : 0,
      child: RaisedButton(
        shape: CircleBorder(),
        child: Icon(
          Icons.stop,
          color: Colors.white,
          size: 30,
        ),
        padding: const EdgeInsets.all(10),
        onPressed: _showStopTimersDialog,
        color: theme.accentColor,
      ),
    );
  }

  void _flipTimers() {
    setState(() => _timersFlipped = !_timersFlipped);
  }

  void _startTimers() {
    setState(() {
      _isLightTimerActive = true;
      _isStarted = true;
      _setTimerActive(_lightTimerController, _isLightTimerActive);
    });
  }

  Future<void> _showStopTimersDialog() async {
    final theme = Theme.of(context);
    _pauseCurrent();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Finish match'),
          content: Text('Do you want to finish the match?'),
          actions: [
            TextButton(
              child: Text('NO', style: TextStyle(color: theme.accentColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            RaisedButton(
              child: Text('FINISH', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
              color: theme.accentColor,
            ),
          ],
        );
      },
    );

    if (result == true) {
      _resetTimers();
    } else {
      _resumeCurrent();
    }
  }

  void _pauseCurrent() {
    setState(() {
      final current =
          _isLightTimerActive ? _lightTimerController : _darkTimerController;
      _setTimerActive(current, false);
    });
  }

  void _resumeCurrent() {
    setState(() {
      final current =
          _isLightTimerActive ? _lightTimerController : _darkTimerController;
      _setTimerActive(current, true);
    });
  }

  void _resetTimers() {
    setState(() {
      _isLightTimerActive = false;
      _isDarkTimerActive = false;
      _isStarted = false;
      _lightTimerController.restart();
      _lightTimerController.pause();
      _darkTimerController.restart();
      _darkTimerController.pause();
    });
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
      controller: _darkTimerController,
      colorTheme: darkTimerTheme,
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
