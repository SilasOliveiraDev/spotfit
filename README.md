# SpotFit

App Android e iOS de música para treino (Flutter + Supabase). Login só com e-mail e senha. Playlist compartilhada **somente por link** (`spotfit://playlist/{token}`).

O catálogo oficial (faixas e playlists Cardio/Músculo/…) deve ser gerido no **dashboard React** com a `service_role`. Este app não insere faixa de catálogo.

## Schema

Arquivo único para colar no SQL Editor do projeto `elvdhgrpwutyonbuzgvb`:

`supabase/migrations/20260309120000_init_spotfit.sql`

Tabelas: `profiles`, `tracks`, `playlists`, `playlist_tracks`, `favorites`, `playlist_share_links`.  
RPC: `get_shared_playlist(p_token)` — único jeito de abrir playlist de outra pessoa.

## Auth no dashboard Supabase

- Providers: **Email** ligado; sociais desligados
- URL Configuration: Site URL do app e Redirect `spotfit://login-callback`

## No GitHub

Repositório: https://github.com/SilasOliveiraDev/spotfit

Depois do merge em `main`, o GitHub Actions publica o web em:

https://silasoliveiradev.github.io/spotfit/

Em **Settings → Pages → Source** escolha **GitHub Actions** na primeira vez.
No Supabase → Authentication → URL Configuration, acrescente essa URL nas Redirect URLs.

## Rodar no navegador (Chrome)

Na pasta do projeto, no **seu** computador (não use o localhost de outra máquina):

```bash
flutter pub get
flutter run -d chrome
```

Se o Chrome não aparecer na lista: `flutter devices` e instale o Chrome.
Build estático (abre sem debugger):

```bash
flutter build web
python3 -m http.server 8080 --directory build/web
```

Depois abra http://localhost:8080

## Android / iOS

```bash
flutter pub get
flutter run -d android
flutter run -d ios
```

A URL e a chave **anon** já estão em `lib/core/config.dart`. Não coloque `service_role` no Flutter.
