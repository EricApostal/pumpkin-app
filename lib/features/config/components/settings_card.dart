import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/config/models/config.dart';
import 'package:pumpkin_app/theme/theme.dart';

class SettingCard extends ConsumerStatefulWidget {
  final ConfigSetting setting;
  final String currentValue;
  final Function(dynamic) onValueChanged;
  final Map<String, List<String>>? dropdownOptions;

  const SettingCard({
    super.key,
    required this.setting,
    required this.currentValue,
    required this.onValueChanged,
    this.dropdownOptions,
  });

  @override
  ConsumerState<SettingCard> createState() => _SettingCardState();
}

class _SettingCardState extends ConsumerState<SettingCard> {
  late dynamic currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = _parseInitialValue();
    widget.onValueChanged(currentValue);
  }

  dynamic _parseInitialValue() {
    if (widget.currentValue.isEmpty) {
      return widget.setting.defaultValue ??
          _getDefaultForType(widget.setting.inputType);
    }

    switch (widget.setting.inputType) {
      case ConfigInputType.number:
      case ConfigInputType.slider:
        final parsedValue = double.tryParse(widget.currentValue)?.toInt();
        if (parsedValue != null) {
          if (widget.setting.constraints != null) {
            final min = widget.setting.constraints!['min'] as num?;
            final max = widget.setting.constraints!['max'] as num?;
            if (min != null && parsedValue < min) return min.toInt();
            if (max != null && parsedValue > max) return max.toInt();
          }
          return parsedValue;
        }
        return widget.setting.defaultValue ?? 0;

      case ConfigInputType.toggle:
        final value = widget.currentValue.toLowerCase();
        if (value == 'true' ||
            value == '1' ||
            value == 'yes' ||
            value == 'on') {
          return true;
        }
        if (value == 'false' ||
            value == '0' ||
            value == 'no' ||
            value == 'off') {
          return false;
        }
        return widget.setting.defaultValue ?? false;

      case ConfigInputType.dropdown:
        final List<String> options =
            (widget.dropdownOptions?[widget.setting.key] ??
                widget.setting.constraints?['options'] ??
                <String>[]) as List<String>;

        if (options.isEmpty) {
          return widget.currentValue;
        }

        try {
          return options.firstWhere(
            (option) =>
                option.toLowerCase() == widget.currentValue.toLowerCase(),
            orElse: () {
              if (widget.setting.defaultValue != null) {
                final defaultMatch = options.firstWhere(
                  (option) =>
                      option.toLowerCase() ==
                      widget.setting.defaultValue.toString().toLowerCase(),
                  orElse: () => options.first,
                );
                return defaultMatch;
              }
              return options.first;
            },
          );
        } catch (e) {
          return options.first;
        }

      case ConfigInputType.list:
        try {
          if (widget.currentValue.startsWith('[') &&
              widget.currentValue.endsWith(']')) {
            final listStr = widget.currentValue
                .substring(1, widget.currentValue.length - 1);

            if (listStr.trim().isEmpty) {
              return widget.setting.defaultValue ?? <String>[];
            }

            return listStr
                .split(',')
                .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ""))
                .where((e) => e.isNotEmpty)
                .toList();
          }

          if (widget.currentValue.isNotEmpty) {
            return [widget.currentValue];
          }

          return widget.setting.defaultValue ?? <String>[];
        } catch (e) {
          return widget.setting.defaultValue ?? <String>[];
        }

      case ConfigInputType.text:
        return widget.currentValue.isNotEmpty
            ? widget.currentValue
            : widget.setting.defaultValue ?? '';
    }
  }

  dynamic _getDefaultForType(ConfigInputType type) {
    switch (type) {
      case ConfigInputType.number:
      case ConfigInputType.slider:
        return 0;
      case ConfigInputType.toggle:
        return false;
      case ConfigInputType.list:
        return <String>[];
      case ConfigInputType.text:
      case ConfigInputType.dropdown:
        return '';
    }
  }

  Widget _buildTextField() {
    return TextFormField(
      initialValue: currentValue.toString(),
      decoration: _getInputDecoration(),
      onChanged: (value) {
        setState(() => currentValue = value);
        widget.onValueChanged(value);
      },
    );
  }

  Widget _buildNumberField() {
    return TextFormField(
      initialValue: currentValue.toString(),
      keyboardType: TextInputType.number,
      decoration: _getInputDecoration(),
      onChanged: (value) {
        final numValue = double.tryParse(value)?.toInt() ?? currentValue;
        setState(() => currentValue = numValue);
        widget.onValueChanged(numValue);
      },
    );
  }

  Widget _buildSlider() {
    final min = (widget.setting.constraints?['min'] ?? 0).toDouble();
    final max = (widget.setting.constraints?['max'] ?? 100).toDouble();
    final divisions =
        (widget.setting.constraints?['divisions'] ?? (max - min).toInt())
            .toInt();

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            thumbColor: Theme.of(context).custom.colorTheme.primary,
            activeTrackColor: Theme.of(context).custom.colorTheme.primary,
            inactiveTrackColor: Theme.of(context).custom.colorTheme.background,
            activeTickMarkColor: Theme.of(context).custom.colorTheme.primary,
            overlayColor:
                Theme.of(context).custom.colorTheme.primary.withOpacity(0.3),
            valueIndicatorColor: Theme.of(context).custom.colorTheme.primary,
            valueIndicatorTextStyle: GoogleFonts.publicSans(
              color: Theme.of(context).custom.colorTheme.dirtywhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Slider(
            value: currentValue.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            label: currentValue.round().toString(),
            onChanged: (value) {
              setState(() => currentValue = value.toInt());
              widget.onValueChanged(value.toInt());
            },
          ),
        ),
        Text(
          currentValue.round().toString(),
          style: GoogleFonts.publicSans(
            color: Theme.of(context).custom.colorTheme.dirtywhite,
          ),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            currentValue ? 'Enabled' : 'Disabled',
            style: GoogleFonts.publicSans(
              color: Theme.of(context).custom.colorTheme.dirtywhite,
            ),
          ),
        ),
        Switch(
          activeColor: Theme.of(context).custom.colorTheme.primary,
          value: currentValue,
          onChanged: (value) {
            setState(() => currentValue = value);
            widget.onValueChanged(value);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    final List<String> options = (widget.dropdownOptions?[widget.setting.key] ??
        widget.setting.constraints?['options'] ??
        <String>[]) as List<String>;

    final List<DropdownMenuItem<String>> dropdownItems =
        options.map((String option) {
      return DropdownMenuItem<String>(
        value: option,
        child: Text(
          option,
          style: GoogleFonts.publicSans(
            color: Theme.of(context).custom.colorTheme.dirtywhite,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }).toList();

    return DropdownButtonFormField<String>(
      value: currentValue as String,
      decoration: _getInputDecoration(),
      items: dropdownItems,
      onChanged: (value) {
        if (value != null) {
          setState(() => currentValue = value);
          widget.onValueChanged(value);
        }
      },
      dropdownColor: Theme.of(context).custom.colorTheme.background,
      style: GoogleFonts.publicSans(
        color: Theme.of(context).custom.colorTheme.dirtywhite,
      ),
    );
  }

  Widget _buildListInput() {
    return Column(
      children: [
        ...currentValue.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: value.toString(),
                    decoration: _getInputDecoration().copyWith(
                      hintText: 'Enter item ${index + 1}',
                    ),
                    onChanged: (newValue) {
                      final newList = List<String>.from(currentValue);
                      newList[index] = newValue;
                      setState(() => currentValue = newList);
                      widget.onValueChanged(newList);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Theme.of(context).custom.colorTheme.primary,
                  ),
                  onPressed: () {
                    final newList = List<String>.from(currentValue)
                      ..removeAt(index);
                    setState(() => currentValue = newList);
                    widget.onValueChanged(newList);
                  },
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(
            'Add Item',
            style: GoogleFonts.publicSans(),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).custom.colorTheme.primary,
            foregroundColor: Theme.of(context).custom.colorTheme.dirtywhite,
          ),
          onPressed: () {
            final newList = List<String>.from(currentValue)..add('');
            setState(() => currentValue = newList);
            widget.onValueChanged(newList);
          },
        ),
      ],
    );
  }

  Widget _buildInput() {
    switch (widget.setting.inputType) {
      case ConfigInputType.text:
        return _buildTextField();
      case ConfigInputType.number:
        return _buildNumberField();
      case ConfigInputType.slider:
        return _buildSlider();
      case ConfigInputType.toggle:
        return _buildToggle();
      case ConfigInputType.dropdown:
        return _buildDropdown();
      case ConfigInputType.list:
        return _buildListInput();
    }
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).custom.colorTheme.primary,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).custom.colorTheme.foreground,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.setting.displayName,
              style: GoogleFonts.publicSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).custom.colorTheme.dirtywhite,
              ),
            ),
            const SizedBox(height: 12),
            _buildInput(),
          ],
        ),
      ),
    );
  }
}
