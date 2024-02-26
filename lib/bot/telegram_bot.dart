import 'package:suai_leetcode_bot/bot/scopes/telegram_scope.dart';
import 'package:suai_leetcode_bot/config/config.dart';
import 'package:suai_leetcode_bot/service/logger_service.dart';
import 'package:televerse/televerse.dart';

class TelegramBot {
  TelegramBot({
    required this.config,
    required List<TelegramScope<dynamic>> scopes,
  })  : _bot = Bot(config.telegramToken),
        _scopes = scopes;

  final Config config;
  final List<TelegramScope<dynamic>> _scopes;
  final Bot _bot;

  void start() {
    _bot
      ..onError((err) {
        LoggerService().writeError(err.error, err.stackTrace);
        // ignore: avoid_print
        print('Error ${err.error}, with stackTrace ${err.stackTrace}');
      })
      ..start();
    for (final TelegramScope(
          :commands,
          :callbackOnCommand,
          :predicate,
          :callbackOnMessage,
          :identificator,
          :queryPattern,
          :callbackOnQuery,
        ) in _scopes) {
      _bot
        ..command(commands, callbackOnCommand)
        ..filter(predicate, callbackOnMessage, name: identificator)
        ..callbackQuery(queryPattern, callbackOnQuery);
    }
  }
}
