
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter/widgets.dart';
import 'package:splash_on_flutter/ui/base_widget.dart';


void main() {
  enableFlutterDriverExtension();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return BaseWidget();
	}
}

