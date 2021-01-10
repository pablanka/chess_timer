import 'dart:math';

import 'package:chess_timer/ui/set_timer_view.dart';
import 'package:chess_timer/ui/timer_widget.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

enum MatchStatus { notStarted, inProgress, paused, finished }
enum TimerType { light, dark }

class TimerView extends StatefulWidget {
  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  CountDownController _lightTimerController;
  CountDownController _darkTimerController;
  MatchStatus _matchStatus = MatchStatus.notStarted;
  TimerType _activeTimer;
  bool _timersFlipped = false;
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
        if (_matchStatus == MatchStatus.notStarted) _buildFlipTimersButton(),
        if (_matchStatus == MatchStatus.notStarted) _buildSetTimerButton(),
        if (_matchStatus == MatchStatus.inProgress) _buildPauseButton(),
        if (_matchStatus == MatchStatus.inProgress) _buildStopButton(),
        if (_matchStatus == MatchStatus.paused) _buildResumeButton(),
        if (_matchStatus == MatchStatus.finished) _buildNewMatchButton(),
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
    final size = 60.0;
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
          padding: const EdgeInsets.all(0),
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
        child: Icon(Icons.stop, color: Colors.white, size: 30),
        padding: const EdgeInsets.all(10),
        onPressed: _showStopTimersDialog,
        color: theme.accentColor,
      ),
    );
  }

  Widget _buildPauseButton() {
    final theme = Theme.of(context);
    return Transform.rotate(
      angle: _timersFlipped ? pi : 0,
      child: RaisedButton(
        shape: CircleBorder(),
        child: Icon(Icons.pause, color: Colors.white, size: 30),
        padding: const EdgeInsets.all(10),
        onPressed: _pauseTimers,
        color: theme.accentColor,
      ),
    );
  }

  Widget _buildResumeButton() {
    final theme = Theme.of(context);
    return Transform.rotate(
      angle: _activeTimer == TimerType.light ? pi : 0,
      child: RaisedButton(
        shape: CircleBorder(),
        child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
        padding: const EdgeInsets.all(10),
        onPressed: _resume,
        color: theme.accentColor,
      ),
    );
  }

  Widget _buildSetTimerButton() {
    final theme = Theme.of(context);
    return RaisedButton(
      shape: CircleBorder(),
      child: Icon(Icons.timer, color: Colors.white),
      padding: const EdgeInsets.all(10),
      onPressed: _openSetTimerView,
      color: theme.accentColor,
    );
  }

  Widget _buildNewMatchButton() {
    final theme = Theme.of(context);
    return RaisedButton(
      shape: CircleBorder(),
      child: Icon(Icons.close, color: Colors.white),
      padding: const EdgeInsets.all(10),
      onPressed: _resetTimers,
      color: theme.accentColor,
    );
  }

  void _openSetTimerView() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SetTimerView(),
    ));
  }

  void _flipTimers() {
    setState(() => _timersFlipped = !_timersFlipped);
  }

  void _startTimers() {
    setState(() {
      _matchStatus = MatchStatus.inProgress;
      _activeTimer = TimerType.light;

      _setTimerActive(_activeTimer, true);
    });
  }

  Future<void> _showStopTimersDialog() async {
    final theme = Theme.of(context);
    _pauseActive();
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
      _resumeActive();
    }
  }

  void _pauseActive() {
    setState(() => _setTimerActive(_activeTimer, false));
  }

  void _resumeActive() {
    setState(() => _setTimerActive(_activeTimer, true));
  }

  void _resetTimers() {
    setState(() {
      _activeTimer = null;
      _matchStatus = MatchStatus.notStarted;
      _lightTimerController.restart();
      _lightTimerController.pause();
      _darkTimerController.restart();
      _darkTimerController.pause();
    });
  }

  void _pauseTimers() {
    _matchStatus = MatchStatus.paused;
    _pauseActive();
  }

  void _resume() {
    _matchStatus = MatchStatus.inProgress;
    _resumeActive();
  }

  Widget _buildLightTimer(BuildContext context) {
    final lightTimerTheme = _buildLightTimerTheme(context);
    final isActive = _isTimerActive(TimerType.light);

    return Transform.rotate(
      angle: pi,
      child: Timer(
        isActive: isActive,
        duration: _getMatchDuration(),
        colorTheme: lightTimerTheme,
        controller: _lightTimerController,
        onTap: _switchActive,
        sound: _timerButtonSound,
        onComplete: _onTimerFinished,
      ),
    );
  }

  bool _isTimerActive(TimerType timer) {
    return _activeTimer == timer &&
        (_matchStatus == MatchStatus.inProgress ||
            _matchStatus == MatchStatus.finished);
  }

  void _onTimerFinished() {
    setState(() => _matchStatus = MatchStatus.finished);

    _showMatchFinishedDialog();
  }

  void _showMatchFinishedDialog() {
    final theme = Theme.of(context);
    showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Match has finished'),
          content: Text('Timer is over!'),
          actions: [
            RaisedButton(
              child: Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
              color: theme.accentColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDarkTimer(BuildContext context) {
    final darkTimerTheme = _buildDarkTimerTheme(context);
    final isActive = _isTimerActive(TimerType.dark);

    return Stack(
      children: [
        Timer(
          isActive: isActive,
          duration: _getMatchDuration(),
          controller: _darkTimerController,
          colorTheme: darkTimerTheme,
          onTap: _switchActive,
          sound: _timerButtonSound,
          onComplete: _onTimerFinished,
        ),
        if (_matchStatus == MatchStatus.notStarted)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: _buildStartButton(),
            ),
          ),
      ],
    );
  }

  Duration _getMatchDuration() {
    return Duration(seconds: 5);
  }

  void _switchActive() {
    setState(() {
      _setTimerActive(_activeTimer, false);
      _activeTimer =
          _activeTimer == TimerType.light ? TimerType.dark : TimerType.light;
      _setTimerActive(_activeTimer, true);
    });
  }

  void _setTimerActive(TimerType timerType, bool isActive) {
    final timerController = timerType == TimerType.light
        ? _lightTimerController
        : _darkTimerController;

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
