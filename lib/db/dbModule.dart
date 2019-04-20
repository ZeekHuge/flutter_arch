
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:splash_on_flutter/core/port/advice_data_provider.dart';
import 'package:splash_on_flutter/core/valueobject/data_valueobject.dart';

class _HTTPRequestHelper {
	static Future<Map<String, dynamic>> simpleGetRequest (String url) {
		HttpClient client = HttpClient();
		return client.getUrl(Uri.parse(url))
			.then((clientRequest) {
			debugPrint("Request closed");
			return clientRequest.close();
		}).then((response) {
			return response
				.transform(utf8.decoder)
				.fold('', (prev, cur) {return '$prev$cur';});
		}).then((stringData) {
			return jsonDecode(stringData);
		});
	}
}

class OnlineDB implements FetchNewAdviceSlip {

	Future<Slip> getNewAdviceSlip () {
		return _HTTPRequestHelper.simpleGetRequest('https://api.adviceslip.com/advice')
			.then((dataMap) {
				return new Slip(dataMap['slip']['advice']);
			});
	}
}