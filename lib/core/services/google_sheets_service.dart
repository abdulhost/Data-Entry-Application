import 'dart:convert';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:first_app/features/dashboard/entry_model.dart';

class GoogleSheetsService {
  static const _scopes = [SheetsApi.spreadsheetsScope];
  final String _spreadsheetId = '1wuOAeGgQbtS6ITWw-dafwWWraR7lDGZdC1ODOHcqywE';

  Future<SheetsApi?> _getSheetsApi() async {
    try {
      final credentials = ServiceAccountCredentials.fromJson(json.decode(r'''
{
  "type": "service_account",
  "project_id": "eighth-veld-401419",
  "private_key_id": "52119da698f2eabd57b2be8102b66b5d3504a440",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDGP6ZgpC9skcAK\nUYBLIMQiXXaKEIK+hU2eUMCGkxK+SPxOLO9rgk7b0BimjwW5+c4MXZmae1rrUPch\ncoEkgbD0/HDFihPTEBFpyeF7ARZuBqj+v+gg2tRTC5P9ndxADVJDs0eJ4KNX9AY4\n71sSh14fGDhdWZRijG5/KBScgL0n9EAAxnduipwlZ54wxzFUYpWqwZKw1OSSfjxl\nEhhLnRMA6mx15MxwQPSjUzf+8bubllkSk3mPtFJ3pzMiU41UgtlqhJzxWJIR6bJV\nGtHxRh19SdCS1/RwYju8W8umSagXsoDo8ZkhfaKCUCq3TMCd1oad3gCIRnNK4bAg\nrV1LjlnhAgMBAAECggEAB8OWId6IO2+lVlodBMQ0njZsFinhnvHESY0WzyZrI1/j\nHrIokbytlzL6BirfgeowOUCAq6HFXKYj+Y+9EkeQfTW2OmxHDLrqPasB/UHchaRV\n4b01C3Vaf6KaUgJIzgrfhAZ9SJ9vMjp8tGXeWpZJ17yod3Jyyt2+VZVFol/x2ILJ\nCXaLSDmhoUttfLOUmdJDIzOn3HWtuaeo+enHgVHKiBbWdSCaWXhq+D7OaJMBj2VE\n+FczMNztuTRsKui4kLUQEIacDy/U5fJ/w3hBbuS7H5sICG1wW/1sdDPZhWp8DRPH\nktEMfDa50FZpbVsqB4gz+diXk/75S1RnYMuel4PeuQKBgQDlJNkyO832A69hxMzr\n0K+sh3MM2MOnuPcszaKJYba7UqBUgbPomOkFT+rw33sWDHRQZ1j56VIbdhdAtKg5\nRT4I2Y8V578TK4uRycFO9nXjH62/797SJyXBBPojZ+Zh3ZNdebbErXPOUpqvCsYS\nLsvATSdMJ/+XV9Ez3RNFB578+QKBgQDde9R1whMaKfFPZbMZuZ99dSpikuFBgRr6\nPU5T0bhgWGmIVDyDIlXPEWaKvCEK1PTwYhnK6U+d6fijiXItx0RwQbJhV8h9ln9F\nMKt/JlWX+i0s9HcRHNXZvstfrg+LV4zG8HIYHUqyGxCVV9xu9BMXAGb38UJHjZtu\nF+PqPvoGKQKBgDptrfBQLZFomSTd8L7EpLbihuSktSckU+qZuLM9NkIHrJg/xmct\n7mULXsXyxkj1/gaug5Kd+vDDqOQ37JlF3a6WAxU71Y4G0XzoLCF9WMwEPOKvQGrn\nzomsQjga+zTDMhtouMDn1Zqrl4PAxIbIZe3v/nA91r95hf+qhIpaiiDJAoGBAKRv\nGv2SaLw0B4P67U1cEp0CL8WfZr1LLMw8V7rDKS/ec/tTDtoM08g4EvlNUvrHwFH3\ng06yiPmki4RetvZlytnM7LJ4idEzuqmTyL9Npp5+jquhlASQc/SFQlh20fORvGK2\ngP6GQL6aeWVnJbD6ZHHfSpMp+xtEdvD1q7BtsRKBAoGAJXWtP0T++AVIdk7+mBM/\nbsfTFJlAv1Ga9c0qzd4w6VwOi60quMEWfv9KvbXKb2VkvIYkowsHJAPQPOg5fY7Y\nzAerUQFond5KpVJQ5lSHA/eDEYJhovZ4nkhYsbuynTu1s+FoHY7VkO/1SjrH2x6k\nupp+c/xrYKaP783mCJb9xSg=\n-----END PRIVATE KEY-----\n",
  "client_email": "demo-data-entry@eighth-veld-401419.iam.gserviceaccount.com",
  "client_id": "115948658549040411628",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/demo-data-entry%40eighth-veld-401419.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
'''));
      final client = await clientViaServiceAccount(credentials, _scopes);
      return SheetsApi(client);
    } catch (e) {
      print("❌ Auth Error: $e");
      return null;
    }
  }

  /// 🔍 FIND ROW BY ID
  Future<int?> _findRowById(SheetsApi api, String id) async {
    final response = await api.spreadsheets.values.get(
      _spreadsheetId,
      'Sheet1!A:A',
    );

    final rows = response.values;
    if (rows == null) return null;

    for (int i = 0; i < rows.length; i++) {
      if (rows[i].isNotEmpty && rows[i][0] == id) {
        return i + 1;
      }
    }

    return null;
  }

  /// ✅ CHECK EXISTS
  Future<bool> checkIfExists(String id) async {
    final api = await _getSheetsApi();
    if (api == null) return false;

    final row = await _findRowById(api, id);
    return row != null;
  }

  /// ➕ APPEND
  Future<void> appendEntry(Entry entry) async {
    final api = await _getSheetsApi();
    if (api == null) return;

    final values = [
      [
        entry.id,
        entry.name,
        entry.phone,
        entry.address,
        entry.variant,
        entry.color,
        entry.amount,
        entry.date,
        entry.time,
      ]
    ];

    await api.spreadsheets.values.append(
      ValueRange(values: values),
      _spreadsheetId,
      'Sheet1!A1',
      valueInputOption: 'RAW',
    );
  }

  /// ✏️ UPDATE BY ID
  Future<void> updateById(Entry entry) async {
    final api = await _getSheetsApi();
    if (api == null) return;

    final row = await _findRowById(api, entry.id);
    if (row == null) return;

    final values = [
      [
        entry.id,
        entry.name,
        entry.phone,
        entry.address,
        entry.variant,
        entry.color,
        entry.amount,
        entry.date,
        entry.time,
      ]
    ];

    await api.spreadsheets.values.update(
      ValueRange(values: values),
      _spreadsheetId,
      'Sheet1!A$row:I$row',
      valueInputOption: 'RAW',
    );
  }

  /// 🗑 DELETE BY ID
  Future<void> deleteById(String id) async {
    final api = await _getSheetsApi();
    if (api == null) return;

    final row = await _findRowById(api, id);
    if (row == null) return;

    await api.spreadsheets.batchUpdate(
      BatchUpdateSpreadsheetRequest(requests: [
        Request(
          deleteDimension: DeleteDimensionRequest(
            range: DimensionRange(
              sheetId: 0,
              dimension: 'ROWS',
              startIndex: row - 1,
              endIndex: row,
            ),
          ),
        )
      ]),
      _spreadsheetId,
    );
  }
}