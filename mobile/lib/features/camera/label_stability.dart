import 'dart:collection';

class LabelStability {
  LabelStability({this.window = 10});

  final int window;
  final _frames = Queue<String>();

  /// Registra o rótulo do frame e o retorna quando ele atinge os votos necessários na janela.
  String? add(String label, {required int required}) {
    _push(label);
    final votes = _frames.where((l) => l == label).length;
    return votes >= required ? label : null;
  }

  /// Registra um frame sem objeto, ocupando uma posição da janela sem zerar os votos.
  void miss() => _push('');

  /// Indica se o rótulo ainda aparece em algum frame da janela.
  bool hasVotes(String label) => _frames.contains(label);

  /// Adiciona um frame à janela descartando os mais antigos.
  void _push(String label) {
    _frames.addLast(label);
    while (_frames.length > window) {
      _frames.removeFirst();
    }
  }

  /// Esquece todos os votos.
  void clear() => _frames.clear();
}
