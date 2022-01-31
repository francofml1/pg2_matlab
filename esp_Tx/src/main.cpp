#include "Arduino.h"
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

#define D1 5
#define MSG_BUFFER_SIZE (500)

const char *ssid = "Testando";
const char *password = "76543210";
const char *mqtt_server = "192.168.137.55";
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient MQTT(espClient);
unsigned long lastMsg = 0;
char msg[MSG_BUFFER_SIZE];

DynamicJsonDocument doc(4096);

// Protótipos de função:
void setup_wifi();
void callback(char *topic, byte *payload, unsigned int length);
void reconnect();
void sendArray(uint16_t N, double Tb, double T_delay, bool *bit_array);

void setup()
{
    pinMode(LED_BUILTIN, OUTPUT); // Initialize the LED_BUILTIN pin as an output
    digitalWrite(LED_BUILTIN, 0);
    pinMode(D1, OUTPUT);
    digitalWrite(D1, 0);

    Serial.begin(115200);
    setup_wifi();
    MQTT.setServer(mqtt_server, mqtt_port);
    MQTT.setCallback(callback);
}

void loop()
{
    if (!MQTT.connected())
    {
        reconnect();
    }
    MQTT.loop();
}

void setup_wifi()
{

    delay(10);
    // We start by connecting to a WiFi network
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);

    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }

    randomSeed(micros());

    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());
}

void callback(char *topic, byte *payload, unsigned int length)
{
    String msg;

    // obtem a string do payload recebido
    for (int i = 0; i < length; i++)
    {
        char c = (char)payload[i];
        msg += c;
    }
    Serial.print("MSG recebida: ");
    Serial.println(msg);

    // StaticJsonDocument<10000> doc;

    deserializeJson(doc, msg);
    JsonObject obj = doc.as<JsonObject>();

    double Tb = obj["Tb"];
    Tb *= 1000;
    double Td = obj["Td"];
    Td *= 1000;
    uint16_t n = obj["n"];
    bool x_bit[n];
    for (size_t j = 0; j < n; j++)
    {
        x_bit[j] = doc["x_bit"][j].as<bool>();
    }

    Serial.println(sizeof(x_bit));

    sendArray(n, Tb, Td, x_bit);
}

void reconnect()
{
    // Loop until we're reconnected
    while (!MQTT.connected())
    {
        Serial.print("Attempting MQTT connection...");
        // Create a random client ID
        String clientId = "ESP8266Client-";
        clientId += String(random(0xffff), HEX);
        // Attempt to connect
        if (MQTT.connect(clientId.c_str()))
        {
            Serial.println("connected");
            // Once connected, publish an announcement...
            // MQTT.publish("outTopic", "hello world");
            // ... and resubscribe
            MQTT.subscribe("inTopic");
        }
        else
        {
            Serial.print("failed, rc=");
            Serial.print(MQTT.state());
            Serial.println(" try again in 5 seconds");
            // Wait 5 seconds before retrying
            delay(5000);
        }
    }
}

/**
 * Transmite o array ativando a solenoide
 * @param Tb tempo de bit [ms]
 * @param T_delay tempo que a solenoide fica ativada [ms]
 * @param bit_array array de bits a ser transmitido
 * */
void sendArray(uint16_t N, double Tb, double T_delay, bool *bit_array)
{
    uint32_t T0_bit;
    for (size_t i = 0; i < N; i++)
    {
        T0_bit = millis();
        if (bit_array[i])
        {
            digitalWrite(D1, 1);
            digitalWrite(LED_BUILTIN, 1);
            delay(T_delay);
            digitalWrite(D1, 0);
            digitalWrite(LED_BUILTIN, 0);
        }
        while ((millis() - T0_bit) < (Tb))
        {
            delay(5);
        }
    }
}
