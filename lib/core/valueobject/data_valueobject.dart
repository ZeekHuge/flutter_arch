import 'package:meta/meta.dart';

@immutable
class Slip {

	final String _advice;

	Slip(this._advice);

	String get advice => _advice;
}