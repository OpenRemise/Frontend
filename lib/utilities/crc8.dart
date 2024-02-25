int _crc8Byte(int byte) {
  int crc = 0;
  if (byte & 0x01 == 0x01) crc ^= 0x5E;
  if (byte & 0x02 == 0x02) crc ^= 0xBC;
  if (byte & 0x04 == 0x04) crc ^= 0x61;
  if (byte & 0x08 == 0x08) crc ^= 0xC2;
  if (byte & 0x10 == 0x10) crc ^= 0x9D;
  if (byte & 0x20 == 0x20) crc ^= 0x23;
  if (byte & 0x40 == 0x40) crc ^= 0x46;
  if (byte & 0x80 == 0x80) crc ^= 0x8C;
  return crc & 0xFF;
}

int crc8<T extends List>(T bytes) {
  return bytes.fold(0, (previousValue, element) {
    return _crc8Byte(previousValue ^ element);
  });
}
