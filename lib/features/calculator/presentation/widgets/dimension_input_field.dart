import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Dimension input field with suffix unit label and ergonomic quick step controls.
///
/// Designed for ultra-fast one-handed mobile and desktop input.
class DimensionInputField extends StatefulWidget {
  final String label;
  final String suffix;
  final bool isInteger;
  final String? initialValue;
  final ValueChanged<double> onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final double step;
  final bool showStepButtons;

  const DimensionInputField({
    super.key,
    required this.label,
    required this.suffix,
    this.isInteger = false,
    this.initialValue,
    required this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.step = 10.0,
    this.showStepButtons = false,
  });

  @override
  State<DimensionInputField> createState() => _DimensionInputFieldState();
}

class _DimensionInputFieldState extends State<DimensionInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && _controller.text.isNotEmpty) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  @override
  void didUpdateWidget(DimensionInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      final newVal = widget.initialValue ?? '';
      if (_controller.text != newVal) {
        _controller.text = newVal;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _stepValue(double delta) {
    AppHaptics.light();
    final current = double.tryParse(_controller.text) ?? 0.0;
    final next = (current + delta).clamp(0.0, 999999.0);
    final text = widget.isInteger ? next.toInt().toString() : (next == next.toInt() ? next.toInt().toString() : next.toStringAsFixed(1));
    _controller.text = text;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          onFieldSubmitted: widget.onFieldSubmitted,
          onTap: () {
            if (_controller.text.isNotEmpty) {
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controller.text.length,
              );
            }
          },
          keyboardType: TextInputType.numberWithOptions(
            decimal: !widget.isInteger,
            signed: false,
          ),
          inputFormatters: [
            if (widget.isInteger)
              FilteringTextInputFormatter.digitsOnly
            else
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: InputDecoration(
            labelText: widget.label,
            suffixText: widget.suffix.isNotEmpty ? widget.suffix : null,
            suffixStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              fontSize: 13,
            ),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: widget.showStepButtons
                ? IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                    tooltip: 'إنقاص',
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    onPressed: () => _stepValue(-widget.step),
                  )
                : null,
          ),
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null) {
              widget.onChanged(parsed);
            } else if (value.isEmpty) {
              widget.onChanged(0);
            }
          },
        ),
      ],
    );
  }
}
