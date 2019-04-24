import 'package:flutter_test/flutter_test.dart';
import 'package:splash_on_flutter/core/port/advice_data_provider.dart';
import 'package:splash_on_flutter/core/valueobject/data_valueobject.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:mockito/mockito.dart';

import 'dart:async';

import 'package:splash_on_flutter/core/valueobject/exception.dart';

class MockedFetchNewAdviceSlipPort extends Mock implements FetchNewAdviceSlip {}
class MockedCurrentAdviceSlipPort extends Mock implements CurrentAdviceSlip {}

void main () {
	group('usecase.advice_reader tests: ', () {
		FetchNewAdviceSlip _mockFetchNewAdviceSlipPort;
		AdviceReader _sutAdviceReader;
		CurrentAdviceSlip _mockedCurrentAdviceSlipPort;

		setUp(() {
			_mockFetchNewAdviceSlipPort = MockedFetchNewAdviceSlipPort();
			_mockedCurrentAdviceSlipPort = MockedCurrentAdviceSlipPort();
			_sutAdviceReader = AdviceReader(_mockFetchNewAdviceSlipPort, _mockedCurrentAdviceSlipPort);

		});

		tearDown(() {
			verifyNoMoreInteractions(_mockedCurrentAdviceSlipPort);
			verifyNoMoreInteractions(_mockFetchNewAdviceSlipPort);
			_mockFetchNewAdviceSlipPort = null;
			_mockedCurrentAdviceSlipPort = null;
			_sutAdviceReader = null;
		});


		test('get new advice: if db fails: should not write current and return future InternetNotConnectedException', () async {
			// set mocks and other
			const EXPECTED_CAUSE = 'EXPECTED_CAUSE';
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip())
				.thenAnswer((invocation) => Future.error(Exception(EXPECTED_CAUSE)));

			try {
				// actually test
				await _sutAdviceReader.getNewAdvice();
				fail('We excpect an exception here');
			} catch (e) {
				// assert and verify
				expect(
					e.toString(),
					equals(
						InternetNotConnectedException(
							Exception(EXPECTED_CAUSE).toString()
						).toString()
					)
				);
				verify(_mockFetchNewAdviceSlipPort.getNewAdviceSlip());
			}
		});


		test('get new advice: If db works: should write current and return future advice', () async {
			// set mocks and other
			const _EXPECTED_ADVICE = 'EXPECTED_STRING';
			final expected_slip = Slip(_EXPECTED_ADVICE);
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip()).thenAnswer((invocation) => Future.value(expected_slip));
			when(_mockedCurrentAdviceSlipPort.writeSlip(any)).thenAnswer((invocation) => Future.value(null));

			// actually test
			var output = await _sutAdviceReader.getNewAdvice();

			// assert and verify
			expect(output, _EXPECTED_ADVICE);
			verify(_mockFetchNewAdviceSlipPort.getNewAdviceSlip());
			verify(_mockedCurrentAdviceSlipPort.writeSlip(expected_slip));
		});


		test('get new advice : if db works but current advice write fails : should return future error', () async {
			/* set mocks and other */
			final expected_slip = Slip('EXPECTED_ADVICE');
			final expected_exception = Exception('EXPECTED_ERROR');
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip())
				.thenAnswer((invocation) => Future.value(expected_slip));
			when(_mockedCurrentAdviceSlipPort.writeSlip(any))
				.thenAnswer((invocation) => Future.error(expected_exception));

			try {
				/* actually test */
				await _sutAdviceReader.getNewAdvice();
				fail('We expect exception');
			} catch (e) {
				/* assert and verify */
				verify(_mockFetchNewAdviceSlipPort.getNewAdviceSlip());
				verify(_mockedCurrentAdviceSlipPort.writeSlip(expected_slip));
			}
		});



		test('get current advice: If not fetched yet: should return empty', () async {
			// set mocks and other
			when(_mockedCurrentAdviceSlipPort.readSlip()).thenAnswer((invocation) => Future.value(null));

			// actually test
			var output = await _sutAdviceReader.getCurrentAdvice();

			// assert and verify
			expect(output, isEmpty);
			verify(_mockedCurrentAdviceSlipPort.readSlip());
		});

		test('get current advice: if failed read: should return Future error', () async {
			/* set mocks and other */
			final EXPECTED_EXCEPTION = new Exception('EXPECTED_EXCEPTION');
			when(_mockedCurrentAdviceSlipPort.readSlip()).thenAnswer((invocation) => Future.error(EXPECTED_EXCEPTION));

			/* actually test */
			var output = _sutAdviceReader.getCurrentAdvice();

			/* assert and verify */
			expect(output, throwsA(equals(EXPECTED_EXCEPTION)));
			verify(_mockedCurrentAdviceSlipPort.readSlip());
		});


		test('get current advice: If fetched yet: should return last advice', () async {
			// set mocks and other
			const _EXPECTED_ADVICE = 'EXPECTED_ADVICE';
			final expected_slip = Slip(_EXPECTED_ADVICE);
			when(_mockFetchNewAdviceSlipPort.getNewAdviceSlip()).thenAnswer((invocation) =>
					Future.value(expected_slip)
			);
			when(_mockedCurrentAdviceSlipPort.writeSlip(any)).thenAnswer((writeInvocation) {
				when(_mockedCurrentAdviceSlipPort.readSlip())
					.thenAnswer((readInvocation) => Future.value(writeInvocation.positionalArguments[0]));
				return Future.value(null);
			});

			// actually test
			await _sutAdviceReader.getNewAdvice();
			var output = await _sutAdviceReader.getCurrentAdvice();

			// assert and verify
			expect(output, _EXPECTED_ADVICE);
			verify(_mockFetchNewAdviceSlipPort.getNewAdviceSlip());
			verify(_mockedCurrentAdviceSlipPort.writeSlip(expected_slip));
			verify(_mockedCurrentAdviceSlipPort.readSlip());
		});
	});
}