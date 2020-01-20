// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

enum _Element { background, text, gradientBegin, gradientEnd }

final _lightTheme = {
  _Element.background: Color(0xFFFAFAFA),
  _Element.text: Colors.black,
  _Element.gradientBegin: Color(0xFFFAFAFA),
  _Element.gradientEnd: Color(0x00FAFAFA)
};

final _darkTheme = {
  _Element.background: Color(0xFF121212),
  _Element.text: Color(0xFFD7FFEC),
  _Element.gradientBegin: Colors.black,
  _Element.gradientEnd: Colors.transparent
};

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  FixedExtentScrollController _hour1SC;
  FixedExtentScrollController _hour2SC;
  FixedExtentScrollController _minute1SC;
  FixedExtentScrollController _minute2SC;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateScrollControllers() {
    final is24HourFormat = widget.model.is24HourFormat;
    final hour = DateFormat(is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    final hour1 = hour.substring(0, 1).parseInt();
    final hour2 = hour.substring(1, 2).parseInt();
    final minute1 = minute.substring(0, 1).parseInt();
    final minute2 = minute.substring(1, 2).parseInt();

    final customEasing = Cubic(0.37, 0.02, 0.27, 0.95);
    final longDuration = Duration(milliseconds: 1500);
    final shortDuration = Duration(milliseconds: 500);

    if (_hour1SC != null) {
      _hour1SC.animateToItem(hour1,
          duration: longDuration, curve: customEasing);
    } else {
      _hour1SC = FixedExtentScrollController(initialItem: hour1);
    }

    if (_hour2SC != null) {
      _hour2SC.animateToItem(hour2,
          duration: longDuration, curve: customEasing);
    } else {
      _hour2SC = FixedExtentScrollController(initialItem: hour2);
    }

    if (_minute1SC != null) {
      _minute1SC.animateToItem(minute1,
          duration: longDuration, curve: customEasing);
    } else {
      _minute1SC = FixedExtentScrollController(initialItem: minute1);
    }

    if (_minute2SC != null) {
      if (minute1 >= 1) {
        // Every 10 minutes
        _minute2SC.animateToItem(minute2,
            duration: longDuration, curve: customEasing);
      } else {
        // Every minute
        _minute2SC.animateToItem(minute2,
            duration: shortDuration, curve: customEasing);
      }
    } else {
      _minute2SC = FixedExtentScrollController(initialItem: minute2);
    }
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
      _updateScrollControllers();
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      _updateScrollControllers();
    });
  }

  Widget _weatherIcon(
      {BuildContext context,
      WeatherCondition weatherCondition,
      double iconWidth,
      double iconHeight}) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    String assetName;
    switch (weatherCondition) {
      case WeatherCondition.cloudy:
        if (isLightTheme) {
          assetName = "assets/images/day/cloudy.svg";
        } else {
          assetName = "assets/images/night/cloudy.svg";
        }
        break;
      case WeatherCondition.foggy:
        if (isLightTheme) {
          assetName = "assets/images/day/fog.svg";
        } else {
          assetName = "assets/images/night/fog.svg";
        }
        break;
      case WeatherCondition.rainy:
        if (isLightTheme) {
          assetName = "assets/images/day/rain.svg";
        } else {
          assetName = "assets/images/night/rain.svg";
        }
        break;
      case WeatherCondition.snowy:
        if (isLightTheme) {
          assetName = "assets/images/day/snow.svg";
        } else {
          assetName = "assets/images/night/snow.svg";
        }
        break;
      case WeatherCondition.sunny:
        if (isLightTheme) {
          assetName = "assets/images/day/sun.svg";
        } else {
          assetName = "assets/images/night/sun.svg";
        }
        break;
      case WeatherCondition.thunderstorm:
        if (isLightTheme) {
          assetName = "assets/images/day/storm.svg";
        } else {
          assetName = "assets/images/night/storm.svg";
        }
        break;
      case WeatherCondition.windy:
        if (isLightTheme) {
          assetName = "assets/images/day/windy.svg";
        } else {
          assetName = "assets/images/night/windy.svg";
        }
        break;
      case WeatherCondition.hail:
        if (isLightTheme) {
          assetName = "assets/images/day/hail.svg";
        } else {
          assetName = "assets/images/night/hail.svg";
        }
        break;
      case WeatherCondition.partly_cloudy:
        if (isLightTheme) {
          assetName = "assets/images/day/partly_cloudy.svg";
        } else {
          assetName = "assets/images/night/partly_cloudy.svg";
        }
        break;
      case WeatherCondition.clear_night:
        if (isLightTheme) {
          assetName = "assets/images/day/moon.svg";
        } else {
          assetName = "assets/images/night/moon.svg";
        }
        break;
    }
    return Container(
      child: SvgPicture.asset(
        assetName,
        width: iconWidth,
        height: iconHeight,
      ),
    );
  }

  Widget _renderGradient(
      {AlignmentGeometry gradientBegin,
      AlignmentGeometry gradientEnd,
      List<Color> colors}) {
    return Container(
      height: 57.0,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: gradientBegin,
              end: gradientEnd,
              colors: colors,
              tileMode: TileMode.repeated)),
    );
  }

  Widget _renderClockColumn(
      {BuildContext context,
      double itemExtent,
      double screenWidth,
      List<int> content,
      ScrollController scrollController}) {
    final scrollViewContainerWidth = screenWidth * 0.175;

    return Container(
      width: scrollViewContainerWidth,
      child: ListWheelScrollView(
        clipToSize: true,
        controller: scrollController,
        physics: NeverScrollableScrollPhysics(),
        itemExtent: itemExtent,
        useMagnifier: false,
        diameterRatio: itemExtent,
        children: <Widget>[
          ...content.map((i) {
            return Center(
              child: Text(i.toString()),
            );
          })
        ],
      ),
    );
  }

  Widget _renderWeatherView(
      {double screenHeight, double screenWidth, TextStyle textStyle}) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _weatherIcon(
            context: context,
            weatherCondition: widget.model.weatherCondition,
            iconWidth: screenWidth * 0.08,
            iconHeight: screenHeight * 0.08,
          ),
          SizedBox(
            height: screenHeight * 0.0067,
          ),
          Text(
            widget.model.temperatureString,
            style: textStyle,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    return LayoutBuilder(
      // Getting constraints of the 5:3 box from the clock customizer
      // Font size, clock column width are all calculate based on
      // constraints of that box
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final containerHeight = constraints.maxHeight;
        final fontSize = containerHeight * 0.48;
        final defaultStyle = TextStyle(
            color: colors[_Element.text],
            fontFamily: 'SpaceGrotesk',
            fontSize: fontSize);

        return Stack(
          children: <Widget>[
            Container(
              color: colors[_Element.background],
              child: DefaultTextStyle(
                style: defaultStyle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _renderClockColumn(
                        context: context,
                        itemExtent: fontSize,
                        screenWidth: containerWidth,
                        content: List.generate(3, (i) {
                          return i;
                        }),
                        scrollController: _hour1SC), // Hour 1
                    _renderClockColumn(
                        context: context,
                        itemExtent: fontSize,
                        screenWidth: containerWidth,
                        content: List.generate(10, (i) {
                          return i;
                        }),
                        scrollController: _hour2SC), // Hour 2
                    SizedBox(
                      width: containerWidth * 0.026,
                    ),
                    _renderClockColumn(
                        context: context,
                        itemExtent: fontSize,
                        screenWidth: containerWidth,
                        content: List.generate(6, (i) {
                          return i;
                        }),
                        scrollController: _minute1SC), // Minute 1
                    _renderClockColumn(
                        context: context,
                        itemExtent: fontSize,
                        screenWidth: containerWidth,
                        content: List.generate(10, (i) {
                          return i;
                        }),
                        scrollController: _minute2SC), // Minute 2
                    SizedBox(
                      width: containerWidth * 0.03,
                    ),
                    _renderWeatherView(
                        screenHeight: containerHeight,
                        screenWidth: containerWidth,
                        textStyle: defaultStyle.copyWith(
                            fontSize: containerHeight * 0.08)), // Weather
                    SizedBox(
                      width: containerWidth * 0.03,
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _renderGradient(
                  gradientBegin: Alignment.topCenter,
                  gradientEnd: Alignment.bottomCenter,
                  colors: [
                    colors[_Element.gradientBegin],
                    colors[_Element.gradientEnd]
                  ]),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _renderGradient(
                  gradientBegin: Alignment.bottomCenter,
                  gradientEnd: Alignment.topCenter,
                  colors: [
                    colors[_Element.gradientBegin],
                    colors[_Element.gradientEnd]
                  ]),
            ),
          ],
        );
      },
    );
  }
}
