
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:splash_on_flutter/app_constants.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';

import 'package:splash_on_flutter/model/home_page_model.dart';

import '../test_helper/helper.dart';



class MockAdviceReader extends Mock implements AdviceReader {}
class MockErrorHandler extends Mock implements ErrorHandler {}
class MockRandom extends Mock implements Random {}
class MockIOException extends Mock implements IOException {
	final String msg;
	MockIOException(this.msg);

	@override
	String toString() {
		return this.msg;
	}
}

void main () {

	group('Homepage model test', () {

		HomePageModel _sutHomePageModel;

		ErrorHandler _mockErrorHandler;
		AdviceReader _mockAdviceReader;
		Random _mockRandom;


		setUp(() {
			_mockErrorHandler = MockErrorHandler();
			_mockAdviceReader = MockAdviceReader();
			_mockRandom = MockRandom();
			_sutHomePageModel = new HomePageModel(_mockAdviceReader, _mockRandom);
		});


		tearDown(() {
			verifyNoMoreInteractions(_mockErrorHandler);
			verifyNoMoreInteractions(_mockRandom);
			verifyNoMoreInteractions(_mockAdviceReader);

			_mockErrorHandler = null;
			_mockAdviceReader = null;
			_mockRandom = null;
			_sutHomePageModel = null;
		});

		test('when change theme color : should change the theme_color property', () async {
			/* set mocks and other */
			var originalThemeColor = _sutHomePageModel.themeColor.value;
			when(_mockRandom.nextInt(any)).thenReturn(2);

			/* actually test */
			var colorChangeListener = ChangeListener(_sutHomePageModel.themeColor, 1);
			_sutHomePageModel.changeThemeColor();
			await colorChangeListener.waitForChange();

			/* assert and verify */
			expect(_sutHomePageModel.themeColor.value, isNot(originalThemeColor));
			verify(_mockRandom.nextInt(any));
		});


		test('When model started : should show initial values', () {
			/* set mocks and other */
			/* actually test */
			/* assert and verify */
			// fab state
			expect(_sutHomePageModel.fabState.isLoading, false);
			expect(_sutHomePageModel.fabState.isActive, true);
			// advice message state
			expect(_sutHomePageModel.adviceMessageState.isActive, true);
			expect(_sutHomePageModel.adviceMessageState.text, UIStrings.HOMEPAGE_INITIAL_ADVICE);
			// click message state
			expect(_sutHomePageModel.clickMessageState.isActive, true);
			expect(_sutHomePageModel.clickMessageState.text, UIStrings.HOMEPAGE_COUNT_MSG_PREFIX + ' 0');
		});


		test('when fetch new advice : if advice_reader fails with no handler : do nothing', () async {
			/* set mocks and other */
			when(_mockAdviceReader.getNewAdvice())
				.thenAnswer((invocation) => Future.error(Exception('Expected exception')));

			/* actually test */
			_sutHomePageModel.onIncrementClicked();
			await untilCalled(_mockAdviceReader.getNewAdvice())
				.timeout(ConstDuration.TenMilliSecond);

			/* assert and verify */
			verify(_mockAdviceReader.getNewAdvice());
		});


		test('when fetch new advice : if advice_reader fails with InternetNotConnected with handler : should handle for connection error', () async {
			/* set mocks and other */
			const EXPECTED_CAUSE = 'Expected cause';
			when(_mockAdviceReader.getNewAdvice())
				.thenAnswer((invocation) => Future.error(MockIOException(EXPECTED_CAUSE)));

			/* actually test */
			_sutHomePageModel.register(_mockErrorHandler);
			_sutHomePageModel.onIncrementClicked();
			await untilCalled(_mockErrorHandler.handleConnectionError(any))
				.timeout(ConstDuration.TenMilliSecond);

			/* assert and verify */
			verify(_mockAdviceReader.getNewAdvice());
			verify(_mockErrorHandler.handleConnectionError(any));
		});


		test('when fetch new advice : if advice_reader fails with non InternetNotConnected with hanlder : should handle for internal error', () async {
			/* set mocks and other */
			when(_mockAdviceReader.getNewAdvice())
				.thenAnswer((invocation) => Future.error(Exception('Intentional Exception')));

			/* actually test */
			_sutHomePageModel.register(_mockErrorHandler);
			_sutHomePageModel.onIncrementClicked();
			await untilCalled(_mockErrorHandler.handleInternalError(any))
				.timeout(ConstDuration.TenMilliSecond);

			/* assert and verify */
			verify(_mockAdviceReader.getNewAdvice());
			verify(_mockErrorHandler.handleInternalError(any));
		});


		test('when fetch new advice : if advice_reader works : should stop progress, activate buttons and text boxes and show advice', () async {
			/* set mocks and other */
			const EXPECTED_ADVICE = 'EXPECTED Advice';
			when(_mockAdviceReader.getNewAdvice())
				.thenAnswer((invocation) => Future.value(EXPECTED_ADVICE));

			/* actually test */
			var changeListener = ChangeListener(_sutHomePageModel.adviceMessageState, 2);
			_sutHomePageModel.onIncrementClicked();
			await changeListener.waitForChange();

			/* assert and verify */

			// button state change assert
			var buttonState = _sutHomePageModel.fabState.value;
			expect(true, buttonState.isActive);
			expect(false, buttonState.isLoading);

			// advice message state change assert
			var messageDisplayState = _sutHomePageModel.adviceMessageState.value;
			expect(true, messageDisplayState.isActive);
			expect(EXPECTED_ADVICE, messageDisplayState.text);

			// count message state change start
			var countMessageDisplayState = _sutHomePageModel.clickMessageState.value;
			expect(true, countMessageDisplayState.isActive);

			// verify calls
			verify(_mockAdviceReader.getNewAdvice());
		});

		group('test unregisteration of error handler : ', () {

			/** The 2 methods in this group need to be in sync **/

			MockErrorHandler _mockErrorHandler;

			setUp(() {
				when(_mockAdviceReader.getNewAdvice()).thenAnswer((invocation) => Future.error(Exception('excpetion')));
				_mockErrorHandler = new MockErrorHandler();
				_sutHomePageModel.register(_mockErrorHandler);
			});

			tearDown(() {
				verify(_mockAdviceReader.getNewAdvice());
				verifyNoMoreInteractions(_mockErrorHandler);
				_mockErrorHandler = null;
			});

			test('since the error_handler is registered : should be call_backed', () async {
				/* set mocks and other */
				/* actually test */
				_sutHomePageModel.onIncrementClicked();

				/* assert and verify */
				await untilCalled(_mockErrorHandler.handleInternalError(any));
				verify(_mockErrorHandler.handleInternalError(any));
			});

			test('unregister error_handler : should not be call_backed', () async {
				/* set mocks and other */

				/* actually test */
				_sutHomePageModel.unregister(_mockErrorHandler);
				_sutHomePageModel.onIncrementClicked();

				/* assert and verify */
				// wait for 100 microseconds, for if the other futures from error handle need to be completed
				await Future.delayed(const Duration(microseconds: 1));
			});
		});
	});
}