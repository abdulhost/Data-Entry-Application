import 'package:flutter/material.dart';
import 'entry_model.dart';
import 'package:intl/intl.dart';
class EntryViewScreen extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EntryViewScreen({
    Key? key,
    required this.entry,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Entry'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (onDelete != null) onDelete!();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildRow('Name', entry.name),
            _buildRow('Phone', entry.phone),
            _buildRow('Address', entry.address, maxLines: 3),
            _buildRow('Variant', entry.variant),
            _buildRow('Color', entry.color),
            _buildRow('Amount', '₹ ${entry.amount}'),
            _buildRow('Date', DateFormat('dd MMM yyyy').format(DateTime.parse(entry.date))),
            _buildRow('Time', entry.time),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, maxLines: maxLines)),
        ],
      ),
    );
  }
}