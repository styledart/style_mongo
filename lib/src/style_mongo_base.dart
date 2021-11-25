import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:style_dart/style_dart.dart' hide State;
import 'package:style_mongo/src/mongo_query.dart';
import 'package:style_mongo/src/mongodb_operation_settings.dart';

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

  SelectorBuilder buildQuery(Access access) {
    if (access.query is MongoQuery) {
      return (access.query as MongoQuery).selectorBuilder;
    }
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
    if (access.settings != null && access.settings is! MongoDbCreateSettings) {
      throw ArgumentError(
          "Create settings must be null or MongoDbCreateSettings");
    }
    var settings = access.settings as MongoDbCreateSettings?;
    if (access.data is List) {
      for (var d in access.data as List) {
        d["_id"] ??= ObjectId().toJson();
      }

      await db.collection(access.collection).insertAll(
          (access.data as List).cast<Map<String, dynamic>>(),
          writeConcern: settings?.writeConcern);
      return CreateDbResult(identifier: null);
    } else {
      access.data!["_id"] ??= ObjectId().toJson();
      /*var res = */
      await db
          .collection(access.collection)
          .insert(access.data!, writeConcern: settings?.writeConcern);
      // print("CREATE DB: $res");
      return CreateDbResult(identifier: null);
    }
  }

  @override
  FutureOr<DeleteDbResult> delete(Access access) async {
    if (access.query == null) {
      throw ArgumentError("Delete calling without Access.query");
    }

    if (access.settings != null && access.settings is! MongoDbDeleteSettings) {
      throw ArgumentError(
          "Delete settings must be null or MongoDbDeleteSettings");
    }

    var settings = access.settings as MongoDbDeleteSettings?;

    if (settings?.many ?? false) {
      await db.collection(access.collection).deleteMany(buildQuery(access),
          writeConcern: settings?.writeConcern,
          collation: settings?.collation,
          hint: settings?.hint,
          hintDocument: settings?.hintDocument);
      return DeleteDbResult(exists: true);
    } else {
      /*var res =*/
      await db.collection(access.collection).deleteOne(buildQuery(access),
          writeConcern: settings?.writeConcern,
          collation: settings?.collation,
          hint: settings?.hint,
          hintDocument: settings?.hintDocument);
      /*print("Delete DB: ${res.serverResponses}");*/
      return DeleteDbResult(exists: true);
    }
  }

  @override
  FutureOr<ReadDbResult> read(Access access) async {
    if (access.query == null) {
      throw ArgumentError("Read calling without Access.query");
    }

    if (access.settings != null && access.settings is! MongoDbFindSettings) {
      throw ArgumentError("Read settings must be null or MongoDbFindSettings");
    }

    var settings = access.settings as MongoDbFindSettings?;

    var res = await db.collection(access.collection).modernFindOne(
        selector: buildQuery(access),
        hintDocument: settings?.hintDocument,
        hint: settings?.hint,
        filter: settings?.filter,
        findOptions: settings?.findOptions,
        projection: settings?.projection,
        rawOptions: settings?.rawOptions,
        skip: settings?.skip,
        sort: settings?.sort);
    // print("Read DB: $res");
    return ReadDbResult(success: true, data: res);
  }

  @override
  FutureOr<ReadListResult> readList(Access access) async {
    if (access.query == null) {
      throw ArgumentError("Read calling without Access.query");
    }

    if (access.settings != null && access.settings is! MongoDbFindSettings) {
      throw ArgumentError("Read settings must be null or MongoDbFindSettings");
    }

    var settings = access.settings as MongoDbFindSettings?;

    var res = await db
        .collection(access.collection)
        .modernFind(
            selector: buildQuery(access),
            hintDocument: settings?.hintDocument,
            hint: settings?.hint,
            filter: settings?.filter,
            findOptions: settings?.findOptions,
            projection: settings?.projection,
            rawOptions: settings?.rawOptions,
            skip: settings?.skip,
            sort: settings?.sort)
        .toList();
/*    print("Read List DB: ${res.runtimeType} $res");*/
    return ReadListResult(success: true, data: res);
  }

  @override
  FutureOr<UpdateDbResult> update(Access access) async {
    if (access.query == null || access.data == null) {
      throw ArgumentError("Read calling without Access.query");
    }

    if (access.settings != null && access.settings is! MongoDbUpdateSettings) {
      throw ArgumentError(
          "Update settings must be null or MongoDbFindSettings");
    }

    var settings = access.settings as MongoDbUpdateSettings?;

    /*var res = */
    await db.collection(access.collection).modernUpdate(
        buildQuery(access), access.data!,
        hint: settings?.hint,
        hintDocument: settings?.hintDocument,
        collation: settings?.collation,
        writeConcern: settings?.writeConcern,
        arrayFilters: settings?.arrayFilters,
        multi: settings?.multi,
        upsert: settings?.upsert);
    // print("Update DB: : ${res.runtimeType} $res");
    return UpdateDbResult();
  }

  @override
  FutureOr<DbResult<int>> count(Access access) async {
    var res = await db
        .collection(access.collection)
        .count(access.query != null ? buildQuery(access) : null);
    // print("Count DB: $res");
    return DbResult<int>(success: true, data: res);
  }

  @override
  FutureOr<DbResult<bool>> exists(Access access) async {
    var res = await db
        .collection(access.collection)
        .count(access.query != null ? buildQuery(access) : null);
    return DbResult<bool>(success: true, data: res > 0);
  }

  @override
  FutureOr<ReadListResult> aggregation(Access access) async {
    if (access.pipeline == null) {
      throw ArgumentError("Aggregate calling without Access.pipeline");
    }

    if (access.settings != null &&
        access.settings is! MongoDbAggregationSettings) {
      throw ArgumentError(
          "Update settings must be null or MongoDbFindSettings");
    }

    var settings = access.settings as MongoDbAggregationSettings?;

    return ReadListResult(
        data: await db
            .collection(access.collection)
            .modernAggregate(access.pipeline,
                hintDocument: settings?.hintDocument,
                hint: settings?.hint,
                rawOptions: settings?.rawOptions,
                aggregateOptions: settings?.aggregateOptions,
                cursor: settings?.cursor,
                explain: settings?.explain)
            .toList());
  }
}
