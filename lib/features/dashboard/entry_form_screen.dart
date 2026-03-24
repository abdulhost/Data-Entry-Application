// lib/features/dashboard/entry_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'entry_model.dart';
import 'entry_repository.dart';

class EntryFormScreen extends StatefulWidget {
  final Entry? entry;
  final VoidCallback? onSaved;

  const EntryFormScreen({Key? key, this.entry, this.onSaved}) : super(key: key);

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _variantController = TextEditingController();
  final _colorController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _nameController.text = widget.entry!.name;
      _phoneController.text = widget.entry!.phone;
      _addressController.text = widget.entry!.address;
      _variantController.text = widget.entry!.variant;
      _colorController.text = widget.entry!.color;
      _amountController.text = widget.entry!.amount.toString();
      _selectedDate = DateFormat('dd MMM yyyy').parse(widget.entry!.date);
      final t = widget.entry!.time.split(':');
      _selectedTime = TimeOfDay(hour: int.parse(t[0]), minute: int.parse(t[1].split(' ')[0]));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = EntryRepository();
    final entry = Entry(
      id: widget.entry?.id ?? const Uuid().v4(),
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      variant: _variantController.text,
      color: _colorController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
      date: DateFormat('dd MMM yyyy').format(_selectedDate),
      time: _selectedTime.format(context),
    );

    if (widget.entry == null) {
      await repo.insert(entry);
    } else {
      await repo.update(entry);
    }

    widget.onSaved?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry == null ? 'Add Entry' : 'Edit Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                keyboardType: TextInputType.name,
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _variantController,
                decoration: const InputDecoration(labelText: 'Variant'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Billed Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text('Time: ${_selectedTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text(widget.entry == null ? 'Save Entry' : 'Update Entry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}