
import 'package:shelf/shelf.dart';

class SumgoCrawllerService {
  static final SumgoCrawllerService _singleton = SumgoCrawllerService._internal();
  static SumgoCrawllerService get me=>_singleton;

  SumgoCrawllerService._internal();

  Future<Response> route(String endPoint) async {
    if(endPoint == "test") {
     return Response.ok('sumgo success');
    }
    else {
      return Response.forbidden('sumgo error');
    }
  }
}