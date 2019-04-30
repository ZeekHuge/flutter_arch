import 'package:flutter/foundation.dart';

class Helper {
	static int calculateHash(List<bool> boolElements, List<String> stringElements) {
		const PRIME = 31;
		var result = 17;
		for (var b in boolElements) {
			result = result * PRIME + (b ? 1 : 0);
		}
		for (var s in stringElements) {
			result = result * PRIME + (s == null ? 0 : s.hashCode);
		}
		return result;
	}
}

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