import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../data/models/budget_category_model.dart';

class BudgetCategoryItemCreate extends StatefulWidget {
  final BudgetCategoryModel category;
  final double forecastedSales;
  final Function(double) onPercentageChanged;
  final Function(double) onAmountChanged;
  const BudgetCategoryItemCreate({
    super.key,
    required this.category,
    required this.forecastedSales,
    required this.onPercentageChanged,
    required this.onAmountChanged,
  });

  @override
  State<BudgetCategoryItemCreate> createState() =>
      _BudgetCategoryItemCreateState();
}

class _BudgetCategoryItemCreateState extends State<BudgetCategoryItemCreate> {
  late TextEditingController _percentageController;
  late TextEditingController _amountController;
  bool _isPercentageEditing = false;
  bool _isAmountEditing = false;

  @override
  void initState() {
    super.initState();
    _percentageController = TextEditingController(
      text: widget.category.percentage.toStringAsFixed(1),
    );
    _amountController = TextEditingController(
      text: widget.category.amount.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(covariant BudgetCategoryItemCreate oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update if we're not currently editing
    if (!_isPercentageEditing) {
      _percentageController.text = widget.category.percentage.toStringAsFixed(
        1,
      );
    }

    if (!_isAmountEditing) {
      _amountController.text = widget.category.amount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate color based on if percentage is within recommended range
    Color statusColor = AppPallete.primaryColor;
    if (widget.category.percentage < widget.category.minRecommendedPercentage) {
      statusColor = Colors.orange;
    } else if (widget.category.percentage >
        widget.category.maxRecommendedPercentage) {
      statusColor = Colors.red;
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.category.name[0].toUpperCase() +
                        widget.category.name.substring(1).toLowerCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.category.minRecommendedPercentage}% - ${widget.category.maxRecommendedPercentage}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Add space for the delete button
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus && _isPercentageEditing) {
                        _handlePercentageSubmit();
                      }
                      setState(() {
                        _isPercentageEditing = hasFocus;
                      });
                    },
                    child: TextField(
                      controller: _percentageController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Percentage',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _handlePercentageSubmit(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus && _isAmountEditing) {
                        _handleAmountSubmit();
                      }
                      setState(() {
                        _isAmountEditing = hasFocus;
                      });
                    },
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '£',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _handleAmountSubmit(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Status indicator
            if (widget.category.percentage > 0)
              LinearProgressIndicator(
                value: widget.category.percentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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

  void _handlePercentageSubmit() {
    final percentageText = _percentageController.text.trim();
    final percentage = double.tryParse(percentageText) ?? 0.0;

    // Clamp to valid range (0-100)
    final clampedPercentage = percentage.clamp(0.0, 100.0);

    if (clampedPercentage != widget.category.percentage) {
      widget.onPercentageChanged(clampedPercentage);
    }
  }

  void _handleAmountSubmit() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    // Ensure amount is not negative
    final validAmount = amount < 0 ? 0.0 : amount;

    if (validAmount != widget.category.amount) {
      widget.onAmountChanged(validAmount);
    }
  }
}
