import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:style_dart/style_dart.dart';
import 'package:style_mongo/src/mongo_query.dart';
import 'package:style_mongo/src/style_mongo_base.dart';
import 'package:style_test/style_test.dart';

void main() async {
  await initStyleTester("db", _MongoDbTest(), (tester) async {
    /// create
    tester("/c/demo_col", statusCodeIs(201), body: {
      "data": {"name": "Mehmet", "lastName": "Yaz"}
    });

    /// read
    tester("/r/demo_col", bodyIs(containsPair("name", "Mehmet")),
        body: {"query": where.eq("name", "Mehmet").map});

    /// update
    tester("/u/demo_col", statusCodeIs(200), body: {
      "query": where.eq("name", "Mehmet").map,
      "data": {
        "\$set": {"lastName": "Style"}
      }
    });

    /// create_again
    tester("/c/demo_col", statusCodeIs(201), body: {
      "data": {"name": "John", "lastName": "Dalton"}
    });

    /// aggregate
    tester(
        "/a/demo_col",
        bodyIs([
          {"name": "Mehmet"},
          {"name": "John"}
        ]),
        body: {
          "pipeline": [
            {
              "\$project": {"_id": 0, "lastName": 0}
            }
          ]
        });

    /// delete
    tester("/d/demo_col", statusCodeIs(200),
        body: {"query": where.eq("name", "Mehmet").map});

    tester(
      "/co/demo_col",
      bodyIs(1), /*body: <String,dynamic>{}*/
    );

    /// delete
    tester("/d/demo_col", statusCodeIs(200),
        body: {"query": where.eq("name", "John").map});

    /// exists
    tester("/e/demo_col", bodyIs(false), body: where.eq("name", "Mehmet").map);
  });
}

class _MongoDbTest extends StatelessComponent {
  const _MongoDbTest({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        dataAccess: DataAccess(MongoDbDataAccessImplementation(File(
                "/home/mehmet/projects/style_packages/style_mongo/secret/mongo_connection.txt")
            .readAsStringSync())),
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
              query: body?["query"] != null
                  ? MongoQuery(SelectorBuilder().raw(body["query"]))
                  : null),
          context: c,
          request: req);
    });
  }
}
