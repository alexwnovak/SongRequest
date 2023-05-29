$j = Get-Content songlist.json | ConvertFrom-Json
$c = 0

@"
final songList = <Song>[];
"@

$j.songs | Where-Object {$_.playlive -eq 'yes'} | Select-Object artist,title | ForEach-Object {
    $c++
@"
songList.add(Song(
  id: $c,
  artist: '$($_.artist)',
  title: '$($_.title)',
  album: '',
  year: 0,
));
"@
}