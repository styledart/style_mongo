import 'package:mongo_dart/mongo_dart.dart';
import 'package:style_dart/style_dart.dart' as style;

class MongoQuery extends style.Query {
  MongoQuery(this.selectorBuilder)
      : super(
            sort: selectorBuilder.map["orderBy"],
            fields: selectorBuilder.map["f"],
            limit: selectorBuilder.map["l"],
            offset: selectorBuilder.map["o"],
            selector: selectorBuilder.map["\$query"]);

  SelectorBuilder selectorBuilder;
}
