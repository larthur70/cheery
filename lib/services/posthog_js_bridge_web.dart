import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Direct `window.posthog` calls for Flutter web.
///
/// Uses [JSObject] + [dart:js_interop_unsafe] so we call the same methods as
/// the working `index.html` boot capture (`opt_in_capturing` + `capture`).
@JS('window.posthog')
external JSObject? get _posthogJs;

@JS('console')
external JSObject get _console;

abstract final class PosthogJsBridge {
  static bool get isAvailable => _posthogJs != null;

  static void _log(String message) {
    _console.callMethod('info'.toJS, '[Cheery][Analytics] $message'.toJS);
  }

  static JSObject get _ph {
    final ph = _posthogJs;
    if (ph == null) {
      throw StateError('window.posthog is not available');
    }
    return ph;
  }

  static void identify(String userId) {
    final ph = _ph;
    ph.callMethod('opt_in_capturing'.toJS);
    ph.callMethod('identify'.toJS, userId.toJS);
    _log('identify($userId)');
  }

  static void reset() {
    _ph.callMethod('reset'.toJS);
    _log('reset()');
  }

  static void capture(
    String eventName,
    Map<String, Object> properties,
  ) {
    final ph = _ph;
    ph.callMethod('opt_in_capturing'.toJS);
    ph.callMethod(
      'capture'.toJS,
      eventName.toJS,
      properties.jsify(),
      {'send_instantly': true}.jsify(),
    );
    _log('capture($eventName)');
  }
}
