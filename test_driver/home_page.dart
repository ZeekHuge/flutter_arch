
import 'package:flutter_driver/flutter_driver.dart';
import 'package:splash_on_flutter/app_constants.dart';
import 'package:test/test.dart';


class HomePageTests {
	static void groupTest () {

		FlutterDriver _driver;

		var _addFinder = find.byValueKey(WidgetKey.HOMEPAGE_START_FETCH);
		var _progressFinder = find.byValueKey(WidgetKey.HOMEPAGE_PROGRESS_INDICATOR);
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


		test('when fab clicked: if db works: should progress > update > activate', () async {
			/* set mocks and other */

			final int EXPECTED_COUNT = _getCountFromCountMessage(await _driver.getText(_countTextFinder)) + 1;

			/* actually test */
			await _driver.tap(_addFinder);

			/* assert and verify */
			// check if we have progress bar
			// TODO : unable to really check the progress bar here, as it would result in timeout.
//			await _driver.waitFor(progressFinder);
			// wait for the progress bar to complete
			await _driver.waitForAbsent(_progressFinder);
			await _driver.waitFor(_addFinder);
			// check msg updates
			expect(
				await _driver.getText(_msgFinder),
				isNot(UIStrings.HOMEPAGE_INITIAL_ADVICE)
			);
			expect(
				await _driver.getText(_countTextFinder),
				UIStrings.HOMEPAGE_COUNT_MSG_PREFIX + ' $EXPECTED_COUNT'
			);
		});
	}
}