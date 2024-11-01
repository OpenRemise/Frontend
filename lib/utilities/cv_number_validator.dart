String? cvNumberValidator(String? value) {
  if (value == null || value.isEmpty) return 'Please enter a CV number';
  final number = int.tryParse(value);
  if (number == null) return 'Number invalid';
  if (number < 1 || number > 1024) {
    return 'Number out of range';
  }
  return null;
}
