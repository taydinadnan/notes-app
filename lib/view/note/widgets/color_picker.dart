import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';

class ColorPicker extends StatefulWidget {
  final List<Color> colors;
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;

  const ColorPicker({
    Key? key,
    required this.colors,
    required this.selectedColorIndex,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  State createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: List.generate(widget.colors.length, (index) {
        final color = widget.colors[index];
        final isSelected = index == widget.selectedColorIndex;

        return GestureDetector(
          onTap: () {
            widget.onColorSelected(index);
          },
          child: Padding(
            padding: EdgeInsets.all(isSelected ? 0.0 : 2.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: isSelected ? 30 : 25, // Change width when selected
              height: isSelected ? 30 : 25, // Change height when selected
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: isSelected ? AppStyle.titleColor : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
