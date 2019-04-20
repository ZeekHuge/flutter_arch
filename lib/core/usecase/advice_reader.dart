
import 'package:splash_on_flutter/core/valueobject/data_valueobject.dart';
import 'package:splash_on_flutter/db/dbModule.dart';

class AdviceReader {

	OnlineDB _onlineDB;
	Slip _currentAdviceSlip;

	AdviceReader(this._onlineDB) : this._currentAdviceSlip = Slip('');

	String getCurrentAdvice() {
		return _currentAdviceSlip.advice;
	}

	Future<String> getNewAdvice () {
		return _onlineDB.getNewAdviceSlip()
			.then((slip) {
				_currentAdviceSlip = slip;
				return _currentAdviceSlip.advice;
			});
	}
}