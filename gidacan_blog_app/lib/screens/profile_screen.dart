import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = UserService().getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final data = snapshot.data ?? {};
        final first = data['firstName'] ?? '';
        final last = data['lastName'] ?? '';
        final email = data['email'] ?? '';
        final type = data['type'] ?? '';
        final contact = data['contactNumber'] ?? '';
        final address = data['address'] ?? '';
        final gender = data['gender'] ?? '';
        final age = data['age'] ?? '';

        return RefreshIndicator(
          onRefresh: () async {
            setState(() { _futureUser = UserService().getUserData(); });
            await _futureUser;
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(
                radius: 46,
                child: Text(
                  (first.isNotEmpty ? first[0] : '?').toUpperCase(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  [first, last].where((s) => s.isNotEmpty).join(' '),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              if (email.isNotEmpty)
                Center(
                  child: Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 24),
              _infoTile('Role', type.isEmpty ? '—' : type),
              _infoTile('First Name', first.isEmpty ? '—' : first),
              _infoTile('Last Name', last.isEmpty ? '—' : last),
              _infoTile('Email', email.isEmpty ? '—' : email),
              _infoTile('Contact Number', contact.isEmpty ? '—' : contact),
              _infoTile('Address', address.isEmpty ? '—' : address),
              _infoTile('Gender', gender.isEmpty ? '—' : gender),
              _infoTile('Age', age.isEmpty ? '—' : age),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}