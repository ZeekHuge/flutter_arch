
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:splash_on_flutter/app_constants.dart';
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
							ValueListenableBuilder<TextViewState> (
								valueListenable: model.clickMessageState,
								builder: (context, textViewState, _) => Text(
									textViewState.text,
									key: Key(WidgetKey.HOMEPAGE_CLICK_TEXT),
									textAlign: TextAlign.center,
									style: TextStyle(color: (textViewState.isActive ? Colors.black : Colors.grey)),
								)
							),
							ValueListenableBuilder<TextViewState> (
								valueListenable: model.adviceMessageState,
								builder: (context, textViewState, _) => Text(
									textViewState.text,
									key: Key(WidgetKey.HOMEPAGE_MSG_TEXT),
									textAlign: TextAlign.center,
									style: TextStyle(color: (textViewState.isActive ? Colors.black : Colors.grey)),
								)
							),
							RaisedButton (
								onPressed: model.changeThemeColor,
								child: Text("Change theme color"),
							)
						],
					),
				),
				floatingActionButton: ValueListenableBuilder<FABState> (
					valueListenable: model.fabState,
					builder: (context, fabState, _) {
						return FloatingActionButton(
							onPressed: (fabState.isActive ? model
								.onIncrementClicked : () {}),
							tooltip: (fabState.isLoading ? 'Processing...'
								: 'Increment'),
							child: (
								fabState.isLoading
								? CircularProgressIndicator(
									valueColor: new AlwaysStoppedAnimation<
									Color>(Colors.blue),
									key: Key(WidgetKey.HOMEPAGE_PROGRESS_INDICATOR),
								)
								: Icon(
									Icons.add,
									key: Key(WidgetKey.HOMEPAGE_START_FETCH),
								)
							),
						);
					}
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
