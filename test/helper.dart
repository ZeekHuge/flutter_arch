import 'dart:async';

import 'package:flutter/widgets.dart';

class ChangeListener {

	final Completer<void> _changeCompleter = new Completer();
	final ValueNotifier _changeNotifier;
	final int _requiredCount;

	int _completionCount = 0;
	void _completionCounter () {
		_completionCount += 1;
	}

	void _completionListener () {
		_completionCounter();
		if (_requiredCount == _completionCount)
			_changeCompleter.complete(null);
	}

	ChangeListener(this._changeNotifier, this._requiredCount) {
		_changeNotifier.addListener(_completionCounter);
	}

	Future<void> waitForChange () {
		_changeNotifier.removeListener(_completionCounter);

		if (_requiredCount == _completionCount)
			_changeCompleter.complete(null);
		else if (_completionCount > _requiredCount)
			_changeCompleter.completeError(new Exception('Change exceeded required limit'));
		else
			_changeNotifier.addListener(_completionListener);

		return _changeCompleter.future.then((value) {
			_changeNotifier.removeListener(_completionCounter);
			return value;
		});
	}
}