import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:splash_on_flutter/modelFile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Flutter Demo',
			theme: ThemeData(
				primarySwatch: Colors.green,
			),
			home: MyHomePage(DemoPageModel(), title: 'Flutter Demo Home Page'),
		);
	}
}

class MyHomePage extends StatefulWidget {
	final DemoPageModel model;

	MyHomePage(this.model, {Key key, this.title}) : super(key: key);

	final String title;

	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(widget.title),
			),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						ValueListenableBuilder<String> (
							valueListenable: widget.model.clickMessageNotifier,
							builder: (context, string, _) => Text(
								string,
								textAlign: TextAlign.center,
							)
						),
						ValueListenableBuilder<String> (
								valueListenable: widget.model.adviceMessageNotifier,
								builder: (context, string, _) => Text(
									string,
									textAlign: TextAlign.center,
								)
						),
					],
				),
			),
			floatingActionButton: ValueListenableBuilder<bool> (
				valueListenable: widget.model.fabShowProgress,
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
							onPressed: widget.model.onIncrementClicked,
							tooltip: 'Increment',
							child: Icon(Icons.add),
							elevation: 20,
						);
					}
				}, // This trailing comma makes auto-formatting nicer for build methods.
			)
		);
	}
}
