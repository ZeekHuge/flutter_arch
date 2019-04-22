
import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:splash_on_flutter/core/usecase/advice_reader.dart';
import 'package:splash_on_flutter/db/dbModule.dart';
import 'package:splash_on_flutter/model/home_page_model.dart';
import 'package:splash_on_flutter/ui/app.dart';
import 'package:splash_on_flutter/ui/home_page.dart';


class AppConfiguration {

	static StatelessWidget getConfiguredApp () {
		return MyApp(getHomePageConfigured());
	}

	static HomePage getHomePageConfigured () {
		return HomePage(getConfiguredHomePageModel());
	}

	static HomePageModel getConfiguredHomePageModel () {
		return HomePageModel(
			getConfiguredAdviceReader(),
			getConfiguredRandom()
		);
	}

	static AdviceReader getConfiguredAdviceReader () {
		return AdviceReader(getConfiguredOnlineDB(), getConfiguredLocalDB());
	}

	static LocalDB getConfiguredLocalDB () {
		return LocalDB();
	}

	static OnlineDB getConfiguredOnlineDB () {
		return OnlineDB();
	}

	static Random getConfiguredRandom () {
		return Random();
	}
}

