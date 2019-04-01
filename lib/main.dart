import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:splash_on_flutter/modelFile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MyHomePage(DemoPageModel(), title: 'Flutter Demo Home Page');
	}
}

class MyHomePage extends StatelessWidget {

	final DemoPageModel model;
	final String title;

	MyHomePage(this.model, {key, this.title}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return ValueListenableBuilder<Color>(
			valueListenable: this.model.themeColor,
			child: Scaffold(
				appBar: AppBar(title: Text(title)),
				body: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							ValueListenableBuilder<String> (
								valueListenable: model.clickMessageNotifier,
								builder: (context, string, _) => Text(
									string,
									textAlign: TextAlign.center,
								)
							),
							ValueListenableBuilder<String> (
								valueListenable: model.adviceMessageNotifier,
								builder: (context, string, _) => Text(
									string,
									textAlign: TextAlign.center,
								)
							),
							RaisedButton (
								onPressed: model.changeThemeColor,
								child: Text("Change theme color"),
							)
						],
					),
				),
				floatingActionButton: ValueListenableBuilder<bool> (
					valueListenable: model.fabShowProgress,
					builder: (context, showProgress, _) {
						if (showProgress) {
							return FloatingActionButton(
								tooltip: 'Processing...',
								child: CircularProgressIndicator(
									valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
								),
								elevation: 20,
							);
						} else {
							return FloatingActionButton(
								onPressed: model.onIncrementClicked,
								tooltip: 'Increment',
								child: Icon(Icons.add),
								elevation: 20,
							);
						}
					},
				)
			),
			builder: (context, value, child){
				return MaterialApp(
					title: 'Flutter Demo',
					theme: ThemeData(
						primarySwatch: value,
					),
					home: child,
				);
			},
		);
	}
}
