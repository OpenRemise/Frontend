import 'package:Frontend/providers/domain.dart';
import 'package:Frontend/services/fake_mdu_service.dart';
import 'package:Frontend/services/mdu_service.dart';
import 'package:Frontend/services/ws_mdu_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mdu_service.g.dart';

@riverpod
MduService mduService(ref) =>
    const String.fromEnvironment('FAKE_SERVICES') == 'true'
        ? FakeMduService()
        : WsMduService(ref.read(domainProvider));
