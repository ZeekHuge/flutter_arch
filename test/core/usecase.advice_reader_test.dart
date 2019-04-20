import 'package:flutter_test/flutter_test.dart';
import 'package:splash_on_flutter/core/port/advice_data_provider.dart';
import 'package:splash_on_flutter/core/valueobject/data_valueobject.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:mockito/mockito.dart';

import 'dart:async';

class MockedFetchNewAdviceSlipPort extends Mock implements FetchNewAdviceSlip {}

void main () {
	group('usecase.advice_reader tests', () {
		FetchNewAdviceSlip _mockFetchNewAdviceSlipPort;

		setUp(() {
			_mockFetchNewAdviceSlipPort = MockedFetchNewAdviceSlipPort();
		});

		tearDown(() {
			_mockFetchNewAdviceSlipPort = null;
		});


		test('get new advice: if db fails: should future error', () async {
			// set mocks and other
			final Exception _EXPECTED_ERROR = Exception('Intentional error');
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip()).thenAnswer((invocation) => Future.error(_EXPECTED_ERROR));

			// actually test
			var _adviceReader = AdviceReader(_mockFetchNewAdviceSlipPort);
			var output = _adviceReader.getNewAdvice();

			// assert and verify
			expect(output, throwsA(equals(_EXPECTED_ERROR)));
		});


		test('get new advice: If db works: should future advice', () {
			// set mocks and other
			const _EXPECTED_ADVICE = 'EXPECTED_STRING';
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip()).thenAnswer((invocation) => Future.value(Slip(_EXPECTED_ADVICE)));

			// actually test
			var _adviceReader = AdviceReader(_mockFetchNewAdviceSlipPort);
			Future<String> output = _adviceReader.getNewAdvice();

			// assert and verify
			expect(output, completion(equals(_EXPECTED_ADVICE)));
		});


		test('get current advice: If not fetched yet: should return empty', () {
			// set mocks and other

			// actually test
			var _adviceReader = AdviceReader(_mockFetchNewAdviceSlipPort);
			var output = _adviceReader.getCurrentAdvice();

			// assert and verify
			expect(output, isEmpty);
		});


		test('get current advice: If fetched yet: should return last advice', () async {
			// set mocks and other
			const _EXPECTED_ADVICE = 'EXPECTED_ADVICE';
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip()).thenAnswer((invocation) =>
					Future.value(Slip(_EXPECTED_ADVICE))
			);

			// actually test
			var _adviceReader = AdviceReader(_mockFetchNewAdviceSlipPort);
			await _adviceReader.getNewAdvice();
			var output = _adviceReader.getCurrentAdvice();

			// assert and verify
			expect(output, _EXPECTED_ADVICE);
		});
	});
}