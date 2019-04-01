import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class DemoPageModel {

	static const String _INITIAL_ADVICE = "Initial advice";
	static const int    _INITIAL_COUNT = 0;
	static const String _COUNT_MSG_PREFIX = "Msg count is :";

	int _clickCounter = _INITIAL_COUNT;

	ValueNotifier<String> _countMessageNotifier = new ValueNotifier('$_COUNT_MSG_PREFIX: $_INITIAL_COUNT');
	ValueNotifier<String> _adviceMessageNotifier = new ValueNotifier(_INITIAL_ADVICE);
	ValueNotifier<bool> _fabShowsProgressBar = new ValueNotifier(false);

	ValueNotifier<String> get clickMessageNotifier => _countMessageNotifier;
	ValueNotifier<String> get adviceMessageNotifier => _adviceMessageNotifier;
	ValueNotifier<bool> get fabShowProgress => _fabShowsProgressBar;

	void onIncrementClicked () {
		_fabShowsProgressBar.value = true;
		_clickCounter ++;
		HttpClient client = HttpClient();
		client.getUrl(Uri.parse('https://api.adviceslip.com/advice'))
			.then((clientRequest) {
				debugPrint("Request closed");
				return clientRequest.close();
			}).then((response) {
				response
					.transform(utf8.decoder)
					.listen((stringContent) {
						Map<String, dynamic> jsonData = jsonDecode(stringContent);
						_countMessageNotifier.value = '$_COUNT_MSG_PREFIX: $_clickCounter';
						_adviceMessageNotifier.value = jsonData['slip']['advice'];
						_fabShowsProgressBar.value = false;
					});
			});
	}
}
