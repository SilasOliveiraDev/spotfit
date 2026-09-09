enum RepeatMode { off, all, one }

class PlaybackQueue {
  PlaybackQueue({
    List<String> trackIds = const [],
    int index = 0,
    this.repeat = RepeatMode.off,
    this.shuffle = false,
  })  : trackIds = List.of(trackIds),
        index = trackIds.isEmpty ? 0 : index.clamp(0, trackIds.length - 1);

  final List<String> trackIds;
  int index;
  RepeatMode repeat;
  bool shuffle;

  bool get isEmpty => trackIds.isEmpty;
  String? get currentId => isEmpty ? null : trackIds[index];

  RepeatMode nextRepeat() {
    repeat = RepeatMode.values[(repeat.index + 1) % RepeatMode.values.length];
    return repeat;
  }

  bool moveNext() {
    if (isEmpty) return false;
    if (repeat == RepeatMode.one) return true;
    if (index < trackIds.length - 1) {
      index += 1;
      return true;
    }
    if (repeat == RepeatMode.all) {
      index = 0;
      return true;
    }
    return false;
  }

  bool movePrevious() {
    if (isEmpty) return false;
    if (index > 0) {
      index -= 1;
      return true;
    }
    if (repeat == RepeatMode.all) {
      index = trackIds.length - 1;
      return true;
    }
    return true;
  }

  void replace(List<String> ids, {int startIndex = 0}) {
    trackIds
      ..clear()
      ..addAll(ids);
    index = ids.isEmpty ? 0 : startIndex.clamp(0, ids.length - 1);
  }
}
