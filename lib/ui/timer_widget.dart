import 'dart:typed_data';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_lite/flutter_sound_player.dart';

part 'timer_button_sound.dart';
part 'timer_theme.dart';

class Timer extends StatelessWidget {
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final CountDownController controller;
  final bool isActive;
  final TimerTheme colorTheme;
  final TimerButtonSound sound;

  Timer({
    Key key,
    @required this.duration,
    this.onTap,
    this.onComplete,
    this.controller,
    this.colorTheme,
    this.sound,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timerSize = MediaQuery.of(context).size.width / 1.8;
    final maxSize = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final progressColor = colorTheme.getProgressColor(isActive);
    final timerTextStyle = textTheme.headline2.copyWith(color: progressColor);
    final borderRadius = BorderRadius.circular(timerSize / 2);
    final elevation = isActive ? 30.0 : 0.0;

    return Container(
      color: colorTheme.getBackgroundColor(isActive),
      child: Center(
        child: Container(
          width: timerSize,
          height: timerSize,
          constraints: BoxConstraints(maxHeight: maxSize, maxWidth: maxSize),
          child: Material(
            elevation: elevation,
            color: colorTheme.getButtonColor(isActive),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            child: InkWell(
              onTap: isActive ? _onTap : null,
              borderRadius: borderRadius,
              child: CircularCountDownTimer(
                backgroundColor: Colors.transparent,
                duration: duration.inSeconds,
                controller: controller,
                width: timerSize,
                height: timerSize,
                color: colorTheme.getProgressBackgroundColor(isActive),
                fillColor: progressColor,
                strokeWidth: 5.0,
                strokeCap: StrokeCap.round,
                textStyle: timerTextStyle,
                isReverse: true,
                isReverseAnimation: true,
                isTimerTextShown: true,
                onComplete: onComplete,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTap() async {
    if (onTap != null) onTap();
    if (sound != null) sound.play();
  }
}
