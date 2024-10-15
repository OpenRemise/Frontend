String? cvValueValidator(String? value) {
  if (value == null || value.isEmpty) return 'Please enter a CV value';
  final cvValue = int.tryParse(value);
  if (cvValue == null) return 'Value invalid';
  if (cvValue > 255) return 'Value out of range';
  return null;
}
