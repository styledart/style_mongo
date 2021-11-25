# style_mongo

Style mongo is a ``DataAccess`` implementation for [style_dart](https://pub.dev/packages/style_dart).

## Usage

### Put To Component Tree

````dart
@override
Component build(BuildContext context) {
  return Server(
      dataAccess: DataAccess(
          MongoDbDataAccessImplementation("<connection-string>")
      ),
      children: [
        //...
      ]);
}
````

OR

````dart

@override
Component build(BuildContext context) {
  return ServiceWrapper<DataAccess>(
    service: DataAccess(
        MongoDbDataAccessImplementation("<connection-string>")
    ),
    child: YourChildComponent(),
  );
}


````

### Operate

````dart
FutureOr<Object> onCall(Request request) {
  return Access(
    collection: "<collection>",
    type: type,

    // optional. necessary for some operations
    // you can also use "Query" 
    query: MongoQuery(where.eq("field", "value")),
    
    // optional. necessary for aggregation
    pipeline: AggregationPipelineBuilder(/*stages*/),
    // or pipeline: [{"\$project" : {"_id":0}}]
  );
}
````

**You can operate with any different styles like ``DataAccess.of(ctx).read(..)`` .**

**Using with `Query`, `selector` parameter must be mongo db style Map.
So must be `where.eq("field", "value").map["\$query"]`.**

### Settings

MongoDb have many operation settings like WriteConcern.
You can set this settings with:

````dart
f(){
  final access = Access(
      settings: MongoDbFindSettings(findOptions: FindOptions(returnKey: true))
    //...
  );
}
````

There is settings for all operations, except count and exists

## Example Usage with AccessPoint

Check Example

