import 'package:http/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client.g.dart';

// Singleton http client (this is a huge improvement on desktop)
@Riverpod(keepAlive: true)
Client httpClient(_) => Client();
