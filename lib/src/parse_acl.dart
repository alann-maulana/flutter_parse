part of flutter_parse;

class ParseACL {
  ParseACL() : _map = {'*': ACL()};

  ParseACL.fromACL(ParseACL acl) : _map = acl._map;

  ParseACL.fromUser(ParseUser user) : _map = {user.objectId: ACL()};

  factory ParseACL.fromMap(dynamic map) {
    final parseACL = ParseACL();

    if (map is Map<String, dynamic>) {
      map.forEach((key, value) {
        parseACL._map[key] = ACL.fromMap(value);
      });
    }

    return parseACL;
  }

  static ParseACL _defaultACL = ParseACL();
  static bool _withAccessForCurrentUser = false;

  final Map<String, ACL> _map;

  ACL get publicAccess => _map['*'];
  set publicAccess(ACL acl) => _map['*'] = acl;

  ACL userAccess(ParseUser user) => _map[user.objectId];
  void setUserAccess(ParseUser user, ACL acl) => _map[user.objectId] = acl;

  ACL roleAccess(ParseRole role) => _map['role:${role.name}'];
  void setRoleAccess(ParseRole role, ACL acl) =>
      _map['role:${role.name}'] = acl;

  dynamic get map => _map.map((k, v) => MapEntry(k, v.map));

  static void setDefaultACL(ParseACL acl, bool withAccessForCurrentUser) {
    _defaultACL = ParseACL.fromACL(acl);
    _withAccessForCurrentUser = withAccessForCurrentUser;
  }

  static ParseACL getDefaultACL({ParseUser currentUser}) {
    ParseACL acl = _defaultACL;
    if (acl != null && currentUser != null && _withAccessForCurrentUser) {
      acl.setUserAccess(currentUser, ACL());
    }

    return acl;
  }
}

class ACL {
  ACL({this.read = true, this.write = true});

  ACL.fromMap(dynamic map) : this(read: map['read'], write: map['write']);

  final bool read;

  final bool write;

  dynamic get map {
    final map = <String, bool>{};

    if (read != null) {
      map['read'] = read;
    }

    if (write != null) {
      map['write'] = write;
    }

    return map;
  }
}
