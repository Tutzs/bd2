-- =====  Exame Pratico Final (EPF) - Base RADIO (ARTISTA/MUSICA/HITMUSICAL)  =====
--
--        SCRIPT DE CONSULTAS (DML)
--
-- Data Criacao ...........: 22/07/2025
-- Autor(es) ..............: Arthur Sousa
-- Banco de Dados .........: MySQL 8.0
-- Base de Dados (nome) ...: radio
--
-- PROJETO => 01 Tabela Auxiliar com SUBCONSULTA (Questao 01)
--         => 01 Visao (VIEW) (Questao 02)
--         => 01 Consulta estrategica sobre a VIEW (Questao 03)
--
-- OBSERVACAO: A restauracao do backup (item obrigatorio da Questao 01) foi
-- realizada fora deste script, via terminal (mysql -u root -p radio < backup),
-- conforme exigido no enunciado. Restauracao e avaliada apenas via Moodle e
-- nao deve constar como instrucao SQL neste arquivo.
--
-- ULTIMAS ATUALIZACOES
--   22/07/2025 => Criacao do script de respostas do EPF (Questoes 01, 02 e 03).
--
-- ---------------------------------------------------------

-- =====================================================================
-- QUESTAO 01
-- =====================================================================

-- 01: Tabela auxiliar HITMUSICAL_TEMP, replicando todos os atributos e regras de negocio (PK, NOT NULL e FKs) da tabela HITMUSICAL original.
CREATE TABLE HITMUSICAL_TEMP (
    id BIGINT NOT NULL AUTO_INCREMENT,
    station VARCHAR(50) NOT NULL,
    played_time DATE NOT NULL,
    artists_id BIGINT NOT NULL,
    songs_id BIGINT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT HITMUSICAL_TEMP_ARTISTA_FK FOREIGN KEY (artists_id)
        REFERENCES artista(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT HITMUSICAL_TEMP_MUSICA_FK FOREIGN KEY (songs_id)
        REFERENCES musica(id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- 01: Insercao unica com SUBCONSULTA, populando HITMUSICAL_TEMP somente com as tuplas de HITMUSICAL cuja station seja 'mai', 'more', 'edge' ou 'magic'.
INSERT INTO HITMUSICAL_TEMP (id, station, played_time, artists_id, songs_id)
SELECT id, station, played_time, artists_id, songs_id
FROM (
    SELECT id, station, played_time, artists_id, songs_id
    FROM hitmusical
    WHERE station IN ('mai', 'more', 'edge', 'magic')
) AS filtrada;

-- =====================================================================
-- QUESTAO 02
-- =====================================================================

-- 02: View estrategica reunindo HITMUSICAL_TEMP, ARTISTA e MUSICA por meio de juncoes internas, expondo id do hitmusical, station, played_time, artists_id, songs_id, nome do artista e nome da musica.
CREATE VIEW T2_EPFA_ARTHUR AS
SELECT
    ht.id         AS id_hitmusical,
    ht.station,
    ht.played_time,
    ht.artists_id,
    ht.songs_id,
    a.name        AS artist_name,
    m.name        AS song_name
FROM HITMUSICAL_TEMP ht
INNER JOIN artista a ON a.id = ht.artists_id
INNER JOIN musica  m ON m.id = ht.songs_id;

-- 02: Consulta simples que aciona a VIEW ja pronta, sem filtros ou juncoes adicionais, apenas exibindo todos os dados projetados por ela.
SELECT * FROM T2_EPFA_ARTHUR;

-- =====================================================================
-- QUESTAO 03
-- =====================================================================

-- 03: Consulta estrategica sobre a VIEW T2_EPFA_ARTHUR, trazendo o identificador do artista, o nome do artista e a quantidade de hitmusical registrados antes de 10/01/2020, filtrando somente as quantidades maiores que 100 e ordenando de forma ascendente pela quantidade.
SELECT
    artists_id,
    artist_name,
    COUNT(*) AS qtd_hitmusical
FROM T2_EPFA_ARTHUR
WHERE played_time < '2020-01-10'
GROUP BY artists_id, artist_name
HAVING COUNT(*) > 100
ORDER BY qtd_hitmusical ASC;
