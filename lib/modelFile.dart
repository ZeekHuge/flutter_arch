import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef void AdviceSubscription (String advice);
typedef void CountSubscription (int count);

class DemoPageModel {

	var _adviceSubscription = new List<AdviceSubscription>();
	var _countSubscription = new List<CountSubscription>();

	int _clickCount = 0;

	void subscribeToAdviceChange (AdviceSubscription subscription) {
		_adviceSubscription.add(subscription);
	}

	void subscribeToCountChange (CountSubscription subscription) {
		_countSubscription.add(subscription);
	}

	void onIncrementClicked () {
		_clickCount++;
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
						for (AdviceSubscription adviceSubscription in _adviceSubscription) {
							adviceSubscription(jsonData['slip']['advice']);
						}
						for (CountSubscription countSubscription in _countSubscription) {
							countSubscription(_clickCount);
						}
					});
			});
	}
}
