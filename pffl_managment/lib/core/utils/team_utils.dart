String getTeamAbbreviation(String teamName) {
  if (teamName.isEmpty) return teamName;

  final words = teamName
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  if (words.isEmpty) return teamName;

  // Rule: First word + first letter of second word
  String firstWord = words[0];

  // If "Unknown Team", we should ideally show something better, but following the rule:
  // "Unknown T"

  if (words.length > 1) {
    String secondWordFirstLetter = words[1][0].toUpperCase();
    return "$firstWord $secondWordFirstLetter";
  }

  return firstWord;
}
