int exor<T extends List>(T bytes) {
  return bytes.fold(0, (previousValue, element) {
    return previousValue ^ element;
  });
}
