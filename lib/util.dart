import 'package:flutter/foundation.dart';

class Log {
	static String _getStringToPrintFromTagAndMessage (String tag, String message) {
		return tag + " >> " + message;
	}

	static void d (String tag, String message) {
		debugPrint(_getStringToPrintFromTagAndMessage(tag, message));
	}

	static void i (String tag, String message) {
		print(_getStringToPrintFromTagAndMessage(tag, message));
	}

    static void e (String tag, String message) {
		print(_getStringToPrintFromTagAndMessage(tag, message));
    }
}