/*This query gives you the TOP 3 Songs that you've played after a given song with a count [x] how often you've played it after to brwose and find ideas for your next set*/
WITH HistoryPlaylists AS (
    SELECT p.id, pt.track_id, pt.position
    FROM Playlists p
    JOIN PlaylistTracks pt ON p.id = pt.playlist_id
    WHERE p.name GLOB '202[3-9]*' OR p.name GLOB '2030*'
),
SongPairs AS (
    SELECT 
        lp1.artist || ' - ' || lp1.title AS Song1,
        lp2.artist || ' - ' || lp2.title AS Song2,
        COUNT(*) AS mix_count
    FROM HistoryPlaylists hp1
    JOIN HistoryPlaylists hp2 ON hp1.id = hp2.id AND hp1.position + 1 = hp2.position
    JOIN library lp1 ON hp1.track_id = lp1.id
    JOIN library lp2 ON hp2.track_id = lp2.id
    GROUP BY Song1, Song2
    HAVING COUNT(*) > 1
),
TopMixes AS (
    SELECT Song1, Song2, mix_count,
           ROW_NUMBER() OVER (PARTITION BY Song1 ORDER BY mix_count DESC) AS row_num
    FROM SongPairs
)
SELECT 
    Song1 AS "Song",
    GROUP_CONCAT(Song2 || ' [' || mix_count || ']', ', ') AS "Top 3 Songs After"
FROM TopMixes
WHERE row_num <= 3
GROUP BY Song1;
