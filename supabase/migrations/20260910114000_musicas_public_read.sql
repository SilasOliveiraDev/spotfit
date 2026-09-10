-- Catálogo de áudio público para o player (Android/iOS/web).
update storage.buckets set public = true where id = 'musicas';

drop policy if exists "musicas_public_read" on storage.objects;
create policy "musicas_public_read"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'musicas');
