#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <ESP8266HTTPClient.h>
#include <SPI.h>
#include <MFRC522.h>

// ---------- USER CONFIG ----------
const char* WIFI_SSID = "WIFISSID";
const char* WIFI_PASS = "WIFIPASS";

const char* SUPABASE_HOST = "SUPABASEHOST";
const char* SUPABASE_TABLE = "access_logs";
const char* SUPABASE_API_KEY = "APIKEY"; 
// ----------------------------------

#define SS_PIN  D4   
#define RST_PIN D3   
#define RLED    D15
#define GLED    D2
#define BUZZER  D9
#define spaceId "SPACEID"

MFRC522 mfrc522(SS_PIN, RST_PIN);
WiFiClientSecure client;
HTTPClient http;

void setup() {
  Serial.begin(115200);
  SPI.begin();
  mfrc522.PCD_Init();
  pinMode(RLED, OUTPUT);
  pinMode(GLED, OUTPUT);
  pinMode(BUZZER, OUTPUT);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected.");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());

  client.setInsecure(); 
}

String uidToHex(MFRC522::Uid uid) {
  String s = "";
  for (byte i = 0; i < uid.size; i++) {
    if (uid.uidByte[i] < 0x10) s += "0";
    s += String(uid.uidByte[i], HEX);
  }
  s.toUpperCase();
  return s;
}

String getLatestEvent(const String &uidHex) {
  if (WiFi.status() != WL_CONNECTED) return "";

  String url = String(SUPABASE_HOST) + "/rest/v1/" + SUPABASE_TABLE +
               "?rfid=eq." + uidHex + "&order=created_at.desc&limit=1";

  http.begin(client, url);
  http.addHeader("apikey", SUPABASE_API_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_API_KEY);

  int code = http.GET();
  if (code > 0) {
    String resp = http.getString();
    Serial.println("Latest entry response: " + resp);
    http.end();

    if (resp.indexOf("checkin") != -1) return "checkin";
    if (resp.indexOf("checkout") != -1) return "checkout";
    return "";
  } else {
    Serial.println("GET failed: " + http.errorToString(code));
    http.end();
    return "";
  }
}

bool insertEvent(const String &uidHex, const String &eventType) {
  if (WiFi.status() != WL_CONNECTED) return false;

  String url = String(SUPABASE_HOST) + "/rest/v1/" + SUPABASE_TABLE;
  String payload = "{\"rfid\":\"" + uidHex + "\", \"event_type\":\"" + eventType + "\", \"spaceid\":\"" + spaceId + "\" }";

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_API_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_API_KEY);
  http.addHeader("Prefer", "return=representation");

  Serial.println("POST " + url);
  Serial.println("Payload: " + payload);

  int code = http.POST(payload);
  if (code > 0) {
    String resp = http.getString();
    Serial.println("Response: " + resp);
    http.end();
    return (code >= 200 && code < 300);
  } else {
    Serial.println("POST failed: " + http.errorToString(code));
    http.end();
    return false;
  }
}

void loop() {
  digitalWrite(GLED, LOW);
  digitalWrite(RLED, LOW);
  digitalWrite(BUZZER, HIGH);

  if (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial()) {
    delay(50);
    return;
  }

  String uidHex = uidToHex(mfrc522.uid);
  Serial.println("Card UID: " + uidHex);

  String latest = getLatestEvent(uidHex);
  String newEvent = (latest == "checkin") ? "checkout" : "checkin";

  bool ok = insertEvent(uidHex, newEvent);
  digitalWrite(BUZZER, LOW);

  if (ok) {
    Serial.println("Inserted " + newEvent + " successfully.");
    digitalWrite(GLED, HIGH);
    delay(2000);
    digitalWrite(GLED, LOW);
  } else {
    Serial.println("Insert failed.");
    digitalWrite(RLED, HIGH);
    delay(2000);
    digitalWrite(RLED, LOW);
  }

  digitalWrite(BUZZER, HIGH);
  mfrc522.PICC_HaltA();
  delay(1200);
}
