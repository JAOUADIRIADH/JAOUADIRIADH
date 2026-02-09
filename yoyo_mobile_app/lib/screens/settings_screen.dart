import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/yoyo_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Apparence'),
          _buildDarkModeSwitch(context),
          
          _buildSectionHeader(context, 'Langue'),
          _buildLanguageSelector(context),
          
          _buildSectionHeader(context, 'Connexion au serveur'),
          _buildServerSettings(context),
          
          _buildSectionHeader(context, 'Voix'),
          _buildVoiceSettings(context),
          
          _buildSectionHeader(context, 'À propos'),
          _buildAboutSection(context),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildDarkModeSwitch(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return SwitchListTile(
      title: const Text('Mode sombre'),
      subtitle: const Text('Activer le thème sombre'),
      value: settingsProvider.isDarkMode,
      onChanged: (value) {
        settingsProvider.setDarkMode(value);
      },
    );
  }
  
  Widget _buildLanguageSelector(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Langue de l\'application',
          border: OutlineInputBorder(),
        ),
        value: settingsProvider.language,
        items: const [
          DropdownMenuItem(value: 'fr', child: Text('Français')),
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'es', child: Text('Español')),
          DropdownMenuItem(value: 'de', child: Text('Deutsch')),
          DropdownMenuItem(value: 'it', child: Text('Italiano')),
          DropdownMenuItem(value: 'pt', child: Text('Português')),
          DropdownMenuItem(value: 'ru', child: Text('Русский')),
          DropdownMenuItem(value: 'zh', child: Text('中文')),
        ],
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setLanguage(value);
          }
        },
      ),
    );
  }
  
  Widget _buildServerSettings(BuildContext context) {
    final yoyoProvider = Provider.of<YoyoProvider>(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut: ${yoyoProvider.isConnected ? 'Connecté' : 'Déconnecté'}',
              style: TextStyle(
                color: yoyoProvider.isConnected 
                    ? Colors.green 
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Adresse du serveur',
                hintText: 'ex: 192.168.1.10',
                border: OutlineInputBorder(),
              ),
              initialValue: '', // À récupérer des préférences
              onFieldSubmitted: (value) {
                // Mettre à jour l'adresse du serveur
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: 'ex: 1883',
                border: OutlineInputBorder(),
              ),
              initialValue: '', // À récupérer des préférences
              keyboardType: TextInputType.number,
              onFieldSubmitted: (value) {
                // Mettre à jour le port
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Tenter de se connecter avec les nouveaux paramètres
                  yoyoProvider.connectToServer();
                },
                child: const Text('Se connecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVoiceSettings(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type de voix'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: 'female',
              items: const [
                DropdownMenuItem(value: 'female', child: Text('Féminine')),
                DropdownMenuItem(value: 'male', child: Text('Masculine')),
                DropdownMenuItem(value: 'neutral', child: Text('Neutre')),
              ],
              onChanged: (value) {
                // Mettre à jour le type de voix
              },
            ),
            const SizedBox(height: 16),
            const Text('Vitesse de la voix'),
            Slider(
              value: 0.5,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: 'Normale',
              onChanged: (value) {
                // Mettre à jour la vitesse de la voix
              },
            ),
            const SizedBox(height: 16),
            const Text('Hauteur de la voix'),
            Slider(
              value: 0.6,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: 'Médium',
              onChanged: (value) {
                // Mettre à jour la hauteur de la voix
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAboutSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yoyo Assistant Vocal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'Yoyo est un assistant vocal personnel avec intelligence artificielle évolutive, '
              'fonctionnant entièrement en local pour préserver votre confidentialité.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Afficher les informations de licence
                },
                child: const Text('Licences'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
