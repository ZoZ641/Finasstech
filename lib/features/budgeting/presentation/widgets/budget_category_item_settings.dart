import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../data/models/budget_category_model.dart';

class BudgetCategoryItemSettings extends StatefulWidget {
  final BudgetCategoryModel category;
  final Function(String) onNameChanged;
  final Function(double, double) onMinMaxChanged;
  final VoidCallback onDelete;

  const BudgetCategoryItemSettings({
    super.key,
    required this.category,
    required this.onNameChanged,
    required this.onMinMaxChanged,
    required this.onDelete,
  });

  @override
  State<BudgetCategoryItemSettings> createState() =>
      _BudgetCategoryItemSettingsState();
}

class _BudgetCategoryItemSettingsState
    extends State<BudgetCategoryItemSettings> {
  late TextEditingController _nameController;
  late TextEditingController _minPercentageController;
  late TextEditingController _maxPercentageController;
  late FocusNode _nameFocusNode;
  late FocusNode _minFocusNode;
  late FocusNode _maxFocusNode;

  // Store original values to only update when changed
  late String _originalName;
  late double _originalMin;
  late double _originalMax;

  @override
  void initState() {
    super.initState();
    _originalName = widget.category.name;
    _originalMin = widget.category.minRecommendedPercentage;
    _originalMax = widget.category.maxRecommendedPercentage;

    _nameController = TextEditingController(text: widget.category.name);
    _minPercentageController = TextEditingController(
      text: widget.category.minRecommendedPercentage.toStringAsFixed(1),
    );
    _maxPercentageController = TextEditingController(
      text: widget.category.maxRecommendedPercentage.toStringAsFixed(1),
    );

    _nameFocusNode = FocusNode();
    _minFocusNode = FocusNode();
    _maxFocusNode = FocusNode();

    _nameFocusNode.addListener(_onNameFocusChange);
    _minFocusNode.addListener(_onMinFocusChange);
    _maxFocusNode.addListener(_onMaxFocusChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minPercentageController.dispose();
    _maxPercentageController.dispose();
    _nameFocusNode.removeListener(_onNameFocusChange);
    _minFocusNode.removeListener(_onMinFocusChange);
    _maxFocusNode.removeListener(_onMaxFocusChange);
    _nameFocusNode.dispose();
    _minFocusNode.dispose();
    _maxFocusNode.dispose();
    super.dispose();
  }

  void _onNameFocusChange() {
    if (!_nameFocusNode.hasFocus) {
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != _originalName) {
        widget.onNameChanged(newName);
        _originalName = newName;
      } else if (newName.isEmpty) {
        // Reset to original if empty
        _nameController.text = _originalName;
      }
    }
  }

  void _onMinFocusChange() {
    if (!_minFocusNode.hasFocus) {
      _handleMinMaxChange();
    }
  }

  void _onMaxFocusChange() {
    if (!_maxFocusNode.hasFocus) {
      _handleMinMaxChange();
    }
  }

  void _handleMinMaxChange() {
    final minPercentage =
        double.tryParse(_minPercentageController.text) ?? _originalMin;
    final maxPercentage =
        double.tryParse(_maxPercentageController.text) ?? _originalMax;

    // Only update if values have changed
    if (minPercentage != _originalMin || maxPercentage != _originalMax) {
      // Ensure min is not greater than max
      if (minPercentage <= maxPercentage) {
        widget.onMinMaxChanged(minPercentage, maxPercentage);
        _originalMin = minPercentage;
        _originalMax = maxPercentage;
      } else {
        // Reset to valid values
        _minPercentageController.text = _originalMin.toStringAsFixed(1);
        _maxPercentageController.text = _originalMax.toStringAsFixed(1);

        // Optional: Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Minimum percentage cannot be greater than maximum'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete category',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPercentageController,
                    focusNode: _minFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Min Percentage',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPercentageController,
                    focusNode: _maxFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Max Percentage',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppPallete.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Current: ${widget.category.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.category.usage > 0) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: widget.category.usage / widget.category.amount,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.category.usage > widget.category.amount
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Usage: £${widget.category.usage.toStringAsFixed(2)} / £${widget.category.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color:
                      widget.category.usage > widget.category.amount
                          ? Colors.red
                          : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
