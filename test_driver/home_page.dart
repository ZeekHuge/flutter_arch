
import 'package:flutter_driver/flutter_driver.dart';
import 'package:splash_on_flutter/app_constants.dart';
import 'package:test/test.dart';


class HomePageTests {
	static void groupTest () {

		FlutterDriver _driver;

		var _addFinder = find.byValueKey(WidgetKey.HOMEPAGE_FAB_ADD_ICON);
		var _progressFinder = find.byValueKey(WidgetKey.HOMEPAGE_FAB_PROGRESS);
		var _msgFinder = find.byValueKey(WidgetKey.HOMEPAGE_MSG_TEXT);
		var _countTextFinder = find.byValueKey(WidgetKey.HOMEPAGE_CLICK_TEXT);

		setUpAll(() async {
			_driver = await FlutterDriver.connect();
		});

		tearDownAll(() {
			if (_driver != null)
				_driver.close();
		});

		int _getCountFromCountMessage(String countMessage) {
			String numberString = countMessage.substring(countMessage.indexOf(RegExp(r'[0-9]')));
			int expectedCount = int.parse(numberString);
			return expectedCount;
		}


		test('initial layout check', () async {
			// set mocks and other
			var currentCount = _getCountFromCountMessage(await _driver.getText(_countTextFinder));

			// actually test

			// assert and verify
			expect(
				await _driver.getText(_countTextFinder),
				UIStrings.HOMEPAGE_COUNT_MSG_PREFIX + ' $currentCount'
			);
			String msgText = await _driver.getText(_msgFinder);
			if (currentCount == 0)
				expect(msgText, UIStrings.HOMEPAGE_INITIAL_ADVICE);
			else {
				expect(msgText, isNot(UIStrings.HOMEPAGE_INITIAL_ADVICE));
				expect(msgText, isNotNull);
			}
		});
	}
}