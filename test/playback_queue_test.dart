import 'package:flutter_test/flutter_test.dart';
import 'package:spotfit/player/playback_queue.dart';

void main() {
  test('avança e volta na fila', () {
    final queue = PlaybackQueue(trackIds: ['a', 'b', 'c']);
    expect(queue.currentId, 'a');
    expect(queue.moveNext(), isTrue);
    expect(queue.currentId, 'b');
    queue.movePrevious();
    expect(queue.currentId, 'a');
  });

  test('repeat all volta ao início', () {
    final queue = PlaybackQueue(trackIds: ['a', 'b'], repeat: RepeatMode.all);
    queue.index = 1;
    expect(queue.moveNext(), isTrue);
    expect(queue.currentId, 'a');
  });

  test('sem repeat para no fim', () {
    final queue = PlaybackQueue(trackIds: ['a', 'b']);
    queue.index = 1;
    expect(queue.moveNext(), isFalse);
    expect(queue.currentId, 'b');
  });

  test('repeat one não troca de faixa', () {
    final queue = PlaybackQueue(trackIds: ['a', 'b'], repeat: RepeatMode.one);
    expect(queue.moveNext(), isTrue);
    expect(queue.currentId, 'a');
  });

  test('ciclo de repeat', () {
    final queue = PlaybackQueue();
    expect(queue.nextRepeat(), RepeatMode.all);
    expect(queue.nextRepeat(), RepeatMode.one);
    expect(queue.nextRepeat(), RepeatMode.off);
  });
}
