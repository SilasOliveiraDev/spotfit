# SpotFit

App de música no estilo Spotify/Deezer, pensado para treino: playlists por foco (Cardio, Músculo, HIIT, Yoga, aquecimento e volta à calma), player com play/pause/stop/repeat, favoritos e listas próprias. Stack: **Flutter + Supabase**.

## O que já funciona

- Tela de entrada (e-mail/senha quando o Supabase está ligado) e **modo demo** sem backend
- Home com categorias de treino e playlists oficiais
- Player: play, pause, stop, próxima, anterior, seek, repeat (off / playlist / faixa)
- Favoritos
- Criar playlist (ex.: Cardio, Muscle)
- Busca por música, artista ou tipo de treino
- Schema pronto para **compartilhar** (`is_public` + `playlist_shares`) — UI ainda mostra “em breve”

## Rodar o app

```bash
flutter pub get
flutter run
```

Modo demo sobe sozinho se você **não** passar as chaves do Supabase.

## Ligar o Supabase

1. Crie um projeto em [supabase.com](https://supabase.com)
2. SQL Editor: rode `supabase/migrations/20260309120000_init_spotfit.sql`
3. Authentication → Providers: e-mail habilitado
4. Rode o app com as chaves **anon/publishable** (nunca a `service_role`):

```bash
flutter run --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sua-chave-anon
```

## O que você ainda precisa me passar (próxima etapa)

Nada disso bloqueia o demo, mas é o que falta para ficar “produto”:

1. **URL e chave anon** do projeto Supabase (ou autenticar o MCP do Supabase neste workspace)
2. **Áudios reais** (licença + arquivos no Storage) no lugar dos MP3 de demonstração
3. Capas/artistas oficiais, se quiser branding próprio
4. Login social (Google/Apple) e deep links
5. Regras de compartilhamento: feed público, convite por e-mail, ou só amigos
6. Plataforma alvo agora: Android, iOS, ou os dois

## Estrutura

- `lib/` — Flutter (UI, player, auth, catálogo)
- `supabase/migrations/` — Postgres + RLS
