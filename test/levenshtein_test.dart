import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/services/levenshtein.dart';

void main() {
  group('levenshtein', () {
    test('same words = 0', () {
      expect(levenshtein('sbi', 'sbi'), 0);
    });
    test('one substitution', () {
      expect(levenshtein('sbi', 'sbl'), 1);
    });
    test('one insertion', () {
      expect(levenshtein('sbi', 'sbii'), 1);
    });
    test('one deletion', () {
      expect(levenshtein('sbi', 'sb'), 1);
    });
    test('empty vs word = word length', () {
      expect(levenshtein('', 'abc'), 3);
      expect(levenshtein('abc', ''), 3);
    });
    test('both empty = 0', () {
      expect(levenshtein('', ''), 0);
    });
    test('classic textbook example', () {
      expect(levenshtein('kitten', 'sitting'), 3);
    });
    test('completely different, same length', () {
      expect(levenshtein('sbi', 'xyz'), 3);
    });
    test('real-looking typo', () {
      expect(levenshtein('hdfcbank.com', 'hdfcbamk.com'), 1);
    });
    test('order of arguments does not matter', () {
      expect(levenshtein('paytm', 'paytn'), levenshtein('paytn', 'paytm'));
    });
  });
}
