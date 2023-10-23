import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/view/note/widgets/color_picker.dart';

class ColorPickerCard extends StatefulWidget {
  final List<Color> colors;
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;

  const ColorPickerCard({
    Key? key,
    required this.colors,
    required this.selectedColorIndex,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  State createState() => _ColorPickerCardState();
}

class _ColorPickerCardState extends State<ColorPickerCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        color: AppStyle.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ColorPicker(
            colors: widget.colors,
            selectedColorIndex: widget.selectedColorIndex,
            onColorSelected: widget.onColorSelected,
          ),
        ),
      ),
    );
  }
}
