import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:splash_on_flutter/app_constants.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:splash_on_flutter/ui/widget/callback_widget.dart';


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

class HomePageModel implements CallbackWidgetCaller<ErrorHandler> {

	static const int _INITIAL_COUNT = 0;

	static const List<Color> _COLOR_LIST = [Colors.brown, Colors.deepPurple, Colors.purple, Colors.red, Colors.green, Colors.orange];

	int _clickCounter;

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

	HomePageModel (this._adviceReader, this._randomGenerator):
			this._clickCounter = _INITIAL_COUNT,
			this._fabState = FABState(true, false),
			this._themeColor = ValueNotifier(Colors.yellow),
			this._msgCountState = TextViewState(true, '${UIStrings.HOMEPAGE_COUNT_MSG_PREFIX} $_INITIAL_COUNT'),
			this._adviceTextState = TextViewState(true, UIStrings.HOMEPAGE_INITIAL_ADVICE);


	void onIncrementClicked () {
		_fabState.change(isLoading: true, isActive: false);
		_adviceTextState.change(isActive: false);
		_msgCountState.change(isActive: false);
		_clickCounter ++;

		_adviceReader.getNewAdvice()
			.then((advice){
				_msgCountState.change(text: '${UIStrings.HOMEPAGE_COUNT_MSG_PREFIX} $_clickCounter');
				_adviceTextState.change(text: advice);
				_fabState.change(isLoading: false, isActive: true);
				_adviceTextState.change(isActive: true);
				_msgCountState.change(isActive: true);
			}).catchError((e) {
				if (e is IOException)
					_errorHandler?.handleConnectionError(e.toString());
				else
					_errorHandler?.handleInternalError(e.toString());
			});
	}

	void changeThemeColor () {
		_themeColor.value = _COLOR_LIST[_randomGenerator.nextInt(_COLOR_LIST.length)];
	}

	@override
	void register(ErrorHandler callback) {
		_errorHandler = callback;
	}

	@override
	void unregister(ErrorHandler callback) {
		if (_errorHandler == callback)
			_errorHandler = null;
	}
}
