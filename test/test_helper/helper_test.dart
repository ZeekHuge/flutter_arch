import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helper.dart';



Future<void> fn () {
	var c = Completer();
	var e = new TimeoutException('intentional error');
	c.completeError(e);
	return c.future;
//	throw e;
}

void main () {
	group('Test ChangeListener class : ', () {

		test('if value does not change : Future should not complete', () async {
			/* set mocks and other */
			ValueNotifier<String> valueNotifier = new ValueNotifier('String');

			/* actually test */
			var changeListener = ChangeListener(valueNotifier, 1);

			/* assert and verify */
			expect(
				changeListener.waitForChange().timeout(Duration(microseconds: 10)),
				throwsA(isInstanceOf<TimeoutException>())
			);
		});

		test('if value changes n time : future should complete only afte n times', () async {
			/* set mocks and other */
			var valueNotifier0 = new ValueNotifier('String');
			var valueNotifier1 = new ValueNotifier('String');
			var valueNotifier2 = new ValueNotifier('String');

			/* actually test */
			var changeListener0 = ChangeListener(valueNotifier0, 0);
			var changeListener1 = ChangeListener(valueNotifier1, 1);
			var changeListener2 = ChangeListener(valueNotifier2, 2);

			valueNotifier1.notifyListeners();

			valueNotifier2.notifyListeners();
			valueNotifier2.notifyListeners();

			/* assert and verify */
			changeListener0.waitForChange().timeout(Duration(microseconds: 10));
			changeListener1.waitForChange().timeout(Duration(microseconds: 10));
			changeListener2.waitForChange().timeout(Duration(microseconds: 10));
		});


		test('if value change more than required times : Complete future with exception', () {
			/* set mocks and other */
			var valueNotifier0 = new ValueNotifier('String');
			var valueNotifier1 = new ValueNotifier('String');

			/* actually test */
			var changeListener0 = ChangeListener(valueNotifier0, 0);
			var changeListener1 = ChangeListener(valueNotifier1, 1);

			valueNotifier0.notifyListeners();

			valueNotifier1.notifyListeners();
			valueNotifier1.notifyListeners();

			/* assert and verify */
			expect(changeListener0.waitForChange(), throwsA(isInstanceOf<Exception>()));
			expect(changeListener1.waitForChange(), throwsA(isInstanceOf<Exception>()));
		});
	});
}