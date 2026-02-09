import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';

class YoyoProvider with ChangeNotifier {
  final List<Message> _messages = [];
  MqttServerClient? _client;
  bool _isConnected = false;
  String _serverAddress = '';
  String _serverPort = '';
  String _username = '';
  String _password = '';
  Timer? _reconnectTimer;
  bool _isReconnecting = false;

  List<Message> get messages => _messages;
  bool get isConnected => _isConnected;

  YoyoProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _serverAddress = prefs.getString('server_address') ?? dotenv.env['DEFAULT_SERVER_ADDRESS'] ?? 'localhost';
    _serverPort = prefs.getString('server_port') ?? dotenv.env['DEFAULT_SERVER_PORT'] ?? '1883';
    _username = prefs.getString('mqtt_username') ?? '';
    _password = prefs.getString('mqtt_password') ?? '';
    
    connectToServer();
  }

  Future<void> updateServerSettings({
    required String serverAddress,
    required String serverPort,
    String? username,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_address', serverAddress);
    await prefs.setString('server_port', serverPort);
    
    if (username != null) {
      await prefs.setString('mqtt_username', username);
    }
    
    if (password != null) {
      await prefs.setString('mqtt_password', password);
    }
    
    _serverAddress = serverAddress;
    _serverPort = serverPort;
    
    if (username != null) {
      _username = username;
    }
    
    if (password != null) {
      _password = password;
    }
    
    // Reconnecter avec les nouveaux paramètres
    await disconnectFromServer();
    await connectToServer();
  }

  Future<void> connectToServer() async {
    if (_isConnected || _isReconnecting) return;
    
    _isReconnecting = true;
    
    try {
      // Créer un identifiant client unique
      final clientId = 'yoyo_mobile_${DateTime.now().millisecondsSinceEpoch}';
      _client = MqttServerClient(_serverAddress, clientId);
      _client!.port = int.parse(_serverPort);
      _client!.keepAlivePeriod = 60;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;
      
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .withWillTopic('yoyo/status')
          .withWillMessage('Déconnecté')
          .withWillQos(MqttQos.atLeastOnce)
          .withWillRetain()
          .startClean();
      
      _client!.connectionMessage = connMessage;
      
      // Ajouter les identifiants si nécessaire
      if (_username.isNotEmpty) {
        _client!.connectionMessage!.authenticateAs(_username, _password);
      }
      
      await _client!.connect();
      
      // S'abonner aux topics
      _client!.subscribe('hermes/intent/#', MqttQos.atLeastOnce);
      _client!.subscribe('hermes/asr/textCaptured', MqttQos.atLeastOnce);
      _client!.subscribe('yoyo/response', MqttQos.atLeastOnce);
      
      // Configurer le gestionnaire de messages
      _client!.updates!.listen(_onMessage);
      
      // Publier un message de connexion
      final builder = MqttClientPayloadBuilder();
      builder.addString('Connecté depuis mobile');
      _client!.publishMessage(
        'yoyo/status',
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: true,
      );
      
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      print('Erreur de connexion MQTT: $e');
      _scheduleReconnect();
    } finally {
      _isReconnecting = false;
    }
  }

  void _onConnected() {
    print('Connecté au serveur MQTT');
    _isConnected = true;
    _cancelReconnectTimer();
    notifyListeners();
  }

  void _onDisconnected() {
    print('Déconnecté du serveur MQTT');
    _isConnected = false;
    _scheduleReconnect();
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    print('Abonné au topic: $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (var message in messages) {
      final recMess = message.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      
      print('Message reçu sur ${message.topic}: $payload');
      
      if (message.topic == 'yoyo/response') {
        _addMessage(payload, false);
      } else if (message.topic == 'hermes/asr/textCaptured') {
        // Traiter le texte capturé si nécessaire
      }
    }
  }

  void _scheduleReconnect() {
    _cancelReconnectTimer();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isReconnecting) {
        connectToServer();
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Future<void> disconnectFromServer() async {
    _cancelReconnectTimer();
    
    if (_client != null && _client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.disconnect();
    }
    
    _isConnected = false;
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    _addMessage(text, true);
    
    if (_isConnected && _client != null) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(text);
      _client!.publishMessage(
        'yoyo/command',
        MqttQos.atLeastOnce,
        builder.payload!,
      );
    } else {
      // Si déconnecté, essayer de se reconnecter
      connectToServer();
      
      // Ajouter un message d'erreur
      _addMessage("Je ne peux pas traiter votre demande car je ne suis pas connecté au serveur. Veuillez vérifier votre connexion.", false);
    }
  }

  void _addMessage(String text, bool isUser) {
    final message = Message(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    
    _messages.add(message);
    notifyListeners();
  }

  @override
  void dispose() {
    disconnectFromServer();
    super.dispose();
  }
}
