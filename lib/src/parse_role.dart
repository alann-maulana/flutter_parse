import 'package:flutter_parse/flutter_parse.dart';

import 'parse_acl.dart';

class ParseRole extends ParseObject {
  ParseRole({required dynamic json})
      : name = json['name'],
        acl = ParseACL.fromMap(json['ACL']),
        super(className: '_Role', json: json);

  factory ParseRole.fromJson({required dynamic json}) {
    return ParseRole(json: json);
  }

  final String name;
  final ParseACL acl;

  @override
  dynamic get asMap => <String, dynamic>{
        '__type': 'Pointer',
        'className': '_Role',
        'objectId': objectId,
      };

  static ParseQuery get query => ParseQuery(className: '_Role');
}
