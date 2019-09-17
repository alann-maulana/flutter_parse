part of flutter_parse;

class ParseException implements Exception {
  static const int OtherCause = -1;
  static const int ConnectionFailed = 100;
  static const int ObjectNotFound = 101;
  static const int InvalidQuery = 102;
  static const int InvalidClassName = 103;
  static const int MissingObjectId = 104;
  static const int InvalidKeyName = 105;
  static const int InvalidPointer = 106;
  static const int InvalidJson = 107;
  static const int CommandUnavailable = 108;
  static const int NotInitialized = 109;
  static const int IncorrectType = 111;
  static const int InvalidChannelName = 112;
  static const int PushMisconfigured = 115;
  static const int ObjectTooLarge = 116;
  static const int OperationForbidden = 119;
  static const int CacheMiss = 120;
  static const int InvalidNestedKey = 121;
  static const int InvalidFileName = 122;
  static const int InvalidAcl = 123;
  static const int Timeout = 124;
  static const int InvalidEmailAddress = 125;
  static const int MissingRequiredFieldError = 135;
  static const int DuplicateValue = 137;
  static const int InvalidRoleName = 139;
  static const int ExceededQuota = 140;
  static const int ScriptError = 141;
  static const int ValidationError = 142;
  static const int FileDeleteError = 153;
  static const int RequestLimitExceeded = 155;
  static const int InvalidEventName = 160;
  static const int UsernameMissing = 200;
  static const int PasswordMissing = 201;
  static const int UsernameTaken = 202;
  static const int EmailTaken = 203;
  static const int EmailMissing = 204;
  static const int EmailNotFound = 205;
  static const int SessionMissing = 206;
  static const int MustCreateUserThroughSignup = 207;
  static const int AccountAlreadyLinked = 208;
  static const int InvalidSessionToken = 209;
  static const int LinkedIdMissing = 250;
  static const int InvalidLinkedSession = 251;
  static const int UnsupportedService = 252;

  @pragma("vm:entry-point")
  const ParseException({int code, this.message})
      : assert(message != null),
        code = code ?? OtherCause;

  ParseException.fromThrow(Exception e)
      : code = OtherCause,
        message = e.toString();

  final int code;
  final String message;

  @override
  String toString() {
    return 'ParseException{code: $code, message: $message}';
  }
}
