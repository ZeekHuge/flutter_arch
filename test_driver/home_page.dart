
import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart' as FDriver;
import 'package:flutter_test/flutter_test.dart';

class HomePageTests {
	static void groupTest () {

		FDriver.FlutterDriver _driver;

		setUpAll(() async {
			_driver = await FDriver.FlutterDriver.connect();
		});

		tearDownAll(() {
			if (_driver != null)
				_driver.close();
		});

		test('initial layout check', () {
			var output = find.byIcon(Icon(Icons.add).icon);
			expect(output, findsOneWidget);
		});
	}
}