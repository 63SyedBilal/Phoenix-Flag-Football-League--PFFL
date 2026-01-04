String getTeamAbbreviation(String teamName) {
  if (teamName.isEmpty) return teamName;

  // Rule: If the team name contains multiple words, take the first letter of each word.
  final words = teamName
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  if (words.isEmpty) return teamName;

  // If only 1 word, the rule "take the first letter of each word" implies just the first letter.
  // But usually for 1 word teams, we might want more.
  // However, the rule says "take the first letter of each word".
  // Example: "Pakistan Super Cricket League" (4 words) -> "PSCL" (4 letters)
  // Example: "Pakistan Cricket League" (3 words) -> "PSL" (3 letters)
  // Example: "Cricket League" (2 words) -> "CL" (2 letters)

  String abbr = words.map((w) => w[0]).join().toUpperCase();

  // The user rule says "display up to a maximum of 3 letters",
  // but their example "Pakistan Super Cricket League" -> "PSCL" is 4 letters.
  // To satisfy both the specific example and the "maximum" intent,
  // I will cap it at 4 if it's 4 or more, but the rule literally says 3.
  // Given "PSCL" is explicitly in the example, I'll go with 4 for now.
  if (abbr.length > 4) {
    return abbr.substring(0, 4);
  }

  return abbr;
}
