// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:crawller_backend/_common/util/AuthUtil.dart';
import 'package:functions_framework/functions_framework.dart';
import 'package:crawller_backend/service/SumgoCrawllerService.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router app = Router()
      // ..get('/show', (Request request) {
      //   return Response.ok("Platform.environment : ${Platform.environment}");
      // })
      ..get('/sumgoApi/<endPoint>', (Request request, String endPoint) {
        return SumgoCrawllerService.me
            .route(endPoint, request.requestedUri.queryParameters);
      })
// ..get('/user/<user>', (Request request, String user) {
//   // fetch the user... (probably return as json)
//   return Response.ok('hello $user');
// })
// ..post('/user', (Request request) {
//   // convert request body to json and persist... (probably return as json)
//   return Response.ok('saved the user');
// })
    ;

@CloudFunction()
Future<Response> function(Request request) async =>await app.call(request);

// Overriding the default 'function' also works, but you will need
// to ensure to set the FUNCTION_TARGET environment variable for the
// process to 'handleGet' as well.
//@CloudFunction()
//Response handleGet(Request request) => Response.ok('Hello, World!');
