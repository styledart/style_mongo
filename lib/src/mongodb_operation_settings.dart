import 'package:mongo_dart/mongo_dart.dart';
import 'package:style_dart/style_dart.dart';

class MongoDbFindSettings extends OperationSettings {
  MongoDbFindSettings(
      {this.filter,
      this.findOptions,
      this.hint,
      this.hintDocument,
      this.limit,
      this.projection,
      this.rawOptions,
      this.skip,
      this.sort});

  Map<String, Object>? filter;
  Map<String, Object>? sort;
  Map<String, Object>? projection;
  String? hint;
  Map<String, Object>? hintDocument;
  int? skip;
  int? limit;
  FindOptions? findOptions;
  Map<String, Object>? rawOptions;
}

class MongoDbUpdateSettings extends OperationSettings {
  MongoDbUpdateSettings(
      {this.hintDocument,
      this.hint,
      this.writeConcern,
      this.arrayFilters,
      this.collation,
      this.multi,
      this.upsert});

  bool? upsert;
  bool? multi;
  WriteConcern? writeConcern;
  CollationOptions? collation;
  List<dynamic>? arrayFilters;
  String? hint;
  Map<String, Object>? hintDocument;
}

class MongoDbAggregationSettings extends OperationSettings {
  MongoDbAggregationSettings(
      {this.hintDocument,
      this.hint,
      this.rawOptions,
      this.aggregateOptions,
      this.cursor,
      this.explain});

  bool? explain;
  Map<String, Object>? cursor;
  String? hint;
  Map<String, Object>? hintDocument;
  AggregateOptions? aggregateOptions;
  Map<String, Object>? rawOptions;
}

class MongoDbDeleteSettings extends OperationSettings {
  MongoDbDeleteSettings(
      {this.hintDocument,
      this.many,
      this.hint,
      this.collation,
      this.writeConcern});

  bool? many;
  WriteConcern? writeConcern;
  CollationOptions? collation;
  String? hint;
  Map<String, Object>? hintDocument;
}

class MongoDbCreateSettings extends OperationSettings {
  MongoDbCreateSettings({this.writeConcern});

  WriteConcern? writeConcern;
}
