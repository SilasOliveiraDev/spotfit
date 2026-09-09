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

## Rodar

```bash
flutter pub get
flutter run -d android
flutter run -d ios
```

A URL e a chave **anon** já estão em `lib/core/config.dart`. Não coloque `service_role` no Flutter.
