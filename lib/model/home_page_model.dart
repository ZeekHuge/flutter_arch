import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:splash_on_flutter/db/dbModule.dart';

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

class HomePageModel {

	static const String _INITIAL_ADVICE = "Initial advice";
	static const int    _INITIAL_COUNT = 0;
	static const String _COUNT_MSG_PREFIX = "Msg count is :";

	static const List<Color> _COLOR_LIST = [Colors.brown, Colors.deepPurple, Colors.purple, Colors.red, Colors.green, Colors.orange];

	int _clickCounter = _INITIAL_COUNT;

	final TextViewState _msgCountState = TextViewState(true, '$_COUNT_MSG_PREFIX $_INITIAL_COUNT');
	final TextViewState _adviceTextState = TextViewState(true, _INITIAL_ADVICE);
	final FABState _fabState = FABState(true, false);

	ValueNotifier<Color> _themeColor = new ValueNotifier(Colors.yellow);

	TextViewState get clickMessageState => _msgCountState;
	TextViewState get adviceMessageState => _adviceTextState;
	FABState get fabState => _fabState;
	ValueNotifier<Color> get themeColor => _themeColor;

	final Random _randomGenerator = Random();
	final AdviceReader _adviceReader;
	HomePageModel (this._adviceReader);

	void onIncrementClicked () {
		_fabState.change(isLoading: true, isActive: false);
		_adviceTextState.change(isActive: false);
		_msgCountState.change(isActive: false);
		_clickCounter ++;

		_adviceReader.getNewAdvice()
			.then((advice){
				_msgCountState.change(text: '$_COUNT_MSG_PREFIX $_clickCounter');
				_adviceTextState.change(text: advice);
				_fabState.change(isLoading: false, isActive: true);
				_adviceTextState.change(isActive: true);
				_msgCountState.change(isActive: true);
			});
	}

	void changeThemeColor () {
		_themeColor.value = _COLOR_LIST[_randomGenerator.nextInt(_COLOR_LIST.length)];
	}
}
