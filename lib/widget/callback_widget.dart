
import 'package:flutter/widgets.dart';

typedef T GetCallback <T> (BuildContext context);

abstract class CallbackWidgetCaller<T> {
	void register (T callback);
	void unregister (T callback);
}

class CallbackWidget<T> extends StatefulWidget {

	final Widget child;
	final GetCallback<T> callbackImplementationGetter;
	final CallbackWidgetCaller callbackCaller;

	CallbackWidget({
		@required this.child,
		@required this.callbackImplementationGetter,
		@required this.callbackCaller
	});

    @override
    State<StatefulWidget> createState() {
        return _CallbackWidgetState();
    }
}


class _CallbackWidgetState<T> extends State<CallbackWidget> {

	T callback;

	@override
    Widget build(BuildContext context) {
		callback = widget.callbackImplementationGetter(context);
		widget.callbackCaller.register(callback);
		return widget.child;
    }

    @override
    void dispose() {
		widget.callbackCaller.unregister(callback);
		callback = null;
        super.dispose();
    }
}