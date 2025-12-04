import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    this.currentDate,
    this.emptyValidationText,
    this.incompleteValidationText,
    this.onDateChanged,
  });

  final DateTime? currentDate;
  final String? emptyValidationText;
  final String? incompleteValidationText;
  final ValueChanged<DateTime?>? onDateChanged;

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late final TextEditingController _dayController;
  late final TextEditingController _monthController;
  late final TextEditingController _yearController;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _date = widget.currentDate;
    _dayController = TextEditingController(
      text: _date != null ? _date!.day.toString().padLeft(2, '0') : '',
    );
    _monthController = TextEditingController(
      text: _date != null ? _date!.month.toString().padLeft(2, '0') : '',
    );
    _yearController = TextEditingController(
      text: _date != null ? _date!.year.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update if the parent passes a different date
    if (widget.currentDate == oldWidget.currentDate) return;

    _date = widget.currentDate;

    // Defer text updates so they do not coincide with the build of the TextFormFields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_date != null) {
        final dayText = _date!.day.toString().padLeft(2, '0');
        final monthText = _date!.month.toString().padLeft(2, '0');
        final yearText = _date!.year.toString();

        // Only set if dates are different to avoid unnecessary notifications
        if (_dayController.text != dayText) {
          _dayController.text = dayText;
        }
        if (_monthController.text != monthText) {
          _monthController.text = monthText;
        }
        if (_yearController.text != yearText) {
          _yearController.text = yearText;
        }
      } else {
        _dayController.text = '';
        _monthController.text = '';
        _yearController.text = '';
      }
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  DateTime? _tryBuildingDateFromFields() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);

    if (day == null || month == null || year == null) {
      return null;
    }

    // Sanity checks
    if (year < 1900) return null;

    final now = DateTime.now();
    if (year > now.year) return null;

    try {
      final dateCandidate = DateTime(year, month, day);
      if (dateCandidate.year == year &&
          dateCandidate.month == month &&
          dateCandidate.day == day &&
          !dateCandidate.isAfter(now)) {
        return dateCandidate;
      }
    } catch (_) {
      logger.w(
        'Could not correctly build date from form fields, values are DD = $day, MM = $month, YYYY = $year',
      );
      return null;
    }

    return null;
  }

  String? _validateDateFields() {
    final dayText = _dayController.text.trim();
    final monthText = _monthController.text.trim();
    final yearText = _yearController.text.trim();

    if (dayText.isEmpty && monthText.isEmpty && yearText.isEmpty) {
      return widget.emptyValidationText ?? 'Date is required';
    }

    if (dayText.isEmpty || monthText.isEmpty || yearText.isEmpty) {
      return widget.incompleteValidationText ??
          'Please fill out all date fields';
    }

    if (int.tryParse(dayText) == null ||
        int.tryParse(monthText) == null ||
        int.tryParse(yearText) == null) {
      return 'Please enter digits only (0-9)';
    }

    final date = _tryBuildingDateFromFields();
    if (date == null) {
      return 'Please enter a valid date';
    }

    // Date looks good
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: (_) => _validateDateFields(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        final theme = Theme.of(context);
        final t = theme.textTheme;
        final inputTextColor = theme.colorScheme.inverseSurface;
        final errorText = field.errorText;

        final Color enabledborderColor = field.hasError
            ? theme.colorScheme.error
            : theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
                  theme.colorScheme.outline;
        final Color focusedBorderColor = field.hasError
            ? theme.colorScheme.error
            : theme.colorScheme.primary;
        OutlineInputBorder border(Color color) =>
            OutlineInputBorder(borderSide: BorderSide(color: color));
        InputDecoration datePickerDecoration(String hint) => InputDecoration(
          hintText: hint,
          border: border(enabledborderColor),
          enabledBorder: border(enabledborderColor),
          focusedBorder: border(focusedBorderColor),
        );

        void onAnyFieldChanged(String _) {
          final date = _tryBuildingDateFromFields();
          setState(() {
            _date = date;
          });
          field.didChange(date);
          widget.onDateChanged?.call(date);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date of Birth',
              style: t.bodyMedium!.copyWith(color: inputTextColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    decoration: datePickerDecoration('DD'),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    maxLength: 2,
                    buildCounter:
                        (
                          _, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) => const SizedBox.shrink(),
                    style: TextStyle(color: inputTextColor),
                    onChanged: onAnyFieldChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _monthController,
                    keyboardType: TextInputType.number,
                    decoration: datePickerDecoration('MM'),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 2,
                    buildCounter:
                        (
                          _, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) => const SizedBox.shrink(),
                    style: TextStyle(color: inputTextColor),
                    onChanged: onAnyFieldChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: datePickerDecoration('YYYY'),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    maxLength: 4,
                    buildCounter:
                        (
                          _, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) => const SizedBox.shrink(),
                    style: TextStyle(color: inputTextColor),
                    onChanged: onAnyFieldChanged,
                  ),
                ),
              ],
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  errorText,
                  style: t.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
