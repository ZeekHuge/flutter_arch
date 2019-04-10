
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:splash_on_flutter/app_constants.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';

import 'package:splash_on_flutter/db/dbModule.dart';
import 'package:splash_on_flutter/model/home_page_model.dart';

import 'helper.dart';

class MockOnlineDB extends Mock implements OnlineDB {}


void main () {

	group('Homepage model test', () {

		HomePageModel _sutHomePageModel;
		OnlineDB _mockOnlineDb;


		setUp(() {
			_mockOnlineDb = MockOnlineDB();
			_sutHomePageModel = new HomePageModel(new AdviceReader(_mockOnlineDb));
		});


		tearDown(() {
			_mockOnlineDb = null;
			_sutHomePageModel = null;
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
			var EXPECTED_ADVICE = 'advice';
			when(_mockOnlineDb.getNewAdvice()).thenAnswer((invocation) => Future.value({'slip':{'advice':EXPECTED_ADVICE}}));

			/* actually test */
			var changeListener = ChangeListener(_sutHomePageModel.adviceMessageState, 2);
			_sutHomePageModel.onIncrementClicked();
			await changeListener.waitForChange();

			/* assert and verify */
			expect(_sutHomePageModel.adviceMessageState.text, EXPECTED_ADVICE);
		});


		test('when fetch new advice : while DB processing : should have inActive and processing state', () async {
			/* set mocks and others */
			when(_mockOnlineDb.getNewAdvice())
				.thenAnswer((invocation) => new Completer<Map<String, dynamic>>().future);

			/* actually test */
			var changeListener = ChangeListener(_sutHomePageModel.fabState, 1);
			_sutHomePageModel.onIncrementClicked();
			await changeListener.waitForChange();

			/* assert and verify */
			expect(_sutHomePageModel.fabState.isLoading, isTrue);
			expect(_sutHomePageModel.fabState.isActive, isFalse);
			expect(_sutHomePageModel.adviceMessageState.isActive, isFalse);
			expect(_sutHomePageModel.clickMessageState.isActive, isFalse);
		});


		test('when fetched new advice : if DB workds : should have active and non processing state', () async {
			/* set mocks and other */
			final String EXPECTED_VALUE = 'advice';
			when(_mockOnlineDb.getNewAdvice()).thenAnswer((invocation) => Future.value({'slip':{'advice':EXPECTED_VALUE}}));

			/* actually test */
			var changeListener = ChangeListener(_sutHomePageModel.fabState, 2);
			_sutHomePageModel.onIncrementClicked();
			await changeListener.waitForChange();

			/* assert and verify */
			expect(_sutHomePageModel.fabState.isLoading, isFalse);
			expect(_sutHomePageModel.fabState.isActive, isTrue);
			expect(_sutHomePageModel.adviceMessageState.isActive, isTrue);
			expect(_sutHomePageModel.clickMessageState.isActive, isTrue);
		});
	});
}