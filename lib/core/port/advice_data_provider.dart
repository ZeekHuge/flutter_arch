import 'package:splash_on_flutter/core/valueobject/data_valueobject.dart';

abstract class FetchNewAdviceSlip {
	Future<Slip> getNewAdviceSlip ();
}


abstract class CurrentAdviceSlip {
  Future<void> writeSlip(Slip slip);
  Future<Slip> readSlip();
}
