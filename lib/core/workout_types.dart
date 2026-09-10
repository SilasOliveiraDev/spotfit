class WorkoutType {
  const WorkoutType({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final String id;
  final String label;
  final String emoji;
}

const workoutTypes = [
  WorkoutType(id: 'cardio', label: 'Cardio', emoji: '🏃'),
  WorkoutType(id: 'muscle', label: 'Músculo', emoji: '💪'),
  WorkoutType(id: 'hiit', label: 'HIIT', emoji: '⚡'),
  WorkoutType(id: 'yoga', label: 'Yoga', emoji: '🧘'),
  WorkoutType(id: 'warmup', label: 'Aquecimento', emoji: '🔥'),
  WorkoutType(id: 'cooldown', label: 'Relaxar', emoji: '🧊'),
];

WorkoutType workoutById(String id) {
  return workoutTypes.firstWhere(
    (item) => item.id == id,
    orElse: () => workoutTypes.first,
  );
}
