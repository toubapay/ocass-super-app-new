class ResponseModel {
  final bool? _isSuccess;
  final String? _message;
  final Map<String, dynamic>? _content;

  ResponseModel(this._isSuccess, this._message, [this._content]);

  String? get message => _message;
  bool? get isSuccess => _isSuccess;
  Map<String, dynamic>? get content => _content;
}
