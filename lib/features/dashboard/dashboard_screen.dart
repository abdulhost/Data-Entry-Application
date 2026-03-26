import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'entry_form_screen.dart';
import 'entry_model.dart';
import 'entry_repository.dart';
import '../profile/profile_screen.dart';

// Theme controller
ValueNotifier<ThemeMode> appTheme = ValueNotifier(ThemeMode.light);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Entry> _entries = [];
  final _repo = EntryRepository();

  final _searchController = TextEditingController();
  String _query = '';

  bool _isOnline = false;
  bool _isSyncing = false;

  late StreamSubscription _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /// 🌐 INIT INTERNET LISTENER
  void _initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnection(result);

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnection);
  }

  void _updateConnection(ConnectivityResult result) {
    final wasOffline = !_isOnline;

    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });

    // ⚡ Auto sync when internet returns
    if (_isOnline && wasOffline) {
      _autoSync();
    }
  }

  /// 🔄 AUTO SYNC
  Future<void> _autoSync() async {
    await _syncData(showMessage: true);
  }

  /// 🔄 MANUAL + AUTO SYNC HANDLER
  Future<void> _syncData({bool showMessage = false}) async {
    if (!_isOnline) {
      if (showMessage) {
        _showSnack('No internet connection');
      }
      return;
    }

    setState(() => _isSyncing = true);

    try {
      await _repo.syncToGoogleSheets(); // 👈 YOU WILL IMPLEMENT THIS

      if (showMessage) {
        _showSnack('Synced successfully ✅');
      }
    } catch (e) {
      _showSnack('Sync failed ❌');
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 📥 LOAD DATA
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
          onSaved: () async {
            await _loadEntries();
            await _syncData(); // auto sync after add/edit
          },
        ),
      ),
    );
  }

  void _viewEntry(Entry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Text(entry.name,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _infoRow('Phone', entry.phone),
            _infoRow('Address', entry.address),
            _infoRow('Variant', entry.variant),
            _infoRow('Color', entry.color),
            _infoRow('Amount', '₹ ${entry.amount}'),
            _infoRow('Date', entry.date),
            _infoRow('Time', entry.time),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Entry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _repo.delete(entry); // ✅ FIXED
      await _loadEntries();
      await _syncData();
    }
  }
  void _searchEntries() {
    setState(() => _query = _searchController.text.trim());
    _loadEntries();
  }

  void _handleMenu(String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;

      case 'theme':
        appTheme.value =
        appTheme.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        break;

      case 'sync':
        _syncData(showMessage: true);
        break;

      case 'logout':
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  /// 🔍 SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _searchEntries(),
        decoration: InputDecoration(
          hintText: 'Search entries...',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              _searchEntries();
            },
          ),
        ),
      ),
    );
  }

  /// 📋 ENTRY CARD
  Widget _buildEntryCard(Entry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          title: Text(entry.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${entry.phone}\n${entry.date} • ${entry.time}'),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  onPressed: () => _viewEntry(entry)),
              IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () => _openForm(entry)),
              IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(entry)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_entries.isEmpty) {
      return const Center(child: Text('No entries found'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadEntries();
        await _syncData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _entries.length,
        itemBuilder: (_, i) => _buildEntryCard(_entries[i]),
      ),
    );
  }

  /// 🟢 INTERNET INDICATOR
  Widget _buildStatusDot() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          _buildStatusDot(),
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'theme', child: Text('Toggle Theme')),
              PopupMenuItem(value: 'sync', child: Text('Sync Now')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }
}