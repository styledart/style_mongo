import 'dart:async';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:style_dart/style_dart.dart';
import 'package:style_mongo/src/style_mongo_base.dart';
import 'package:style_test/style_test.dart';
import 'package:test/expect.dart';

void main() {

  /*
  * -   1.15 s
            _passed_testing: /c/follows
        -   79 ms
            _passed_testing: /r/follows
        -   78 ms
            _passed_testing: /u/follows
        -   76 ms
            _passed_testing: /r/follows
        -   78 ms
            _passed_testing: /d/follows
        -   79 ms
            _passed_testing: /e/follows
  * */



  initStyleTester("db", _MongoDbTest(), (tester) {
    tester("/c/follows", statusCodeIs(201), body: {
      "data": {"name": "Mehmet", "lastName": "Yaz"}
    });
    tester("/r/follows", bodyIs(containsPair("name", "Mehmet")),
        body: where.eq("name", "Mehmet").map);

    tester("/u/follows", statusCodeIs(200),
        body: where.eq("name", "Mehmet").map
          ..addAll({
            "data": {
              "\$set": {"lastName": "Style"}
            }
          }));
    tester("/r/follows", bodyIs(containsPair("lastName", "Style")),
        body: where.eq("name", "Mehmet").map);
    tester("/d/follows", statusCodeIs(200),
        body: where.eq("name", "Mehmet").map);
    tester("/e/follows", bodyIs(false), body: where.eq("name", "Mehmet").map);
  });
}

class _MongoDbTest extends StatelessComponent {
  const _MongoDbTest({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        dataAccess: DataAccess(MongoDbDataAccessImplementation(File(
                "D:\\style_packages\\style_mongo\\secret\\mongo_connection.txt")
            .readAsStringSync())),
        children: [
          Route("{type}", child: RouteTo("{collection}", root: MyAccessPoint()))
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
    "co": AccessType.count
  };

  @override
  Component build(BuildContext context) {
    return AccessPoint((req) {
      if (req.body is! JsonBody) {
        throw BadRequests();
      }
      var type = _types[req.arguments["type"]];
      if (type == null) {
        throw BadRequests();
      }
      var body = (req.body as JsonBody).data;
      return AccessEvent(
          access: Access(
              collection: req.arguments["collection"],
              type: type,
              data: body["data"],
              query: Query(
                selector: body["\$query"],
                limit: body["l"],
                offset: body["o"],
                sort: body["orderBy"],
                fields: body["f"],
              )),
          context: context,
          request: req);
    });
  }
}

/// TODO: Document
class ReadEndpoint extends Endpoint {
  ReadEndpoint() : super();

  @override
  FutureOr<Message> onCall(Request request) async {
    var db = context.dataAccess;
    var res = await db.read(AccessEvent(
        access: Access(
            type: AccessType.read,
            collection: request.arguments["collection"],
            query: Query(selector: request.body?.data as Map<String, dynamic>)),
        context: context,
        request: request));
    return request.response(res.data);
  }
}
