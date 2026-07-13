-- questao 1 
delete from hitmusical 
where songs_id in 
(select id 
from musica 
where length < 180);

-- questao 2 
create or replace view T2_EPFB_ARTHUR as
select h.id, h.station, h.played_time, h.artists_id, h.songs_id, a.name as nomeArtista, m.name as nomeMusica, m.length as duração
from hitmusical h
join artista a on a.id = h.artists_id
join musica m on m.id = h.songs_id;

select * from T2_EPFB_ARTHUR;

-- questão 3
select songs_id, nomeMusica, count(*) as contagem
from T2_EPFB_ARTHUR
group by songs_id, nomeMusica
having contagem > 150
order by contagem desc;