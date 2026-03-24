// lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'entry_form_screen.dart';
import 'entry_model.dart';
import 'entry_repository.dart';

import '../profile/profile_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// Simple theme manager using ValueNotifier
ValueNotifier<ThemeMode> appTheme = ValueNotifier(ThemeMode.light);

class _DashboardScreenState extends State<DashboardScreen> {
  List<Entry> _entries = [];
  final _repo = EntryRepository();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _repo.getEntries(query: _query);
    setState(() => _entries = entries);
  }

  void _openForm([Entry? entry]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntryFormScreen(
          entry: entry,
          onSaved: _loadEntries,
        ),
      ),
    );
  }

  void _viewEntry(Entry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(entry.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${entry.phone}'),
            Text('Address: ${entry.address}'),
            Text('Variant: ${entry.variant}'),
            Text('Color: ${entry.color}'),
            Text('Amount: ${entry.amount}'),
            Text('Date: ${entry.date}'),
            Text('Time: ${entry.time}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed ?? false) {
      await _repo.delete(id);
      _loadEntries();
    }
  }

  void _searchEntries() {
    setState(() => _query = _searchController.text.trim());
    _loadEntries();
  }

  void _handleMenu(String value) {
    switch (value) {
      case 'profile':
      // Navigate to ProfileScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;

      case 'theme':
      // Toggle theme
        appTheme.value =
        appTheme.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        break;
      case 'contact':
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Contact Info'),
            content: const Text('Abdul\nPhone: 94893'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;
      case 'logout':
      // Correct logout navigation
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _searchEntries(),
        decoration: InputDecoration(
          labelText: 'Search by name, phone, address, variant, color',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _searchEntries();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(Entry entry) {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(entry.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${entry.phone} • ${entry.address}\n${entry.date} • ${entry.time}'),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              tooltip: 'View',
              onPressed: () => _viewEntry(entry),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              tooltip: 'Edit',
              onPressed: () => _openForm(entry),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(entry.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenu,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'theme', child: Text('Toggle Theme')),
              const PopupMenuItem(value: 'contact', child: Text('Contact')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _entries.isEmpty
                ? const Center(child: Text('No entries found'))
                : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (_, index) => _buildEntryCard(_entries[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}