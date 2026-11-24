import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../server/server_controller.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  final ServerController _controller = ServerController.instance;
  late final TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    // Shows the actual port if the server is already running.
    _portController = TextEditingController(text: _controller.port.toString());
  }

  @override
  void dispose() {
    _portController.dispose(); // do NOT stop the server here
    super.dispose();
  }

  Future<void> toggleServer() async {
    try {
      if (_controller.isRunning) {
        await _controller.stop();
      } else {
        final port = int.tryParse(_portController.text);
        if (port == null || port < 1 || port > 65535) {
          throw Exception('Please enter a valid port (1-65535).');
        }
        await _controller.start(port);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isServerRunning = _controller.isRunning;
        final isLoading = _controller.isLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Server')),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('Web Server'),
                trailing: Text(
                  isServerRunning ? 'running' : 'stopped',
                  style: TextStyle(
                    color: isServerRunning ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings_ethernet),
                title: const Text('Web Server Port'),
                trailing: SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _portController,
                    enabled: !isServerRunning && !isLoading,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ElevatedButton(
                  onPressed: isLoading ? null : toggleServer,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(isServerRunning ? 'Stop Server' : 'Start Server'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
