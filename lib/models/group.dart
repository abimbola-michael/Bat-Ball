// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Group {
  String group_id = "";
  String groupname = "";
 Group({
    required this.group_id,
    required this.groupname,
  });
  

  Group copyWith({
    String? group_id,
    String? groupname,
  }) {
    return Group(
      group_id: group_id ?? this.group_id,
      groupname: groupname ?? this.groupname,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'group_id': group_id,
      'groupname': groupname,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      group_id: (map["group_id"] ?? '') as String,
      groupname: (map["groupname"] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Group.fromJson(String source) => Group.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Group(group_id: $group_id, groupname: $groupname)';

  @override
  bool operator ==(covariant Group other) {
    if (identical(this, other)) return true;
  
    return 
      other.group_id == group_id &&
      other.groupname == groupname;
  }

  @override
  int get hashCode => group_id.hashCode ^ groupname.hashCode;
}

