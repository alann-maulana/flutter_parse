import 'package:flutter_parse/flutter_parse.dart';

/// Represents a Role on the Parse server. [ParseRole]s represent groupings of
/// [ParseUser]s for the purposes of granting permissions (e.g. specifying a [ParseACL]
/// for a [ParseObject]). Roles are specified by their sets of child users and child roles, all
/// of which are granted any permissions that the parent role has.
///
/// Roles must have a name (which cannot be changed after creation of the role), and must specify an
/// ACL.
class ParseRole extends ParseObject {
  static const kClassName = '_Role';

  /// Constructs a new [ParseRole] with JSON.
  ParseRole({required dynamic json})
      : name = json['name'],
        acl = ParseACL.fromMap(json['ACL']),
        super(className: kClassName, json: json);

  /// Factory constructor of a new [ParseRole] with JSON.
  factory ParseRole.fromJson({required dynamic json}) {
    return ParseRole(json: json);
  }

  /// Constructs a new [ParseRole] with the given name.
  ParseRole.create(this.name, this.acl) : super(className: kClassName);

  /// The name of this Role
  final String name;

  /// The default [ParseACL] of this Role
  final ParseACL acl;

  /// Return map of pointer
  @override
  dynamic get asMap => <String, dynamic>{
        '__type': 'Pointer',
        'className': kClassName,
        'objectId': objectId,
      };

  static ParseQuery<ParseRole> get query => ParseQuery<ParseRole>();
}
