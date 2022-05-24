import 'dart:io';

import 'package:puppeteer/plugins/stealth.dart';
import 'package:puppeteer/puppeteer.dart';

import 'LogUtil.dart';

class PuppeteerUtil {
  late Browser browser;
  late Page tab;

  final defaultTimeout = Duration(seconds: 10);

  Future<void> openBrowser(Future<void> Function() function,
      {int width = 1920,
      int height = 1600,
      bool headless = true,
      String? browserUrl}) async {
    await startBrowser(
        width: width,
        height: height,
        headless: headless,
        browserUrl: browserUrl);
    await function();
    await stopBrowser();
  }

  Future<void> startBrowser(
      {int width = 1920,
      int height = 1600,
      bool headless = true,
      String? browserUrl}) async {
    bool isConnect = (browserUrl ?? "").isNotEmpty;

    if (isConnect) {
      //크롬 바로가기 만들고, 거기에 "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222형태로 쓰면 됨.
      //이때, 크롬을 다 껏다가 해야함.
      browser = await puppeteer.connect(browserUrl: browserUrl!);
    } else {
      browser = await puppeteer.launch(
        headless: headless,
        args: [
          '--no-sandbox',
          '--window-size=$width,$height',
        ],
        userDataDir: "./browserData", //쿠키 유지 방법
        defaultViewport: DeviceViewport(
          width: width,
          height: height,
        ),
        plugins: [
          StealthPlugin()
        ], //스텔스 플러그인, 봇 아닌척하기 //https://github.com/berstend/puppeteer-extra/tree/master/packages/puppeteer-extra-plugin-stealth
      );

      //const browser = await puppeteer.launch({ignoreDefaultArgs: ["--enable-automation"]}); 이걸로 웹드라이버인 것을 숨길 수 있다.
    }
    tab = await browser.newPage();
    tab.defaultTimeout = defaultTimeout;
    // 이미지 로드 비활성화
    // await tab.setRequestInterception(true);
    // tab.onRequest.listen((request) {
    //   if (request.resourceType == ResourceType.image) request.abort();
    //   else request.continueRequest();
    // });
    /*
    애니메이션 멈추기
     page.on("load", () => {
    const content = `
    *,
    *::after,
    *::before {
        transition-delay: 0s !important;
        transition-duration: 0s !important;
        animation-delay: -0.0001s !important;
        animation-duration: 0s !important;
        animation-play-state: paused !important;
        caret-color: transparent !important;
    }`;

    page.addStyleTag({ content });
  });
     */
    // tab.emulate(puppeteer.devices.iPhone6);//모바일인척하기
    // await page.emulateMediaType(MediaType.screen); //화면 타입 변경

    //스크린샷찍고 저장하기
    // var screenshot = await page.screenshot();
    // await File('example/_github.png').writeAsBytes(screenshot);
    //   await myPage.pdf(); //pdf 만들기
    /*
    await page.pdf(
      format: PaperFormat.a4,
      printBackground: true,
      pageRanges: '1',
      output: File('example/_dart.pdf').openWrite());
     */

    /*
    여러 데이터 갖고오기
      var links = await page.evaluate(r'''resultsSelector => {
  const anchors = Array.from(document.querySelectorAll(resultsSelector));
  return anchors.map(anchor => {
    const title = anchor.textContent.split('|')[0].trim();
    return `${title} - ${anchor.href}`;
  });
}''', args: [resultsSelector]);
     */

    await setPageZoom();
  }

  Future<void> stopBrowser() async {
    try {
      await tab.close();
      await browser.close();
    } catch (e) {}
  }

  Future<Response> reload() async {
    return await tab.reload();
  }

  Future<void> goto(String url) async {
    await tab.goto(url, wait: Until.networkIdle, timeout: defaultTimeout);
  }

  Future<String> bodyText() async {
    return await tab.content ?? "";
  }

  Future<String> text(ElementHandle tag) async {
    return await evaluate(r'el => el.textContent', args: [tag]);
  }

  Future<String> getAttr(
      {required ElementHandle tag, required String attr}) async {
    return await evaluate('el => el.getAttribute("$attr")', args: [tag]);
  }

  Future<void> setAttr(
      {required ElementHandle tag,
      required String attr,
      required String attrValue}) async {
    return await evaluate('el => el.setAttribute("$attr","$attrValue")',
        args: [tag]);
  }

  Future<String> getHtml({required ElementHandle tag}) async {
    return await evaluate(r'el => el.innerHtml', args: [tag]);
  }

  Future<String> setHtml(
      {required ElementHandle tag, required String value}) async {
    return await evaluate(r'el => el.innerHtml="$value"', args: [tag]);
  }

  Future<dynamic> evaluate(String pageFunction, {List? args}) async {
    return await tab.evaluate(pageFunction, args: args);
  }

  Future<ElementHandle> evaluateHandle(String pageFunction,
      {List? args}) async {
    return await tab.evaluateHandle(pageFunction, args: args);
  }

  Future<void> type(String selector, String content, {Duration? delay}) async {
    await tab.type(selector, content, delay: delay);
  }

  Future<bool> existTag(String selector) async {
    return await evaluate("Boolean(document.querySelector('$selector'))");
  }

  Future<void> wait(double millseconds) async {
    await evaluate('''async () => {
      await new Promise(function(resolve) { 
            setTimeout(resolve, $millseconds)
      });
  }''');
  }

  Future<ElementHandle> $(String selector, {ElementHandle? tag}) async {
    // querySelector를 나타냄.
    if (tag != null) {
      return await tag.$(selector);
    } else {
      return await tab.$(selector);
    }
  }

  Future<List<ElementHandle>> $$(String selector, {ElementHandle? tag}) async {
    // querySelectorAll를 나타냄.
    if (tag != null) {
      return await tag.$$(selector);
    } else {
      return await tab.$$(selector);
    }
  }

  Future<bool> waitForSelector(String selector,
      {bool? visible,
      bool? hidden,
      Duration timeout = const Duration(seconds: 10)}) async {
    try {
      await tab.waitForSelector(selector,
          visible: visible, hidden: hidden, timeout: timeout);
      return true;
    } catch (e) {
      LogUtil.info("$selector 가 없습니다.: $e");
      return false;
    }
  }

  Future<void> click(String selector, {ElementHandle? tag}) async {
    try {
      if (tag == null) {
        await waitForSelector(selector);
      }
      var tagToClick = await $(selector, tag: tag);
      await tagToClick.click();
    } catch (e) {}
  }

  Future<Response?> clickAndWaitForNavigation(String selector,
      {Duration? timeout, Until? wait}) async {
    try {
      return await tab.clickAndWaitForNavigation(selector,
          timeout: timeout, wait: wait);
    } catch (e) {
      return null;
    }
  }

  Future<Response?> waitForNavigation({Duration? timeout, Until? wait}) async {
    try {
      return await tab.waitForNavigation(timeout: timeout, wait: wait);
    } catch (e) {
      return null;
    }
  }

  Future<bool> include(String selector, String text) async {
    return await evaluate(
        "(document.querySelector('$selector')?.innerText ?? '').includes('$text')");
  }

  Future<void> autoScroll({int millisecondInterval = 1000}) async {
    await evaluate('''async () => {
        await new Promise((resolve, reject) => {
            var totalHeight = 0;
            var distance = 100;
            var timer = setInterval(() => {
                var scrollHeight = document.body.scrollHeight;
                window.scrollBy(0, distance);
                totalHeight += distance;

                if(totalHeight >= scrollHeight){
                    clearInterval(timer);
                    resolve();
                }
            }, $millisecondInterval);
        });
    }''');
  }

  Future<void> setPageZoom({int zoom = 1}) async {}

  Future<ElementHandle> parent(ElementHandle tag) async {
    return await evaluateHandle(r'el => el.parentNode', args: [tag]);
  }

  Future<void> waitForFileChooser(ElementHandle tag, {required List<File> acceptFiles}) async {
    var futureFileChooser = tab.waitForFileChooser();
    await tag.click();

    var fileChooser = await futureFileChooser;
    await fileChooser.accept(acceptFiles);
  }

  Future<void> focus(String selector) async {
    await tab.focus(selector);
  }

  Future<void> typeFocus(String selector, String text, {Duration? delay}) async {
    await focus(selector);
    await tab.keyboard.type(text, delay: delay);
  }
  Future<void> typeClick(String selector, String text, {Duration? delay}) async {
    await click(selector);
    await tab.keyboard.type(text, delay: delay);
  }
}
