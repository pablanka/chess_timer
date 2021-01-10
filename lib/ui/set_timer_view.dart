import 'package:flutter/material.dart';

class SetTimerView extends StatelessWidget {
  final Duration selectedDuration;

  const SetTimerView({
    Key key,
    this.selectedDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timers'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        children: [
          _buildSection(
            context,
            'Bullet',
            [
              _buildTimeButton(context, Duration(minutes: 1)),
              _buildTimeButton(context, Duration(minutes: 2)),
            ],
          ),
          _buildSection(
            context,
            'Blitz',
            [
              _buildTimeButton(context, Duration(minutes: 3)),
              _buildTimeButton(context, Duration(minutes: 5)),
            ],
          ),
          _buildSection(
            context,
            'Rapid',
            [
              _buildTimeButton(context, Duration(minutes: 10)),
              _buildTimeButton(context, Duration(minutes: 15)),
              _buildTimeButton(context, Duration(minutes: 20)),
              _buildTimeButton(context, Duration(minutes: 30)),
              _buildTimeButton(context, Duration(minutes: 60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String titleText,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context, titleText),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 5,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context, Duration duration) {
    final theme = Theme.of(context);
    final minutes = duration.inMinutes;

    if (duration == selectedDuration) {
      return RaisedButton(
        child: Text('$minutes min', style: TextStyle(color: Colors.white)),
        onPressed: () => _onTimeButtonTap(context, duration),
        color: theme.accentColor,
      );
    }

    return OutlineButton(
      child: Text('$minutes min'),
      textColor: theme.accentColor,
      color: theme.accentColor,
      onPressed: () => _onTimeButtonTap(context, duration),
    );
  }

  void _onTimeButtonTap(BuildContext context, Duration duration) {
    Navigator.of(context).pop(duration);
  }

  Widget _buildTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Text(text, style: theme.textTheme.headline5);
  }
}
