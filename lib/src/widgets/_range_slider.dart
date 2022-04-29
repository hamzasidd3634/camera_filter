import 'package:flutter/material.dart';

///
class RangedSlider extends StatelessWidget {
  ///Range Slider widget for strokeWidth
  const RangedSlider({Key? key, this.value, this.onChanged}) : super(key: key);

  ///Default value of strokewidth.
  final double? value;

  /// Callback for value change.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Slider.adaptive(
      max: 40,
      min: 2,
      divisions: 19,
      value: value!,
      onChanged: onChanged,
    );
  }
}

///
class FontRangedSlider extends StatelessWidget {
  ///Range Slider widget for strokeWidth
  const FontRangedSlider({Key? key, this.value, this.onChanged})
      : super(key: key);

  ///Default value of strokewidth.
  final double? value;

  /// Callback for value change.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Slider.adaptive(
      max: 100,
      min: 28,
      divisions: 19,
      value: value!,
      onChanged: onChanged,
    );
  }
}
