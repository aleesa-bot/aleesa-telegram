# Aleesa-Telegram-bot - Telegram chatty bot

## About

It is based on Perl modules [Telegram::Bot][1] and [Hailo][2] as conversation
generator.

I have to fork [Telegram::Bot][1] and update it according to features appeared
in [Telegram Bot API v5][3]. Also, I decide to rename it to avoid collision in
the future, now it is Teapot::Bot and is bundled with bot. When lib becomes
mature enough, maybe I release it separately.

Bot config located in **data/config.json**, sample config provided as
**data/sample_config.json**.

Bot can be run via **bin/aleesa-telegram-bot** and acts as daemon (double
fork() and detaches stdio).

## Installation

In order to run this application, you need to "bootstrap" it - download and
build all required dependencies and libraries.

You'll need perl-5.18 or newer, "Development Tools" or similar group of
packages, perl, perl-devel, perl-local-lib, perl-app-cpanm, sqlite-devel,
zlib-devel, openssl-devel, libdb4-devel (Berkeley DB devel), make,
hiredis-devel.

After installing required dependencies it is possible to run:

```bash

bash bootstrap.sh

```

and all libraries should be downloaded, built, tested and installed.

## Running

This bot does not [ultilize][4] webhooks, so in order to run it only well
internet connection is required, no public-available ip address is needed.


[1]: https://metacpan.org/pod/Telegram::Bot
[2]: https://metacpan.org/pod/Hailo
[3]: https://core.telegram.org/bots/api
[4]: https://core.telegram.org/bots/api#getting-updates
