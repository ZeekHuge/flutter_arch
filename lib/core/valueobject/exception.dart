class InternetNotConnectedException implements Exception {
	String _cause;

	InternetNotConnectedException(this._cause);

	@override
	String toString() {
        return 'InternetNotConnectedException : ' + this._cause;
	}
}