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
		AdviceReader _sutAdviceReader;

		setUp(() {
			_mockFetchNewAdviceSlipPort = MockedFetchNewAdviceSlipPort();
			_sutAdviceReader = AdviceReader(_mockFetchNewAdviceSlipPort);
		});

		tearDown(() {
			verifyNoMoreInteractions(_mockFetchNewAdviceSlipPort);
			_mockFetchNewAdviceSlipPort = null;
			_sutAdviceReader = null;
		});


		test('get new advice: if db fails: should future error', () async {
			// set mocks and other
			final Exception _EXPECTED_ERROR = Exception('Intentional error');
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip()).thenAnswer((invocation) => Future.error(_EXPECTED_ERROR));

			// actually test
			var output = _sutAdviceReader.getNewAdvice();

			// assert and verify
			expect(output, throwsA(equals(_EXPECTED_ERROR)));
			verify(_mockFetchNewAdviceSlipPort.getNewAdviceSlip());
		});


		test('get new advice: If db works: should future advice', () {
			// set mocks and other
			const _EXPECTED_ADVICE = 'EXPECTED_STRING';
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip()).thenAnswer((invocation) => Future.value(Slip(_EXPECTED_ADVICE)));

			// actually test
			Future<String> output = _sutAdviceReader.getNewAdvice();

			// assert and verify
			expect(output, completion(equals(_EXPECTED_ADVICE)));
			verify(_mockFetchNewAdviceSlipPort.getNewAdviceSlip());
		});


		test('get current advice: If not fetched yet: should return empty', () {
			// set mocks and other

			// actually test
			var output = _sutAdviceReader.getCurrentAdvice();

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
			await _sutAdviceReader.getNewAdvice();
			var output = _sutAdviceReader.getCurrentAdvice();

			// assert and verify
			expect(output, _EXPECTED_ADVICE);
			verify(_mockFetchNewAdviceSlipPort.getNewAdviceSlip());
		});
	});
}