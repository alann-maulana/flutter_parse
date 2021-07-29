///  A ParseException gets raised whenever a [ParseObject] issues an invalid request, such as
///  deleting or editing an object that no longer exists on the server, or when there is a network
///  failure preventing communication with the Parse server.
class ParseException implements Exception {
  /// Error code indicating another cause.
  static const int otherCause = -1;

  /// Error code indicating the connection to the Parse servers failed.
  static const int connectionFailed = 100;

  /// Error code indicating the specified object doesn't exist.
  static const int objectNotFound = 101;

  /// Error code indicating you tried to query with a datatype that doesn't support it, like exact
  /// matching an array or object.
  static const int invalidQuery = 102;

  /// Error code indicating a missing or invalid classname. ClassNames are case-sensitive. They must
  /// start with a letter, and a-zA-Z0-9_ are the only valid characters.
  static const int invalidClassName = 103;

  /// Error code indicating an unspecified object id.
  static const int missingObjectId = 104;

  /// Error code indicating an invalid key name. Keys are case-sensitive. They must start with a
  /// letter, and a-zA-Z0-9_ are the only valid characters.
  static const int invalidKeyName = 105;

  /// Error code indicating a malformed pointer. You should not see this unless you have been mucking
  /// about changing internal Parse code.
  static const int invalidPointer = 106;

  /// Error code indicating that badly formed JSON was received upstream. This either indicates you
  /// have done something unusual with modifying how things encode to JSON, or the network is failing
  /// badly.
  static const int invalidJson = 107;

  /// Error code indicating that the feature you tried to access is only available internally for
  /// testing purposes.
  static const int commandUnavailable = 108;

  /// You must call [Parse.initialize] before using the Parse library.
  static const int notInitialized = 109;

  /// Error code indicating that a field was set to an inconsistent type.
  static const int incorrectType = 111;

  /// Error code indicating an invalid channel name. A channel name is either an empty string (the
  /// broadcast channel) or contains only a-zA-Z0-9_ characters and starts with a letter.
  static const int invalidChannelName = 112;

  /// Error code indicating that push is misconfigured.
  static const int pushMisconfigured = 115;

  /// Error code indicating that the object is too large.
  static const int objectTooLarge = 116;

  /// Error code indicating that the operation isn't allowed for clients.
  static const int operationForbidden = 119;

  /// Error code indicating the result was not found in the cache.
  static const int cacheMiss = 120;

  /// Error code indicating that an invalid key was used in a nested JSONObject.
  static const int invalidNestedKey = 121;

  /// Error code indicating that an invalid filename was used for ParseFile. A valid file name
  /// contains only a-zA-Z0-9_. characters and is between 1 and 128 characters.
  static const int invalidFileName = 122;

  /// Error code indicating an invalid ACL was provided.
  static const int invalidAcl = 123;

  /// Error code indicating that the request timed out on the server. Typically this indicates that
  /// the request is too expensive to run.
  static const int timeout = 124;

  /// Error code indicating that the email address was invalid.
  static const int invalidEmailAddress = 125;

  /// Error code indicating that required field is missing.
  static const int missingRequiredFieldError = 135;

  /// Error code indicating that a unique field was given a value that is already taken.
  static const int duplicateValue = 137;

  /// Error code indicating that a role's name is invalid.
  static const int invalidRoleName = 139;

  /// Error code indicating that an application quota was exceeded. Upgrade to resolve.
  static const int exceededQuota = 140;

  /// Error code indicating that a Cloud Code script failed.
  static const int scriptError = 141;

  /// Error code indicating that cloud code validation failed.
  static const int validationError = 142;

  /// Error code indicating that deleting a file failed.
  static const int fileDeleteError = 153;

  /// Error code indicating that the application has exceeded its request limit.
  static const int requestLimitExceeded = 155;

  /// Error code indicating that the provided event name is invalid.
  static const int invalidEventName = 160;

  /// Error code indicating that the username is missing or empty.
  static const int usernameMissing = 200;

  /// Error code indicating that the password is missing or empty.
  static const int passwordMissing = 201;

  /// Error code indicating that the username has already been taken.
  static const int usernameTaken = 202;

  /// Error code indicating that the email has already been taken.
  static const int emailTaken = 203;

  /// Error code indicating that the email is missing, but must be specified.
  static const int emailMissing = 204;

  /// Error code indicating that a user with the specified email was not found.
  static const int emailNotFound = 205;

  /// Error code indicating that a user object without a valid session could not be altered.
  static const int sessionMissing = 206;

  /// Error code indicating that a user can only be created through signup.
  static const int mustCreateUserThroughSignUp = 207;

  /// Error code indicating that an an account being linked is already linked to another user.
  static const int accountAlreadyLinked = 208;

  /// Error code indicating that the current session token is invalid.
  static const int invalidSessionToken = 209;

  /// Error code indicating that a user cannot be linked to an account because that account's id
  /// could not be found.
  static const int linkedIdMissing = 250;

  /// Error code indicating that a user with a linked (e.g. Facebook) account has an invalid session.
  static const int invalidLinkedSession = 251;

  /// Error code indicating that a service being linked (e.g. Facebook or Twitter) is unsupported.
  static const int unsupportedService = 252;

  /// Construct a new ParseException with a particular error code.
  @pragma("vm:entry-point")
  const ParseException({int? code, required this.message, this.data})
      : code = code ?? otherCause;

  /// Construct a new ParseException with an external cause.
  ParseException.fromThrow(dynamic e)
      : code = otherCause,
        message = (e is FormatException)
            ? e.message
            : e.toString().replaceFirst('Exception: ', ''),
        data = e;

  /// Access the code for this error.
  final int code;

  /// Access the message for this error
  final String message;

  /// Access the data for this error
  final dynamic data;

  @override
  String toString() {
    return 'ParseException{code: $code, message: $message}';
  }
}
