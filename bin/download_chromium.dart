import 'package:puppeteer/puppeteer.dart';

void main() async {
  await downloadChrome(revision: 970485, cachePath: "/app/.local-chromium");
}