int _crc32Byte(int crc, int byte) {
  for (var i = 0; i < 8; ++i) {
    final tmp = crc;
    crc <<= 1;
    if ((byte & 0x80) == 0x80) crc |= 1;
    if ((tmp & 0x80000000) == 0x80000000) crc ^= 0x4C11DB7;
    byte <<= 1;
  }
  return crc & 0xFFFFFFFF;
}

int crc32<T extends List>(T bytes) {
  int crc = bytes.fold(0xFFFFFFFF, (previousValue, element) {
    return _crc32Byte(previousValue, element);
  });
  final List<int> zeros = [0, 0, 0, 0];
  return zeros.fold(crc, (previousValue, element) {
    return _crc32Byte(previousValue, element);
  });
}
