import 'package:flutter_test/flutter_test.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:splash_on_flutter/db/dbModule.dart';
import 'package:mockito/mockito.dart';

import 'dart:async';

class MockedOnlineDB extends Mock implements OnlineDB {}

void main () {
	group('usecase.advice_reader tests', () {
		OnlineDB _mockOnlineDB;

		setUp(() {
			_mockOnlineDB = MockedOnlineDB();
		});

		tearDown(() {
			_mockOnlineDB = null;
		});


		test('get new advice: if db fails: should future error', () async {
			// set mocks and other
			final Exception _EXPECTED_ERROR = Exception('Intentional error');
			when(_mockOnlineDB.getNewAdviceSlip()).thenAnswer((invocation) => Future.error(_EXPECTED_ERROR));

			// actually test
			var _adviceReader = AdviceReader(_mockOnlineDB);
			var output = _adviceReader.getNewAdvice();

			// assert and verify
			expect(output, throwsA(equals(_EXPECTED_ERROR)));
		});


		test('get new advice: If db works: should future advice', () {
			// set mocks and other
			const String _EXPECTED_STRING = 'EXPECTED_STRING';
			when(_mockOnlineDB.getNewAdviceSlip()).thenAnswer((invocation) => Future.value(
				{'slip': {
					'advice' : _EXPECTED_STRING
				}}
			));

			// actually test
			var _adviceReader = AdviceReader(_mockOnlineDB);
			Future<String> output = _adviceReader.getNewAdvice();

			// assert and verify
			expect(output, completion(equals(_EXPECTED_STRING)));
		});


		test('get current advice: If not fetched yet: should return empty', () {
			// set mocks and other

			// actually test
			var _adviceReader = AdviceReader(_mockOnlineDB);
			var output = _adviceReader.getCurrentAdvice();

			// assert and verify
			expect(output, '');
		});


		test('get current advice: If fetched yet: should return last advice', () async {
			// set mocks and other
			const String _EXPECTED_ADVICE = 'EXPECTED_ADVICE';
			when(_mockOnlineDB.getNewAdviceSlip()).thenAnswer((invocation) =>
					Future.value(
						{'slip':
							{
								'advice':_EXPECTED_ADVICE
							}
						}
					)
			);

			// actually test
			var _adviceReader = AdviceReader(_mockOnlineDB);
			await _adviceReader.getNewAdvice();
			var output = _adviceReader.getCurrentAdvice();

			// assert and verify
			expect(output, _EXPECTED_ADVICE);
		});
	});
}