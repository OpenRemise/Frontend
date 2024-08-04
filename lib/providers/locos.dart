import 'package:Frontend/models/loco.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locos.g.dart';

@Riverpod(keepAlive: true)
class Locos extends _$Locos {
  @override
  List<Loco> build() {
    return const String.fromEnvironment('FAKE_SERVICES') == 'true'
        ? [
            Loco(address: 42, name: 'BR 85'),
            Loco(address: 3, name: 'Vectron'),
            Loco(address: 100, name: 'BR 247'),
            Loco(address: 1337, name: 'Reihe 498'),
            Loco(address: 14, name: 'BR 248'),
            Loco(address: 130, name: 'Mh6'),
            Loco(address: 98, name: 'L45H'),
            Loco(address: 6, name: 'E2'),
            Loco(address: 75, name: 'Litra F'),
            Loco(address: 1400, name: 'Reihe 5022'),
            Loco(address: 10, name: 'V 36'),
            Loco(address: 167, name: 'BR E 77'),
            Loco(address: 2811, name: 'ASF EL 16'),
            Loco(address: 208, name: 'Gruppo 740'),
            Loco(address: 2, name: 'ET22'),
            Loco(address: 49, name: 'ST44'),
            Loco(address: 330, name: 'Rad 710'),
            Loco(address: 726, name: 'Gem 4/4'),
          ]
        : List.empty();
  }

  void updateLocos(List<Loco> locos) {
    state = locos;
  }

  void updateLoco(int address, Loco loco) {
    final index =
        state.indexWhere((previousLoco) => previousLoco.address == address);
    // Update
    if (index >= 0) {
      state = [
        for (var i = 0; i < state.length; ++i)
          if (i == index) loco else state[i],
      ];
    }
    // Create
    else {
      state = [...state, loco];
    }
  }

  void deleteLocos() {
    // DELETE /locos/
    state = List.empty();
  }

  void deleteLoco(int address) {
    // DELETE /locos/$address
    state = [
      for (final loco in state)
        if (loco.address != address) loco,
    ];
  }
}
