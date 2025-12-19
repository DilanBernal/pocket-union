import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InputWithButton extends StatefulWidget {
  final Function(Map<String, String>) onSend;
  final List<String> fieldNames;
  final List<TextInputType>? keyboardTypes;
  final List<List<TextInputFormatter>>? inputFormatters;
  final String buttonName;
  final Map<String, List<String>>? dropdownOptions;
  final Map<String, String>? initialDropdownValues;
  final Map<String, Map<String, IconData>>? dropdownIcons;
  final Map<String, Map<String, int>>? dropdownElementIdNumber;
  final Map<String, Map<String, String>>? dropdownElementString;

  const InputWithButton(
      {super.key,
      required this.onSend,
      required this.fieldNames,
      required this.buttonName,
      this.keyboardTypes,
      this.inputFormatters,
      this.dropdownOptions,
      this.initialDropdownValues,
      this.dropdownIcons,
      this.dropdownElementIdNumber,
      this.dropdownElementString});

  @override
  _InputWithButtonState createState() => _InputWithButtonState();
}

class _InputWithButtonState extends State<InputWithButton> {
  late List<TextEditingController> _controllers;
  late Map<String, String> _capturedValues;
  late Map<String, String?> _dropdownValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.fieldNames.length,
      (index) => TextEditingController(),
    );
    _capturedValues = {for (var name in widget.fieldNames) name: ''};
    _dropdownValues = {};
    if (widget.dropdownOptions != null) {
      for (var field in widget.dropdownOptions!.keys) {
        _dropdownValues[field] = widget.initialDropdownValues?[field];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(widget.fieldNames.length, (index) {
            final fieldName = widget.fieldNames[index];
            bool isDateField = widget.keyboardTypes != null &&
                widget.keyboardTypes!.length > index &&
                widget.keyboardTypes![index] == TextInputType.datetime;
            bool isDropdownField =
                widget.dropdownOptions?.containsKey(fieldName) ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: isDropdownField
                  ? _buildDropdownField(fieldName)
                  : isDateField
                      ? _buildDateField(context, index)
                      : _buildTextField(index),
            );
          }),
          CupertinoButton(
            onPressed: () {
              final values = {
                for (int i = 0; i < widget.fieldNames.length; i++)
                  widget.fieldNames[i]: widget.dropdownOptions
                              ?.containsKey(widget.fieldNames[i]) ??
                          false
                      ? _dropdownValues[widget.fieldNames[i]] ?? ''
                      : _controllers[i].text
              };
              setState(() {
                _capturedValues = values;
              });
              widget.onSend(_capturedValues);
            },
            color: CupertinoColors.systemPink,
            child: Text(
              widget.buttonName,
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(int index) {
    return CupertinoTextField(
      controller: _controllers[index],
      keyboardType:
          widget.keyboardTypes != null && widget.keyboardTypes!.length > index
              ? widget.keyboardTypes![index]
              : TextInputType.text,
      inputFormatters: widget.inputFormatters != null &&
              widget.inputFormatters!.length > index
          ? widget.inputFormatters![index]
          : null,
      placeholder: 'Ingresa el ${widget.fieldNames[index]}',
      padding: EdgeInsets.all(12),
      style: TextStyle(color: CupertinoColors.lightBackgroundGray),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemBlue),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, int index) {
    return TextField(
      controller: _controllers[index],
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Selecciona ${widget.fieldNames[index]}',
        prefixIcon: Icon(
          Icons.calendar_today,
          color: CupertinoColors.systemBlue,
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CupertinoColors.systemBlue),
            borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CupertinoColors.activeBlue)),
        contentPadding: EdgeInsets.all(12),
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          setState(() {
            _controllers[index].text = formattedDate;
          });
        }
      },
    );
  }

  Widget _buildDropdownField(String fieldName) {
    final List<String> options = widget.dropdownOptions?[fieldName] ?? [];

    final Map<String, IconData>? iconsForField =
        widget.dropdownIcons?[fieldName];
    final Map<String, String> optionIds = widget.dropdownElementString![fieldName]!;
    return DropdownButtonFormField<String>(
      initialValue: _dropdownValues[fieldName],
      decoration: InputDecoration(
          labelText: fieldName,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CupertinoColors.systemBlue),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CupertinoColors.systemBlue),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4)))),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: optionIds[option].toString(),
          child: iconsForField != null && iconsForField.containsKey(option)
              ? Row(
                  children: [
                    Icon(
                      iconsForField[option],
                      color: CupertinoColors.systemPurple,
                    ),
                    const SizedBox(width: 10),
                    Text(option),
                  ],
                )
              : Text((option)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _dropdownValues[fieldName] = newValue;
        });
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
