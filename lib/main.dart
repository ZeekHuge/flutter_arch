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

	String _showText = ".. no message ..";
	int _msgCounter = 0;

	_MyHomePageState () {
		widget.model.subscribeToAdviceChange((adviceString) {
			setState(() {
				_showText = adviceString;
			});
		});

		widget.model.subscribeToCountChange((count) {
			setState(() {
				_msgCounter = count;
			});
		});
	}

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
						Text(
							'Message number $_msgCounter is',
							textAlign: TextAlign.center,
						),
						Text(
							'$_showText',
							style: Theme.of(context).textTheme.display1,
							textAlign: TextAlign.center,
						),
					],
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: widget.model.onIncrementClicked,
				tooltip: 'Increment',
				child: Icon(Icons.add),
			), // This trailing comma makes auto-formatting nicer for build methods.
		);
	}
}
