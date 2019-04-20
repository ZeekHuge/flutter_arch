
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:splash_on_flutter/app_constants.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';

import 'package:splash_on_flutter/db/dbModule.dart';
import 'package:splash_on_flutter/model/home_page_model.dart';

import 'helper.dart';

class MockOnlineDB extends Mock implements OnlineDB {}
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
		OnlineDB _mockOnlineDb;
		Random _mockRandom;


		setUp(() {
			_mockOnlineDb = MockOnlineDB();
			_mockRandom = MockRandom();
			_sutHomePageModel = new HomePageModel(new AdviceReader(_mockOnlineDb), _mockRandom);
		});


		tearDown(() {
			verifyNoMoreInteractions(_mockRandom);
			verifyNoMoreInteractions(_mockOnlineDb);

			_mockOnlineDb = null;
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


		test('when fetch new advice : if DB works : should update advice text', () async {
			/* set mocks and other */
			const EXPECTED_ADVICE = 'advice';
			when(_mockOnlineDb.getNewAdviceSlip()).thenAnswer((invocation) => Future.value({'slip':{'advice':EXPECTED_ADVICE}}));

			/* actually test */
			var changeListener = ChangeListener(_sutHomePageModel.adviceMessageState, 2);
			_sutHomePageModel.onIncrementClicked();
			await changeListener.waitForChange();

			/* assert and verify */
			expect(_sutHomePageModel.adviceMessageState.text, EXPECTED_ADVICE);
			verify(_mockOnlineDb.getNewAdviceSlip());
		});

		test('when fetch new advice : if DB fails and no handler : should do nothing', () {
			/* set mocks and other */
			when(_mockOnlineDb.getNewAdviceSlip()).thenAnswer((invocation) => Future.error(MockIOException('MSG')));

			/* actually test */
			_sutHomePageModel.onIncrementClicked();

			/* assert and verify */
			verify(_mockOnlineDb.getNewAdviceSlip());
		});


		test('when fetch new advice : if DB fails IO error : should invoke internet error handlers', () async {
			/* set mocks and other */
			const EXPECTED_MSG = 'MSG';
			var mockErrorHandler = MockErrorHandler();

			when(_mockOnlineDb.getNewAdviceSlip()).thenAnswer((invocation) => Future.error(MockIOException(EXPECTED_MSG)));

			/* actually test */
			_sutHomePageModel.register(mockErrorHandler);
			_sutHomePageModel.onIncrementClicked();

			/* assert and verify */
			await untilCalled(mockErrorHandler.handleConnectionError(any));
			verify(mockErrorHandler.handleConnectionError(EXPECTED_MSG));
			verifyNoMoreInteractions(mockErrorHandler);

			verify(_mockOnlineDb.getNewAdviceSlip());
		});


		test('when fetch new advice : if DB fails non_IO error : should invoke internal error handlers', () async {
			/* set mocks and other */
			const EXPECTED_STRING = 'MSG';
			var mockErrorHandler = MockErrorHandler();

			when (_mockOnlineDb.getNewAdviceSlip()).thenAnswer((invocation) => Future.error((Exception(EXPECTED_STRING))));

			/* actually test */
			_sutHomePageModel.register(mockErrorHandler);
			_sutHomePageModel.onIncrementClicked();


			/* assert and verify */
			await untilCalled(mockErrorHandler.handleInternalError(any));
			verify(mockErrorHandler.handleInternalError(any));
			verifyNoMoreInteractions(mockErrorHandler);

			verify(_mockOnlineDb.getNewAdviceSlip());
		});


		test('when fetch new advice : while DB processing : should have inActive and processing state', () async {
			/* set mocks and others */
			when(_mockOnlineDb.getNewAdviceSlip())
				.thenAnswer((invocation) => new Completer<Map<String, dynamic>>().future);

			/* actually test */
			var changeListener = ChangeListener(_sutHomePageModel.fabState, 1);
			_sutHomePageModel.onIncrementClicked();
			await changeListener.waitForChange();

			/* assert and verify */
			expect(_sutHomePageModel.fabState.value.isLoading, isTrue);
			expect(_sutHomePageModel.fabState.value.isActive, isFalse);
			expect(_sutHomePageModel.adviceMessageState.value.isActive, isFalse);
			expect(_sutHomePageModel.clickMessageState.value.isActive, isFalse);

			verify(_mockOnlineDb.getNewAdviceSlip());
		});


		test('when fetched new advice : if DB workds : should have active and non processing state', () async {
			/* set mocks and other */
			const String EXPECTED_VALUE = 'advice';
			when(_mockOnlineDb.getNewAdviceSlip()).thenAnswer((invocation) => Future.value({'slip':{'advice':EXPECTED_VALUE}}));

			/* actually test */
			var changeListener = ChangeListener(_sutHomePageModel.fabState, 2);
			_sutHomePageModel.onIncrementClicked();
			await changeListener.waitForChange();

			/* assert and verify */
			expect(_sutHomePageModel.fabState.isLoading, isFalse);
			expect(_sutHomePageModel.fabState.isActive, isTrue);
			expect(_sutHomePageModel.adviceMessageState.isActive, isTrue);
			expect(_sutHomePageModel.clickMessageState.isActive, isTrue);

			verify(_mockOnlineDb.getNewAdviceSlip());
		});

		group('test unregisteration of error handler : ', () {

			/** The 2 methods in this group need to be in sync **/

			MockErrorHandler _mockErrorHandler;

			setUp(() {
				when(_mockOnlineDb.getNewAdviceSlip()).thenAnswer((invocation) => Future.error(Exception('excpetion')));
				_mockErrorHandler = new MockErrorHandler();
				_sutHomePageModel.register(_mockErrorHandler);
			});

			tearDown(() {
				verify(_mockOnlineDb.getNewAdviceSlip());
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