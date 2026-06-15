import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/formatters.dart';
import '../../data/models/category.dart';
import '../../data/models/expense_transaction.dart';
import '../../data/models/transaction_type.dart';
import '../../state/settings_controller.dart';
import '../../state/transactions_controller.dart';

/// Form to create a new transaction or edit an existing one.
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({super.key, this.existing});

  final ExpenseTransaction? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  late String _categoryId;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _type = existing?.type ?? TransactionType.expense;
    _categoryId =
        existing?.categoryId ?? Categories.forType(_type).first.id;
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      // Reset to a valid category for the new type.
      _categoryId = Categories.forType(type).first.id;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amount =
        double.parse(_amountController.text.trim().replaceAll(',', ''));
    final controller = ref.read(transactionsControllerProvider.notifier);
    final existing = widget.existing;

    final transaction = ExpenseTransaction(
      id: existing?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      categoryId: _categoryId,
      date: _date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      if (existing == null) {
        await controller.add(transaction);
      } else {
        await controller.edit(transaction);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyFormatterProvider);
    final categories = Categories.forType(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.south_west),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.north_east),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => _onTypeChanged(s.first),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                autofocus: !widget.isEditing,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${money.currency.symbol} ',
                ),
                validator: _validateAmount,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Category',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categories)
                    ChoiceChip(
                      avatar: Icon(
                        c.icon,
                        size: 18,
                        color: _categoryId == c.id ? null : c.color,
                      ),
                      label: Text(c.label),
                      selected: _categoryId == c.id,
                      onSelected: (_) => setState(() => _categoryId = c.id),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date'),
                subtitle: Text(DateFormats.dayMonthYear.format(_date)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(widget.isEditing ? 'Save changes' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    final text = value?.trim().replaceAll(',', '') ?? '';
    if (text.isEmpty) return 'Enter an amount';
    final parsed = double.tryParse(text);
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than zero';
    if (parsed > 1000000000) return 'Amount is too large';
    return null;
  }
}
