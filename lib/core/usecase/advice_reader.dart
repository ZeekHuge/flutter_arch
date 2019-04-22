
import 'package:splash_on_flutter/core/port/advice_data_provider.dart';
import 'package:splash_on_flutter/core/valueobject/data_valueobject.dart';

class AdviceReader {

	FetchNewAdviceSlip _fetchNewAdviceSlipPort;
	final CurrentAdviceSlip _currentAdviceSlipPort;

	AdviceReader(this._fetchNewAdviceSlipPort, this._currentAdviceSlipPort);

	Future<String> getCurrentAdvice() {
		return _currentAdviceSlipPort.readSlip()
			.then((slip) {
				if (slip == null)
					return '';
				return slip.advice;
			});
	}

	Future<String> getNewAdvice () {
		Slip currentAdviceSlip;
		return _fetchNewAdviceSlipPort.getNewAdviceSlip()
			.then((slip) {
				currentAdviceSlip = slip;
				return _currentAdviceSlipPort.writeSlip(slip);
			}).then((_void) {
				return currentAdviceSlip.advice;
			});
	}
}