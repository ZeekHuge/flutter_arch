
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:splash_on_flutter/model/home_page_model.dart';

class HomePage extends StatelessWidget {

	final HomePageModel model;
	final String title;

	HomePage(this.model, this.title, {Key key}) : super(key: key);

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
								onPressed: () {},
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
