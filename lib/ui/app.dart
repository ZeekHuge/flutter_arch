import 'package:flutter/cupertino.dart';

class MyApp extends StatelessWidget {
	final StatelessWidget _childWidget;

	MyApp(this._childWidget);

	@override
	Widget build(BuildContext context) {
		return this._childWidget;
	}
}
