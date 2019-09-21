part of flutter_parse;

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
}
