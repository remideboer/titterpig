class NameFormatter {
  /// Formats a name by capitalizing the first letter of each word
  /// and converting the rest to lowercase.
  /// 
  /// Example:
  /// - "john doe" -> "John Doe"
  /// - "JANE SMITH" -> "Jane Smith"
  /// - "mary-jane" -> "Mary-Jane"
  static String formatName(String name) {
    if (name.isEmpty) return name;
    
    // Split by spaces and hyphens, but keep the delimiters
    final words = name.split(RegExp(r'([ -])'));
    final delimiters = name.split(RegExp(r'[^ -]')).where((s) => s.isNotEmpty).toList();
    
    final formattedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();
    
    // Recombine words with their original delimiters
    final result = StringBuffer();
    for (var i = 0; i < formattedWords.length; i++) {
      result.write(formattedWords[i]);
      if (i < delimiters.length) {
        result.write(delimiters[i]);
      }
    }
    
    return result.toString();
  }
} 