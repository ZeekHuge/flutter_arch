
import 'package:splash_on_flutter/db/dbModule.dart';

class AdviceReader {

	OnlineDB _onlineDB;
	String _currentAdvice='';

	AdviceReader(this._onlineDB);

	String getCurrentAdvice() {
		return _currentAdvice;
	}

	Future<String> getNewAdvice () {
		return _onlineDB.getNewAdvice()
			.then((mapDate) {
				_currentAdvice = mapDate['slip']['advice'];
				return _currentAdvice;
			});
	}
}