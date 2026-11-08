import 'dart:math';

int levenshtein(String a, String b) {
  final dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));

  for (var i = 0; i <= a.length; i++) {
    dp[i][0] = i;
  }

  for (var j = 0; j <= b.length; j++) {
    dp[0][j] = j;
  }

  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = 1 + min(dp[i - 1][j], min(dp[i][j - 1], dp[i - 1][j - 1]));
      }
    }
  }

  return dp[a.length][b.length];
}
