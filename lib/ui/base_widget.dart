

import 'package:flutter/material.dart';
import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:splash_on_flutter/db/dbModule.dart';
import 'package:splash_on_flutter/model/home_page_model.dart';
import 'package:splash_on_flutter/ui/home_page.dart';

class BaseWidget extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		var demoPageModel = HomePageModel(
			AdviceReader(
				OnlineDB()
			)
		);
		return HomePage(demoPageModel, 'Demo home page');
	}
}