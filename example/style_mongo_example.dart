import 'package:mongo_dart/mongo_dart.dart';
import 'package:style_dart/style_dart.dart';
import 'package:style_mongo/src/mongo_query.dart';
import 'package:style_mongo/src/style_mongo_base.dart';

/// In this example usage
///
/// Examples for client.
///
/// create:
///
/// ```http request
/// http://localhost/c/users
///
/// {
///   "data" : {
///     "name" : "Mehmet"
///   }
/// }
/// ```
///
/// read:
///
/// ```http request
/// http://localhost/r/users
///
/// {
///   "query" : where.eq("name" ,"Mehmet").map
/// }
/// ```
/// for more example look tests
void main() {
  runService(MongoDbExampleServer());
}

class MongoDbExampleServer extends StatelessComponent {
  const MongoDbExampleServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        dataAccess: DataAccess(MongoDbDataAccessImplementation(
            "mongodb://0.0.0.0:27017/demo_col")),
        children: [
          Route("{type}", child: Route("{collection}", root: MyAccessPoint()))
        ]);
  }
}

///
class MyAccessPoint extends StatelessComponent {
  final Map<String, AccessType> _types = {
    "r": AccessType.read,
    "c": AccessType.create,
    "u": AccessType.update,
    "d": AccessType.delete,
    "rl": AccessType.readMultiple,
    "e": AccessType.exists,
    "co": AccessType.count,
    "a": AccessType.aggregation
  };

  @override
  Component build(BuildContext context) {
    return AccessPoint((req, c) {
      if (req.body != null && req.body is! JsonBody?) {
        print(req.body.runtimeType);
        throw BadRequests();
      }
      var type = _types[req.arguments["type"]];
      if (type == null) {
        throw BadRequests();
      }
      var body = (req.body as JsonBody?)?.data;
      return AccessEvent(
          access: Access(
              collection: req.arguments["collection"],
              type: type,
              data: body?["data"],
              pipeline: body?["pipeline"],
              query: body["query"] != null
                  ? MongoQuery(SelectorBuilder().raw(body["query"]))
                  : null),
          context: c,
          request: req);
    });
  }
}
