# Aleesa-Telegram-bot - Болтливый бот для Telegram

## Что это такое

Это бот, основанный на перловых модулях [Telegram::Bot][1] для работы в
мессенджере Telegram и [Hailo][2] для генерации "умной" беседы.

Для корректной работы, пришлось форкнуть [Telegram::Bot][1], чтобы обновить
интерфейс API до [Telegram Bot API v5][3]. Для избежания неоднозначностей, модуль
пришлось переименовать и теперь он идёт в составе бота. Возможно, когда модуль
отлежится и будет похож на стабильный, он стнет самостоятельным и поселится на
metacpan.org

Конфиг бота должен лежать в **data/config.json**. Пример конфига расположен в
**data/sample_config.json**.

Бота можно запустить через **bin/aleesa-telegram-bot** и он взлетит, как юниксовый
демон (сделает двойной fork() и отцепится от stdio).

## Установка

Чтобы запустить приложение, его надо "забурстрапить" - загрузить и собрать все
необходимые зависимости.

Понадобится perl-5.18, а желательно новее, "Development Tools" или подобная
группа пакетов , perl, perl-devel, perl-local-lib, perl-app-cpanm, sqlite-devel,
zlib-devel, openssl-devel, libdb4-devel (Berkeley DB devel), make, hiredis-devel.

После установки этих пакетов, можно будет запустить:

```bash

bash bootstrap.sh

```

и, по идее, всё что нужно будет выкачено, собрано и разложено куда надо.

## Запуск и работа

Бот не использует [вебхуки][4], поэтому ничего дополнительного, кроме хорошего
подключения к интернету ему не нужно.


[1]: https://metacpan.org/pod/Telegram::Bot
[2]: https://metacpan.org/pod/Hailo
[3]: https://core.telegram.org/bots/api
[4]: https://core.telegram.org/bots/api#getting-updates
