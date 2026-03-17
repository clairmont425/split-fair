import 'room.dart';

class SplitResult {
  final Room room;
  final double score;
  final double percentage;
  final double amount;

  const SplitResult({
    required this.room, required this.score,
    required this.percentage, required this.amount,
  });
}

List<SplitResult> calculateSplit({required List<Room> rooms, required double totalRent}) {
  if (rooms.isEmpty || totalRent <= 0) return [];
  final scores = rooms.map((r) => r.computeScore()).toList();
  final totalScore = scores.fold(0.0, (a, b) => a + b);
  return List.generate(rooms.length, (i) {
    final pct = scores[i] / totalScore;
    return SplitResult(room: rooms[i], score: scores[i], percentage: pct, amount: totalRent * pct);
  });
}