import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:splash_on_flutter/app_constants.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:splash_on_flutter/core/valueobject/exception.dart';
import 'package:splash_on_flutter/util.dart';
import 'package:splash_on_flutter/widget/callback_widget.dart';

const _TAG = "home_page_model";

abstract class ErrorHandler {
	void handleConnectionError (String message);
	void handleInternalError (String message);
}

class TextViewState extends ValueNotifier<TextViewState> {

	String _text;
	bool _isActive;

    TextViewState(this._isActive, this._text) : super(null);

    TextViewState get value => this;

	String get text => _text;
	bool get isActive => _isActive;

	void change({bool isActive, String text}) {
		if (isActive != null)
			_isActive = isActive;
		if (text != null)
			_text = text;
		notifyListeners();
	}
}

class FABState extends ValueNotifier<FABState> {

	bool _isActive;
	bool _isLoading;

	FABState (this._isActive, this._isLoading) : super(null);

	FABState get value => this;

	bool get isActive => _isActive;
	bool get isLoading => _isLoading;

	void change ({bool isActive, bool isLoading}) {
		if (isActive != null)
			this._isActive = isActive;
		if (isLoading != null)
			this._isLoading = isLoading;
		notifyListeners();
	}
}


class MessageDisplayState {
	final bool isActive;
	final String text;

	const MessageDisplayState._(this.text, this.isActive,);
}

class ActionElementState {
	final bool isLoading;
	ActionElementState(this.isLoading);

	@override
	int get hashCode {
		const PRIME = 31;
		var result = 17;
		result = result * PRIME + (isLoading ? 1 : 0);
		return result;
	}

	@override
	bool operator ==(other) {
		if (other is ActionElementState)
			return other.isLoading == isLoading;
		return false;
	}
}

class CounterMessageState {
	final String text;
    const CounterMessageState(this.text);

	@override
	int get hashCode => Helper.calculateHash([], [text]);

	@override
	bool operator ==(other) {
		if (other is CounterMessageState)
			return other.text == text;
		return false;
	}
}



class HomePageModel implements CallbackWidgetCaller<ErrorHandler> {

	static const int _INITIAL_COUNT = 0;

	static const List<Color> _COLOR_LIST = [
		Colors.brown,
		Colors.deepPurple,
		Colors.purple,
		Colors.red,
		Colors.green,
		Colors.orange
	];

	int _clickCounter;

	final String _title;

	final TextViewState _msgCountState;
	final TextViewState _adviceTextState;
	final FABState _fabState;

	final ValueNotifier<Color> _themeColor;

	final Random _randomGenerator;
	final AdviceReader _adviceReader;

	ErrorHandler _errorHandler;

	TextViewState get clickMessageState => _msgCountState;
	TextViewState get adviceMessageState => _adviceTextState;
	FABState get fabState => _fabState;
	ValueNotifier<Color> get themeColor => _themeColor;
	String get title => _title;

	HomePageModel (this._adviceReader, this._randomGenerator):
			this._title = UIStrings.APPLICATION_TITLE,
			this._clickCounter = _INITIAL_COUNT,
			this._fabState = FABState(true, false),
			this._themeColor = ValueNotifier(Colors.yellow),
			this._msgCountState = TextViewState(true, '${UIStrings.HOMEPAGE_COUNT_MSG_PREFIX} $_INITIAL_COUNT'),
			this._adviceTextState = TextViewState(true, UIStrings.HOMEPAGE_INITIAL_ADVICE);



	get adviceMessageStateStream => _adviceReader.getAdviceStream()
		.map((advice) => MessageDisplayState._(advice, true));

	// ignore: close_sinks
	StreamController<Color> _themeColorStreamController ;
	get themeColorStream {
		if (_themeColorStreamController == null)
			_themeColorStreamController = StreamController<Color>();
		return _themeColorStreamController.stream;
	}


	ActionElementStateController _actionElementStateController;
	Stream<ActionElementState> get actionElementStateStream {
		if (_actionElementStateController == null)
			_actionElementStateController = ActionElementStateController(_adviceReader.getAdviceStream());
		return _actionElementStateController.stream;
	}

	CounterMessageStateController _counterMessageStateController;
	get counterMessageStateStream {
		if (_counterMessageStateController == null)
			_counterMessageStateController = CounterMessageStateController(_adviceReader.getAdviceStream());
		return _counterMessageStateController.stream;
	}


	void onIncrementClicked () {
		_fabState.change(isLoading: true, isActive: false);
		_adviceTextState.change(isActive: false);
		_msgCountState.change(isActive: false);
		_clickCounter ++;
		_actionElementStateController?.setOnLoadingState();
	}

	void changeThemeColor () {
		_themeColorStreamController?.add(
			_COLOR_LIST[_randomGenerator.nextInt(_COLOR_LIST.length)]
		);
	}

	@override
	void register(ErrorHandler callback) {
		_errorHandler = callback;
		_adviceReader.getAdviceStream()
			.handleError((e) {
			if (e is InternetNotConnectedException)
				_errorHandler?.handleConnectionError(UIStrings.INTERNET_NOT_CONNECTED);
			else
				_errorHandler?.handleInternalError(UIStrings.INTERNAL_ERROR);
		})
			.listen((onData) {});
	}

	@override
	void unregister(ErrorHandler callback) {
		if (_errorHandler == callback)
			_errorHandler = null;
	}
}


class CounterMessageStateController {

	int _counterCount;
	final Stream<String> _adviceStream;

	CounterMessageStateController(this._adviceStream): _counterCount=0;

	Stream<CounterMessageState> get stream {
		return _adviceStream
			.map((_)  {
				_counterCount++;
				return CounterMessageState(UIStrings.HOMEPAGE_COUNT_MSG_PREFIX + _counterCount.toString());
			}).handleError((e) {
				Log.e(_TAG, 'Error in advice stream. Wont handle : ' + e.toString());
			});
	}
}

class ActionElementStateController {
	final Stream<String> _adviceStream;
	ActionElementStateController(this._adviceStream);

	StreamController<ActionElementState> _actionElementStateStreamController;
	StreamSubscription<String> _adviceStreamSubscription;
	Stream<ActionElementState> get stream {
		if (_actionElementStateStreamController == null) {
			_actionElementStateStreamController = StreamController<ActionElementState>();
			_actionElementStateStreamController.onListen = _onActionElementStateStreamListened;
			_actionElementStateStreamController.onCancel = _onActionElementStateStreamCanceled;
		}
		return _actionElementStateStreamController.stream;
	}

	void setOnLoadingState () {
		_actionElementStateStreamController?.add(ActionElementState(true));
	}

	void _onActionElementStateStreamListened () {
		_adviceStreamSubscription = _adviceStream.listen(
			_onNewAdviceOnAdviceStream,
			onError: _onExceptionInAdviceStream,
			onDone: _onAdviceStreamIsClosed
		);
	}

	void _onAdviceStreamIsClosed () {
		Log.d(_TAG, 'AdviceStream closed. Closing ActionElementStateStream');
		_actionElementStateStreamController.close();
	}

	void _onActionElementStateStreamCanceled () {
		_adviceStreamSubscription.cancel();
	}

	void _onExceptionInAdviceStream (Object e) {
		Log.d(_TAG, 'Error on AdviceStream : ' + e.toString());
		_actionElementStateStreamController.add(ActionElementState(false));
	}

	void _onNewAdviceOnAdviceStream (String newAdvice) {
		_actionElementStateStreamController.add(ActionElementState(false));
	}
}
