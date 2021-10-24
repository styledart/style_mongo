import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:style_dart/style_dart.dart' hide State;

class MongoDbDataAccessImplementation extends DataAccessImplementation {
  MongoDbDataAccessImplementation(String db,
      {this.writeConcern = WriteConcern.ACKNOWLEDGED,
      this.secure = false,
      this.tlsAllowInvalidCertificates = false,
      this.tlsCAFile,
      this.tlsCertificateKeyFile,
      this.tlsCertificateKeyFilePassword})
      : db = Db(db);

  Db db;

  WriteConcern writeConcern;
  bool secure;
  bool tlsAllowInvalidCertificates;
  String? tlsCAFile;
  String? tlsCertificateKeyFile;
  String? tlsCertificateKeyFilePassword;

  @override
  FutureOr<bool> init() async {
    await db.open(
        secure: secure,
        tlsAllowInvalidCertificates: tlsAllowInvalidCertificates,
        tlsCAFile: tlsCAFile,
        tlsCertificateKeyFile: tlsCertificateKeyFile,
        tlsCertificateKeyFilePassword: tlsCertificateKeyFilePassword,
        writeConcern: writeConcern);

    return db.state == State.OPEN;
  }

  @override
  FutureOr<CreateDbResult> create(Access access) async {
    if (access.data == null) {
      throw ArgumentError("Create calling without Access.data");
    }

    access.data!["_id"] ??= ObjectId().toJson();

    var res = await db.collection(access.collection).insert(access.data!);
    print("CREATE DB: $res");
    return CreateDbResult(success: true, identifier: null);
  }

  @override
  FutureOr<DeleteDbResult> delete(Access access) async {
    if (access.query == null) {
      throw ArgumentError("Delete calling without Access.query");
    }
    var res =
        await db.collection(access.collection).deleteOne(buildQuery(access));
    print("Delete DB: $res");
    return DeleteDbResult(exists: true, operationSuccess: true);
  }

  SelectorBuilder buildQuery(Access access) {
    var s = SelectorBuilder()
      ..map["\$query"] = access.query?.selector
      ..map["orderBy"] = access.query?.sort;

    if (access.query?.limit != null) {
      s.paramLimit = access.query!.limit!;
    }
    if (access.query?.offset != null) {
      s.paramSkip = access.query!.offset!;
    }
    if (access.query?.fields != null) {
      s.paramFields.addAll(access.query!.fields!.cast<String, Object>());
    }

    return s;
  }

  @override
  FutureOr<ReadDbResult> read(Access access) async {
    if (access.query == null) {
      throw ArgumentError("Read calling without Access.query");
    }
    var res = await db
        .collection(access.collection)
        .modernFindOne(selector: buildQuery(access));
    print("Read DB: $res");
    return ReadDbResult(success: true, data: res);
  }

  @override
  FutureOr<ReadListResult> readList(Access access) async {
    if (access.query == null) {
      throw ArgumentError("Read calling without Access.query");
    }
    var res = await db
        .collection(access.collection)
        .modernFind(selector: buildQuery(access))
        .toList();
    print("Read List DB: ${res.runtimeType} $res");
    return ReadListResult(success: true, data: res);
  }

  @override
  FutureOr<UpdateDbResult> update(Access access) async {
    if (access.query == null || access.data == null) {
      throw ArgumentError("Read calling without Access.query");
    }
    var res = await db
        .collection(access.collection)
        .modernUpdate(buildQuery(access), access.data!);
    print("Update DB: : ${res.runtimeType} $res");
    return UpdateDbResult(success: true);
  }

  @override
  FutureOr<DbResult<int>> count(Access access) async {
    var res = await db
        .collection(access.collection)
        .count(access.query != null ? buildQuery(access) : null);
    print("Count DB: $res");
    return DbResult<int>(success: true, data: res);
  }

  @override
  FutureOr<DbResult<bool>> exists(Access access) async {
    var res = await db
        .collection(access.collection)
        .count(access.query != null ? buildQuery(access) : null);
    print("Exists DB: $res");
    return DbResult<bool>(success: true, data: res > 0);
  }
}
