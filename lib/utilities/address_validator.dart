String? addressValidator(String? value) {
  if (value == null || value.isEmpty) return 'Please enter an address';
  final number = int.tryParse(value);
  if (number == null) {
    return 'Address invalid';
  } else if (number > 9999) {
    return 'Address out of range';
  } else {
    return null;
  }
}
