import 'dart:io';

import 'package:crawller_backend/_common/util/AuthUtil.dart';
import 'package:crawller_backend/_common/util/LogUtil.dart';
import 'package:crawller_backend/_common/util/PuppeteerUtil.dart';
import 'package:crawller_backend/_common/util/hive/HiveUtil.dart';
import 'package:crawller_backend/repository/KeywordItemRepository.dart';
import 'package:crawller_backend/repository/RemovalConditionRepository.dart';
import 'package:crawller_backend/repository/SettingRepository.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf.dart' as shelf;

class SumgoCrawllerService {
  final PuppeteerUtil p;
  final Duration delay;
  final Duration timeout;

  static final SumgoCrawllerService _singleton =
      SumgoCrawllerService._internal();

  static SumgoCrawllerService get me => _singleton;

  SumgoCrawllerService._internal()
      : this.p = PuppeteerUtil(),
        this.delay = const Duration(milliseconds: 100),
        this.timeout = Duration(seconds: 20);

  Future<shelf.Response> route(
      String endPoint, Map<String, String> queryParameters) async {
    if (endPoint == "crawll") {
      return await crawll(queryParameters["settingDocumentId"],
          queryParameters["firebaseAuthEmail"]);
    } else {
      return shelf.Response.forbidden('crawll fail');
    }
  }

  Future<shelf.Response> crawll(
      String? settingDocumentIdStr, String? firebaseAuthEmail) async {
    await HiveUtil.init();
    await AuthUtil().init();

    if (settingDocumentIdStr == null) {
      return shelf.Response.forbidden('settingDocumentIdStr is null');
    }
    if (firebaseAuthEmail == null) {
      return shelf.Response.forbidden('firebaseAuthEmail is null');
    }

    int? settingDocumentId = int.tryParse(settingDocumentIdStr);
    if (settingDocumentId == null) {
      return shelf.Response.forbidden('settingDocumentId is null');
    }

    Map<String, String> evnVars = Platform.environment;
    await AuthUtil().loginWithEmail(
        evnVars["firebaseEmail"]!, evnVars["firebasePassword"]!);

    Setting? setting =
        await SettingRepository().getOne(documentId: settingDocumentId);
    if (setting == null) {
      return shelf.Response.forbidden('setting??? ????????????.');
    }

    await p.startBrowser(
      headless: true,
      browserUrl: setting.crallwerUrl,
    );

    await _login(setting.sumgoId ?? "", setting.sumgoPw ?? "");

    await _deleteAndSendRequests(firebaseAuthEmail);

    await p.stopBrowser();

    return shelf.Response.ok('crawll ???');
  }

  Future<void> _login(String? id, String? pw) async {
    for (int i = 0; i < 5; i++) {
      await p.goto('https://soomgo.com/requests/received');
      if (await _isLoginSuccess()) {
        LogUtil.info("????????? ??????");
        break;
      }

      LogUtil.info("????????? ?????????");
      await p.type('[name="email"]', id ?? "", delay: delay);
      await p.type('[name="password"]', pw ?? "", delay: delay);
      await p.clickAndWaitForNavigation('.btn.btn-login.btn-primary',
          timeout: timeout);
    }
  }

  Future<bool> _isLoginSuccess() async {
    bool isLoginPage = await p.existTag(".login-page");
    return !isLoginPage;
  }

  Future<void> _deleteRequest(ElementHandle tag, String requestContent) async {
    LogUtil.info("_deleteRequest requestContent:${requestContent}");

    await p.click('.quote-btn.del', tag: tag);
    await p.click('.swal2-confirm.btn');
  }

  Future<void> _sendRequests(ElementHandle tag, String requestContent) async {
    LogUtil.info("_sendRequests requestContent:${requestContent}");
    //????????????????????????
    await tag.click();
    await p.waitForNavigation();

    //????????????
    await p.click('.quote-tmpl-icon.arrow');
    await p.click('.item-list .item-short:nth-child(1)');
    await p.click('.action-btn-wrap');
    await p.click('.swal2-confirm.btn');

    //???????????????
    await p.waitForSelector('.file-wrap .delete');
    await p.evaluate(
        "document.querySelector('.btn.btn-primary.btn-block').click();");
  }

  Future<void> _deleteAndSendRequests(String firebaseAuthEmail) async {
    LogUtil.info("_deleteAndSendRequests ??????");

    Future<bool> refreshAndExitIfShould() async {
      await p.goto('https://soomgo.com/requests/received');
      bool existSelector =
          await p.waitForSelector('.request-list > li > .request-item');
      if (!existSelector) {
        return true;
      }
      return false;
    }

    Future<List<ElementHandle>> getTagList() async =>
        await p.$$('.request-list > li > .request-item');

    Map<String, int> keywordMap = {};
    while (true) {
      if (await refreshAndExitIfShould()) break;
      List<ElementHandle> tagList = await getTagList();
      if (tagList.isEmpty) break;

      var tag = tagList[0];
      var messageTag = await p.$('.quote > span.message', tag: tag);
      String message = await p.text(messageTag);

      Future<Map<String, int>> countKeyword(String message) async {
        Map<String, int> keywordMap = {};
        for (var eachWord in message.trim().split(",")) {
          eachWord = eachWord.trim();
          if (!keywordMap.containsKey(eachWord)) {
            keywordMap[eachWord] = 0;
          }
          keywordMap[eachWord] = keywordMap[eachWord]! + 1;
        }
        LogUtil.info("keywordMap: $keywordMap");
        return keywordMap;
      }

      keywordMap.addAll(await countKeyword(message));

      await decideMethod(
        message,
        () async => await _sendRequests(tag, message),
        () async => await _deleteRequest(tag, message),
        firebaseAuthEmail,
      );
    }

    Future<void> saveFirestore(
        Map<String, int> keywordMap, String firebaseAuthEmail) async {
      for (var entry in keywordMap.entries) {
        String eachWord = entry.key;
        int count = entry.value;

        KeywordItem? keywordItem = await KeywordItemRepository()
            .getKeywordItem(email: firebaseAuthEmail, keyword: eachWord);
        if (keywordItem == null) {
          await KeywordItemRepository().add(
            keywordItem: KeywordItem(
              keyword: eachWord,
              count: count,
            ),
          );
        } else {
          await KeywordItemRepository().update(
            keywordItem
              ..keyword = eachWord
              ..count = ((keywordItem.count ?? 0) + count),
          );
        }
      }
    }

    await saveFirestore(keywordMap, firebaseAuthEmail);
  }

  Future<void> decideMethod(String message, Future<void> Function() send,
      Future<void> Function() delete, String firebaseAuthEmail) async {
    final List<String> listToIncludeAlways = (await RemovalConditionRepository()
            .getListByType(
                email: firebaseAuthEmail, type: RemovalType.best.value))
        .map((e) => e.content ?? "")
        .toList();
    final List<String> listToInclude = (await RemovalConditionRepository()
            .getListByType(
                email: firebaseAuthEmail, type: RemovalType.include.value))
        .map((e) => e.content ?? "")
        .toList();
    final List<String> listToExclude = (await RemovalConditionRepository()
            .getListByType(
                email: firebaseAuthEmail, type: RemovalType.exclude.value))
        .map((e) => e.content ?? "")
        .toList();

    //?????? ???????????? ????????? ?????? ????????? ?????????.
    for (String toIncludeAlways in listToIncludeAlways) {
      if (message.toLowerCase().contains(toIncludeAlways.toLowerCase())) {
        await send();
        return;
      }
    }

    //?????? ????????? ?????? ???????????? ???????????? ?????????.
    List<String> listToIncludeForOr =
        listToInclude.where((element) => element.contains("||")).toList();
    List<String> listToIncludeForAnd =
        listToInclude.where((element) => !element.contains("||")).toList();

    //?????? ????????? ??????????????? ?????????, ?????? ??????.
    bool isValid = true;
    for (String toIncludeForAnd in listToIncludeForAnd) {
      if (!message.toLowerCase().contains(toIncludeForAnd.toLowerCase())) {
        LogUtil.info(
            "condition1 message:$message, toIncludeForAnd:$toIncludeForAnd");
        isValid = false;
        break;
      }
    }
    //?????? ????????? ??????????????? ?????????, ?????? ??????.
    //1??? ????????? ?????? A||B||C??? ???, ???????????? A or B or C??? ??????????????? ?????????, ?????? ??????
    for (String toIncludeForOr in listToIncludeForOr) {
      List<String> orStrList = toIncludeForOr.split("||").toList();
      bool existOr = orStrList
          .where((orStr) => message.toLowerCase().contains(orStr.toLowerCase()))
          .isNotEmpty;
      if (!existOr) {
        LogUtil.info("condition2 message:$message, orStrList:$orStrList");
        isValid = false;
        break;
      }
    }
    //??? ???????????? ?????????, ????????????
    for (String toExclude in listToExclude) {
      if (message.toLowerCase().contains(toExclude.toLowerCase())) {
        LogUtil.info("condition3 message:$message, toExclude:$toExclude");
        isValid = false;
        break;
      }
    }

    if (isValid) {
      LogUtil.info("decideMethod send message:$message");
      await send();
    } else {
      LogUtil.info("decideMethod delete message:$message");
      await delete();
    }
  }
}
