import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_model.dart';
import '../providers/category_provider.dart';

class CreateCategorySheet extends ConsumerStatefulWidget {
  const CreateCategorySheet({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateCategorySheet> createState() =>
      _CreateCategorySheetState();
}

class _CreateCategorySheetState extends ConsumerState<CreateCategorySheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  IconData? _selectedIcon;

  final List<IconData> _availableIcons = [
    Icons.shopping_bag,
    Icons.restaurant,
    Icons.directions_car,
    Icons.flight,
    Icons.fitness_center,
    Icons.computer,
    Icons.work,
    Icons.movie,
    Icons.account_balance_wallet,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _createCategory() {
    if (_nameController.text.isEmpty ||
        _limitController.text.isEmpty ||
        _selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an icon'),
        ),
      );
      return;
    }

    final double? limit = double.tryParse(_limitController.text);
    if (limit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid limit amount')),
      );
      return;
    }

    final newCategory = BudgetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameController.text,
      spentAmount: 0.0,
      limitAmount: limit,
      icon: _selectedIcon!,
      color: Colors.indigoAccent, // Default color for custom categories
    );

    ref.read(walletProvider.notifier).addBudget(newCategory);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen height to make bottom sheet responsive
    final height = MediaQuery.of(context).size.height * 0.9;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row with Back Button and Wallet Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, size: 20),
                      ),
                      Image.asset(
                        'assets/logo/logo.png',
                        width: 32,
                        height: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Banner Image
                  Center(
                    child: Image.asset(
                      'assets/images/Background+Shadow.png',
                      height: 250,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Center(child: Text('Image Placeholder')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Titles
                  const Text(
                    'First things first',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Create your first category to start tracking\nyour spending with precision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14.0,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Category Name Input
                  Text(
                    'Category Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Groceries',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Limit Input
                  Text(
                    'Limit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _limitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: '00.0',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Select Icon Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Icon',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        'Line Style',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIcon = icon;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1)
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16.0),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 2.0,
                                  )
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40.0), // Padding before button
                ],
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _createCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Category',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Icon(Icons.add_circle_outline, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
