import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  final String clientId; // optional identifier for mobile client
  WebSocketChannel? _channel;
  bool _connected = false;
  Timer? _reconnectTimer;

  final _messagesController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messagesController.stream;

  WebSocketService({required this.url, this.clientId = 'mobile-client'});

  Future<void> connect() async {
    if (_connected) return;
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _connected = true;
      _channel!.stream.listen(
        _onMessage,
        onDone: _onDone,
        onError: _onError,
        cancelOnError: true,
      );
      // optional hello to server (not required by server but helps)
      _send({'from': 'mobile', 'event': 'hello', 'clientId': clientId});
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final Map<String, dynamic> msg = (raw is String) ? jsonDecode(raw) : Map<String, dynamic>.from(raw);
      _messagesController.add(msg);
    } catch (e) {
      // ignore parse errors
    }
  }

  void _onDone() {
    _connected = false;
    _scheduleReconnect();
  }

  void _onError(Object error) {
    _connected = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      connect();
    });
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messagesController.close();
    _connected = false;
  }

  bool get isConnected => _connected;

  // Generic send wrapper for mobile events
  void sendEvent(String event, [Map<String, dynamic>? data]) {
    final payload = <String, dynamic>{'from': 'mobile', 'event': event};
    if (data != null) payload.addAll(data);
    _send(payload);
  }

  // Low-level send
  void _send(Map<String, dynamic> payload) {
    try {
      final jsonMsg = jsonEncode(payload);
      if (_channel != null && _connected) {
        _channel!.sink.add(jsonMsg);
      }
    } catch (e) {
      // ignore
    }
  }

  // Convenience API methods
  void getDevices() => sendEvent('getDevices');

  void toggleRelay({required String deviceId, required int relayId}) =>
      sendEvent('toggleRelay', {'deviceId': deviceId, 'relayId': relayId});

  void requestStatus({required String deviceId}) =>
      sendEvent('getStatus', {'deviceId': deviceId});

  void relayOn({required String deviceId, required int relayId}) =>
      sendEvent('relayOn', {'deviceId': deviceId, 'relayId': relayId});

  void relayOff({required String deviceId, required int relayId}) =>
      sendEvent('relayOff', {'deviceId': deviceId, 'relayId': relayId});

  void setTimer({required String deviceId, required int relayId, required int seconds}) =>
      sendEvent('setTimer', {'deviceId': deviceId, 'relayId': relayId, 'seconds': seconds});

  void setSchedule({required String deviceId, required int relayId, required Map<String, dynamic> scheduleData}) =>
      sendEvent('setSchedule', {'deviceId': deviceId, 'relayId': relayId, 'scheduleData': scheduleData});
}
