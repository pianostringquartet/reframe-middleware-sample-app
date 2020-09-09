import 'package:flutter/material.dart';
import 'package:flutter_reframe_sample_app/initialize_app.dart';
import 'package:http/http.dart';

void main() {
  runApp(initializeApp(client: Client()));
}
