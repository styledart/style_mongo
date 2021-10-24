import 'dart:async';

import 'package:style_dart/style_dart.dart';
import 'package:style_mongo/src/style_mongo_base.dart';

void main() {
  runService(_MongoDbTest());

  // initStyleTester("db", _MongoDbTest(), (t) {
  //   t("/read/follows", bodyIs("body"),
  //       body: where.eq("mehmet", "yaz").map["\$query"]);
  // });
}

class _MongoDbTest extends StatelessComponent {
  const _MongoDbTest({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        dataAccess: DataAccess(MongoDbDataAccessImplementation(
            "mongodb://167.86.87.39:9098/berber-db?compressors=disabled&gssapiServiceName=mongodb")),
        children: [
          Route("read", child: RouteTo("{collection}", root: ReadEndpoint()))
        ]);
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
            query: Query(selector: request.path.queryParameters)),
        context: context,
        request: request));
    return request.response(res.data);
  }
}
