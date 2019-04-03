
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

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

class OnlineDB {

	Future<Map<String, dynamic>> getNewAdvice () {
		return _HTTPRequestHelper.simpleGetRequest('https://api.adviceslip.com/advice');
	}
}