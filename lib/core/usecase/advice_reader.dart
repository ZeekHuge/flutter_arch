
import 'package:splash_on_flutter/core/port/advice_data_provider.dart';
import 'package:splash_on_flutter/core/valueobject/data_valueobject.dart';

class AdviceReader {

	FetchNewAdviceSlip _fetchNewAdviceSlipPort;
	Slip _currentAdviceSlip;

	AdviceReader(this._fetchNewAdviceSlipPort) : this._currentAdviceSlip = Slip('');

	String getCurrentAdvice() {
		return _currentAdviceSlip.advice;
	}

	Future<String> getNewAdvice () {
		return _fetchNewAdviceSlipPort.getNewAdviceSlip()
			.then((slip) {
				_currentAdviceSlip = slip;
				return _currentAdviceSlip.advice;
			});
	}
}