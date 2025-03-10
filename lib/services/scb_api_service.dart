import 'dart:convert';
import 'package:http/http.dart' as http;

class SCBApiService {
  final String apiKey =
      'l7ca712dd35134193876250fc405560d1'; // API Key จาก SCB Developer
  final String apiSecret =
      '3e6ce8e1307b4b32bad55865d76b258d'; // API Secret จาก SCB Developer
  final String merchantId = '9882867128'; // ใส่ Merchant ID ของคุณ
  final String callbackUrl = 'yourapp://'; // URL สำหรับรับการตอบกลับ

  Future<String?> createPayment(double amount, String orderId) async {
    final String url =
        'https://api-sandbox.partners.scb/partners/sandbox/v1/oauth/token';

    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
        'resourceOwnerId': apiKey,
        'requestUId': orderId,
        'accept-language': 'EN',
      },
      body: jsonEncode({
        "applicationKey": apiKey,
        "applicationSecret": apiSecret,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String accessToken = data['data']['accessToken'];
      return accessToken;
    } else {
      print('Error: ${response.body}');
      return null;
    }
  }

  Future<String?> generateQrCode(
      String accessToken, double amount, String orderId) async {
    final String url =
        'https://api-sandbox.partners.scb/partners/sandbox/v1/payment/qrcode/create';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'resourceOwnerId': apiKey,
        'requestUId': orderId,
        'accept-language': 'EN',
      },
      body: jsonEncode({
        "transactionType": "PURCHASE",
        "transactionSubType": ["BP"],
        "sessionValidityPeriod": "1800",
        "amount": amount.toString(),
        "currencyCode": "THB",
        "merchantId": merchantId,
        "terminalId": "YOUR_TERMINAL_ID",
        "callbackUrl": callbackUrl,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['qrImage'];
    } else {
      print('Error: ${response.body}');
      return null;
    }
  }
}
