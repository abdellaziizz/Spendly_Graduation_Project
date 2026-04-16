class VoiceExpenseData {
  final String title;
  final String description;
  final String category;
  final double amount;

  VoiceExpenseData({
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
  });
}

class VoiceParser {
  static final Map<String, List<String>> _categoryKeywords = {
    'Gym / Fitness': ['gym', 'workout', 'fitness', 'membership', 'protein'],
    'Food / Dining': ['dinner', 'lunch', 'restaurant', 'food', 'cafe', 'coffee', 'burger', 'pizza', 'breakfast'],
    'Transportation': ['uber', 'taxi', 'fuel', 'gas', 'car', 'bus', 'train', 'flight', 'ticket'],
    'Groceries': ['supermarket', 'groceries', 'market', 'walmart', 'store', 'milk', 'bread'],
    'Bills & Subscriptions': ['bill', 'subscription', 'payment', 'internet', 'netflix', 'spotify', 'electricity', 'water'],
  };

  static VoiceExpenseData parse(String transcribedText) {
    if (transcribedText.isEmpty) {
      return VoiceExpenseData(title: 'Unknown', description: '', category: 'Other', amount: 0.0);
    }

    final lowerText = transcribedText.toLowerCase();

    // 1. Extract Amount
    // Matches patterns like "45", "120.50", "3,500"
    final amountRegex = RegExp(r'\$?\b(\d+[\.,]?\d*)\b');
    final matches = amountRegex.allMatches(lowerText);
    
    double maxAmount = 0.0;
    for (final match in matches) {
      final valStr = match.group(1)?.replaceAll(',', '');
      if (valStr != null) {
        final val = double.tryParse(valStr);
        if (val != null && val > maxAmount) {
           // Basic heuristic: pick the largest number mentioned as the amount
           // (Could be improved, but works for simple sentences "I spent 45 on dinner and 12 on tips")
           maxAmount = val; 
        }
      }
    }

    // 2. Extract Category
    String detectedCategory = 'Other';
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          detectedCategory = entry.key;
          break; // Stop checking keywords for this category
        }
      }
      if (detectedCategory != 'Other') break; // Stop checking other categories if found
    }

    // 3. Synthesize Title
    // If we detected a category, we can use the keyword matched or the category name
    String title = detectedCategory;
    if (detectedCategory == 'Other') {
      // Pick first 2 words if no category
      final words = transcribedText.split(RegExp(r'\s+'));
      if (words.length > 2) {
        title = '${words[0]} ${words[1]}';
      } else {
         title = transcribedText;
      }
    } else {
        // Try to find the exact keyword used
        for (final keyword in _categoryKeywords[detectedCategory]!) {
            if (lowerText.contains(keyword)) {
                // capitalize first letter
                title = keyword[0].toUpperCase() + keyword.substring(1);
                break;
            }
        }
    }

    // Ensure title is reasonably short
    if (title.length > 20) {
       title = title.substring(0, 20);
    }

    // 4. Description is the full sentence
    String description = transcribedText;

    return VoiceExpenseData(
      title: title,
      description: description,
      category: detectedCategory,
      amount: maxAmount,
    );
  }
}
