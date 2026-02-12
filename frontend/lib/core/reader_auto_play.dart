/// Flag để Reader tự động phát audio khi mở bằng "Nghe ngay".
/// Set trước khi push ReaderRoute, ReaderView sẽ check và auto-play.
class ReaderAutoPlay {
  static bool _requested = false;

  static void request() {
    _requested = true;
  }

  static bool consume() {
    final v = _requested;
    _requested = false;
    return v;
  }
}
