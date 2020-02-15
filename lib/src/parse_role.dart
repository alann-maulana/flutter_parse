import 'package:flutter_parse/flutter_parse.dart';

import 'parse_acl.dart';

class ParseRole {
  ParseRole.fromMap(dynamic map)
      : objectId = map['objectId'],
        name = map['name'],
        acl = ParseACL.fromMap(map['ACL']),
        createdAt = map['createdAt'],
        updatedAt = map['updatedAt'];

  final String objectId;
  final String name;
  final ParseACL acl;
  final DateTime createdAt;
  final DateTime updatedAt;

  static ParseQuery get query => ParseQuery(className: '_Role');
}
