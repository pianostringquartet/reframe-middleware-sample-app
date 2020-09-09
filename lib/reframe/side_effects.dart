import 'package:http/http.dart';
import 'package:meta/meta.dart';

/* 'Effects' are side-effects' dependencies, e.g. client,
 which we might want to change in various circumstances
 (e.g. production vs. local vs. test)*/
class Effects {
  final Client client;

  const Effects({
    @required this.client,
  });
}