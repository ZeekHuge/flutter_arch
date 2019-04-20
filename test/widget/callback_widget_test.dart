import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:splash_on_flutter/widget/callback_widget.dart';

import '../helper.dart';

class MockCallbackCaller extends Mock implements CallbackWidgetCaller<Object> {}

void main () {
	group('Test registeration on lifecycle : ', () {

		MockCallbackCaller _mockCallbackWidgetCaller;

		setUp(() {
			_mockCallbackWidgetCaller = MockCallbackCaller();
		});

		tearDown(() {
			// when the lifecycle of the SUT widget ends, it should be unregistered
			verify(_mockCallbackWidgetCaller.unregister(any));

			verifyNoMoreInteractions(_mockCallbackWidgetCaller);
			_mockCallbackWidgetCaller = null;
		});

		testWidgets('when widget alive/dead : should register/unregister on caller', (WidgetTester tester) async {
			/* set mocks and other */
			var sutCallbackWidget = CallbackWidget<Object>(
				child: ConstWidget.TEXT_WIDGET,
				callbackImplementationGetter: (context) => Object(),
				callbackCaller: _mockCallbackWidgetCaller
			);

			/* actually test */
			await tester.pumpWidget(sutCallbackWidget);

			/* assert and verify */
			verify(_mockCallbackWidgetCaller.register(any));
		});

	});

	testWidgets('when redrawing widget : child widget should appear', (WidgetTester tester) async {
		/* set mocks and other */

		var sutCallbackWidget = CallbackWidget<Object>(
			child: ConstWidget.TEXT_WIDGET,
			callbackImplementationGetter: (context) => Object(),
			callbackCaller: MockCallbackCaller(),
		);

		/* actually test */
		await tester.pumpWidget(sutCallbackWidget);


		/* assert and verify */
		tester.ensureVisible(find.byKey(ConstWidget.TEXT_WIDGET_KEY));
	});
}
