
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter/widgets.dart';
import 'package:splash_on_flutter/configuration.dart';


void main() {
    enableFlutterDriverExtension();
    runApp(AppConfiguration.getConfiguredApp());
}

