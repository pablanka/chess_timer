part of 'timer_widget.dart';

class TimerTheme {
  Color _enabledButtonColor;
  Color _disabledButtonColor;
  Color _enabledProgressColor;
  Color _disabledProgressColor;
  Color _enabledProgressBackgroundColor;
  Color _disabledProgressBackgroundColor;
  Color _enabledBackgroundColor;
  Color _disabledBackgroundColor;

  TimerTheme({
    Color enabledButtonColor,
    Color disabledButtonColor,
    Color enabledProgressColor,
    Color disabledProgressColor,
    Color enabledProgressBackgroundColor,
    Color disabledProgressBackgroundColor,
    Color enabledBackgroundColor,
    Color disabledBackgroundColor,
  })  : _enabledButtonColor = enabledButtonColor,
        _disabledButtonColor = disabledButtonColor,
        _enabledProgressColor = enabledProgressColor,
        _disabledProgressColor = disabledProgressColor,
        _enabledProgressBackgroundColor = enabledProgressBackgroundColor,
        _disabledProgressBackgroundColor = disabledProgressBackgroundColor,
        _enabledBackgroundColor = enabledBackgroundColor,
        _disabledBackgroundColor = disabledBackgroundColor;

  Color getBackgroundColor(bool isActive) {
    return isActive ? _enabledBackgroundColor : _disabledBackgroundColor;
  }

  Color getProgressColor(bool isActive) {
    return isActive ? _enabledProgressColor : _disabledProgressColor;
  }

  Color getButtonColor(bool isActive) {
    return isActive ? _enabledButtonColor : _disabledButtonColor;
  }

  Color getProgressBackgroundColor(bool isActive) {
    return isActive
        ? _enabledProgressBackgroundColor
        : _disabledProgressBackgroundColor;
  }
}
