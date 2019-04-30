
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:splash_on_flutter/app_constants.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:splash_on_flutter/core/valueobject/exception.dart';

import 'package:splash_on_flutter/model/home_page_model.dart';

import '../test_helper/helper.dart';



class MockAdviceReader extends Mock implements AdviceReader {}
class MockErrorHandler extends Mock implements ErrorHandler {}
class MockRandom extends Mock implements Random {}

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

		test('when change theme color : theme-color-stream should emit new theme color', () async {
			/* set mocks and other */
			var originalThemeColor = _sutHomePageModel.themeColor.value;
			when(_mockRandom.nextInt(any)).thenReturn(2);
			var colorStream = _sutHomePageModel.themeColorStream;

			/* actually test */
			_sutHomePageModel.changeThemeColor();

			/* assert and verify */
			expect(await colorStream.first, isNot(originalThemeColor));
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


		test('when listenting to action-alement-state-stream '
			': after error/message event in advice stream '
			': action-element-stream should emit non-loading state', () async {

			/* set mocks and other */
			var adviceStreamController = StreamController<String>();
			when(_mockAdviceReader.getAdviceStream()).thenAnswer((invocation) => adviceStreamController.stream);

			/* actually test */
			var actionElementStateSequenceFuture = _sutHomePageModel.actionElementStateStream.toList();

			adviceStreamController.add('any-string');
			adviceStreamController.addError(Exception('Intentional exception'));

			adviceStreamController.close();

			/* assert and verify */
			expect(await actionElementStateSequenceFuture,
				[
					ActionElementState(false), // as response to new message
					ActionElementState(false), // as response to error
				]
			);
			verify(_mockAdviceReader.getAdviceStream());
		});


		test('when refresh advice '
			': while no event in advice steam '
			': action-element-stream should emit on-loading state', () async {

			/* set mocks and other */
			var adviceStreamController = StreamController<String>();
			when(_mockAdviceReader.getAdviceStream()).thenAnswer((invocation) => adviceStreamController.stream);

			/* actually test */
			var actionElementStateSequenceFuture = _sutHomePageModel.actionElementStateStream.toList();

			_sutHomePageModel.onIncrementClicked();

			adviceStreamController.close();

			/* assert and verify */
			expect(await actionElementStateSequenceFuture, [ActionElementState(true)]);
			verify(_mockAdviceReader.getAdviceStream());
		});


		test('when event on advice stream : if non-InternetNotConnectedException and handler registered : should invoke internal error handler', () async {
			/* set mocks and other */
			var streamController = StreamController<String>();
			when(_mockAdviceReader.getAdviceStream()).thenAnswer((invocation) => streamController.stream);

			/* actually test */
			_sutHomePageModel.register(_mockErrorHandler);
			streamController.addError(Exception('Intentional exception'));
			await untilCalled(_mockErrorHandler.handleInternalError(any)).timeout(ConstDuration.TenMilliSecond);

			streamController.close();

			/* assert and verify */
			verify(_mockAdviceReader.getAdviceStream());
			verify(_mockErrorHandler.handleInternalError(UIStrings.INTERNAL_ERROR))	;
		});


		test('when event on advice stream : if InternetNotConnectedException and handler registered : should invoke internet error handler', () async {
			/* set mocks and other */
			var streamController = StreamController<String>();
			when(_mockAdviceReader.getAdviceStream()).thenAnswer((invocation) => streamController.stream);

			/* actually test */
			_sutHomePageModel.register(_mockErrorHandler);
			streamController.addError(InternetNotConnectedException('Intentional exception'));
			await untilCalled(_mockErrorHandler.handleConnectionError(any)).timeout(ConstDuration.TenMilliSecond);

			streamController.close();

			/* assert and verify */
			verify(_mockAdviceReader.getAdviceStream());
			verify(_mockErrorHandler.handleConnectionError(UIStrings.INTERNET_NOT_CONNECTED));
		});


		test('when event on advice stream : if new advice added : advice-message-state-stream should emit new message state', () async {
			/* set mocks and other */
			const expectedMessage = 'expected message';
			final streamController = StreamController<String>();

			when(_mockAdviceReader.getAdviceStream()).thenAnswer((invocation) => streamController.stream);

			/* actually test */
			streamController.add(expectedMessage);
			var outputState = await _sutHomePageModel.adviceMessageStateStream.first;

			/* assert and verify */
			expect(outputState.isActive, true);
			expect(outputState.text, expectedMessage);

			verify(_mockAdviceReader.getAdviceStream());

			streamController.close();
		});


		test('when event on advice strem : any exception and no error-handler registerd : should do nothing', () async {
			/* set mocks and other */
			var streamController = StreamController<String>();
			when(_mockAdviceReader.getAdviceStream()).thenAnswer((invocation) => streamController.stream);

			/* actually test */
			_sutHomePageModel.register(_mockErrorHandler);
			_sutHomePageModel.unregister(_mockErrorHandler);
			streamController.addError(Exception('Intentional exception'));

			// wait for 100 microseconds, for if the other futures from error handle need to be completed
			await Future.delayed(const Duration(microseconds: 1));
			streamController.close();

			/* assert and verify */
			verify(_mockAdviceReader.getAdviceStream());
		});
	});
}