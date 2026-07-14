-- ===== Exame Pratico Final (EPF) - Base RADIO (ARTISTA/MUSICA/HITMUSICAL) =====
--
-- SCRIPT DE CONSULTAS (DML)
--
-- Data Criacao ...........: 14/07/2025
-- Autor(es) ..............: Kaua Richard
-- Banco de Dados .........: MySQL 8.0
-- Base de Dados (nome) ...: radio
--
-- PROJETO => 01 Tabela Auxiliar com SUBCONSULTA (Questao 01)
-- => 01 Visao (VIEW) (Questao 02)
-- => 01 Consulta estrategica sobre a VIEW (Questao 03)
--
-- OBSERVACAO: A restauracao do backup (item obrigatorio da Questao 01) foi
-- realizada fora deste script, via terminal (mysql -u root -p radio < backup),
-- conforme exigido no enunciado. Restauracao e avaliada apenas via Moodle e
-- nao deve constar como instrucao SQL neste arquivo.
--
-- ULTIMAS ATUALIZACOES
-- 22/07/2025 => Criacao do script de respostas do EPF (Questoes 01, 02 e 03).
--
-- ---------------------------------------------------------
USE radio;

-- =====================================================================
-- QUESTAO 01 (Oficial)
-- =====================================================================
-- ENUNCIADO: Analise a base de dados disponível e elabore uma instrução SQL 
-- correta para criar uma nova tabela chamada HITMUSICAL_TEMP que tenha as 
-- mesmas colunas e restrições da tabela original HITMUSICAL. A nova tabela 
-- receberá somente as tuplas que tenham no atributo station as estações 
-- 'mai', 'more', 'edge' ou 'magic'. Utilize uma subconsulta de inserção.

DROP TABLE IF EXISTS HITMUSICAL_TEMP; 
CREATE TABLE HITMUSICAL_TEMP(
    id BIGINT NOT NULL,
    station VARCHAR(50) NOT NULL,  
    played_time DATE NOT NULL,
    artists_id BIGINT NOT NULL,
    songs_id BIGINT NOT NULL,
    CONSTRAINT PK_HITMUSICAL_TEMP PRIMARY KEY (id),
    CONSTRAINT FK_HITMUSICAL_TEMP_ARTISTA FOREIGN KEY (artists_id) REFERENCES artista(id),
    CONSTRAINT FK_HITMUSICAL_TEMP_MUSICA FOREIGN KEY (songs_id) REFERENCES musica(id)
);

-- subconsulta de insercao 
INSERT INTO HITMUSICAL_TEMP (id, station, played_time, artists_id, songs_id)
SELECT id, station, played_time, artists_id, songs_id
FROM HITMUSICAL
WHERE station IN ('mai', 'more', 'edge', 'magic');


-- =====================================================================
-- QUESTAO 02 (Oficial)
-- =====================================================================
-- ENUNCIADO: Elabore uma VIEW que seja estratégica para análises. 
-- O nome será T2_EPFA_ seguida do seu primeiro nome. A visão deverá 
-- apresentar da tabela HITMUSICAL_TEMP (id, station, played_time, 
-- artists_id, songs_id) e das tabelas ARTISTA e MUSICA o atributo name.
-- Após a criação, faça um SELECT simples mostrando todos os dados.

CREATE OR REPLACE VIEW T2_EPFA_KAUA AS 
SELECT 
    h.id AS hitmusical_id,
    h.station,
    h.played_time,
    h.artists_id,
    h.songs_id,
    art.name AS artist_name,
    musc.name AS music_name
FROM HITMUSICAL_TEMP h
INNER JOIN artista art ON h.artists_id = art.id
INNER JOIN musica musc ON h.songs_id = musc.id;
    
SELECT hitmusical_id, station, played_time, artists_id, songs_id, artist_name, music_name 
FROM T2_EPFA_KAUA;


-- =====================================================================
-- QUESTAO 03 (Oficial)
-- =====================================================================
-- ENUNCIADO: Use a VIEW criada na questão anterior e apresente, por artista, 
-- a quantidade de hitmusical registrados antes de 10/01/2020. A consulta 
-- deve ser ordenada de forma ascendente e apresentar somente as quantidades 
-- maiores que 100.

SELECT 
    artists_id, 
    artist_name,
    COUNT(hitmusical_id) AS quantidade_hitmusical
FROM T2_EPFA_KAUA
WHERE played_time < '2020-01-10'
GROUP BY artists_id, artist_name
HAVING quantidade_hitmusical > 100
ORDER BY quantidade_hitmusical ASC;


-- =====================================================================
-- QUESTAO 04 (Treino: Arquivamento)
-- =====================================================================
-- ENUNCIADO: Crie uma nova tabela HITMUSICAL_ARQUIVO com as mesmas regras da 
-- tabela original. Popule ela com as tuplas que tenham data de reprodução 
-- anterior a 01 de Janeiro de 2010 usando uma subconsulta.

CREATE TABLE HITMUSICAL_ARQUIVO(
    id BIGINT NOT NULL,
    station VARCHAR(50) NOT NULL,  
    played_time DATE NOT NULL,
    artists_id BIGINT NOT NULL,
    songs_id BIGINT NOT NULL,
    CONSTRAINT PK_HITMUSICAL_ARQ PRIMARY KEY (id),
    CONSTRAINT FK_HITMUSICAL_ARQ_ARTISTA FOREIGN KEY (artists_id) REFERENCES artista(id),
    CONSTRAINT FK_HITMUSICAL_ARQ_MUSICA FOREIGN KEY (songs_id) REFERENCES musica(id)
);

INSERT INTO HITMUSICAL_ARQUIVO(id, station, played_time, artists_id, songs_id)
SELECT id, station, played_time, artists_id, songs_id
FROM HITMUSICAL
WHERE played_time  < '2010-01-01';


-- =====================================================================
-- QUESTAO 05 (Treino: View de Auditoria)
-- =====================================================================
-- ENUNCIADO: Crie a VIEW VW_AUDITORIA_CAVALCANTE juntando a sua tabela 
-- HITMUSICAL_ARQUIVO com musica e artista. Projete o ID, estação, nome 
-- da música, tamanho da música e nome do artista. Finalize com um SELECT *.

CREATE OR REPLACE VIEW VW_AUDITORIA_CAVALCANTE AS
SELECT 
     ha.id AS arquivo_id,
     ha.station,
     m.name AS musica_nome,
     m.length AS musica_tamanho,
     a.name AS artista_name
FROM HITMUSICAL_ARQUIVO  ha
INNER JOIN musica m ON ha.songs_id = m.id
INNER JOIN artista a ON ha.artists_id = a.id;
    
SELECT arquivo_id, station, musica_nome, musica_tamanho, artista_name
FROM VW_AUDITORIA_CAVALCANTE;
    
    
-- =====================================================================
-- QUESTAO 06 (Treino: Filtro de Tempo Total)
-- =====================================================================
-- ENUNCIADO: Usando a VW_AUDITORIA_CAVALCANTE, responda: "Quais artistas 
-- tiveram um tempo total de reprodução superior a 5.000 segundos, e qual 
-- foi esse tempo total?". Ordene de forma crescente.

SELECT SUM(musica_tamanho) AS tempo_total, artista_name
FROM VW_AUDITORIA_CAVALCANTE
GROUP BY artista_name
HAVING tempo_total > 5000
ORDER BY tempo_total;


-- =====================================================================
-- QUESTAO 07 (Treino: Desafio do Anti-Join)
-- =====================================================================
-- ENUNCIADO: Retorne o ID e NOME dos artistas cadastrados no banco que 
-- NUNCA tiveram nenhuma música tocada na estação 'magic'. 
-- (Filtro de Exclusão).

SELECT 
    a.id, 
    a.name
FROM artista a
LEFT JOIN HITMUSICAL hit ON a.id = hit.artists_id AND hit.station = 'magic'
WHERE hit.played_time IS NULL;


-- =====================================================================
-- QUESTAO 08 (Treino: Filtro Completo de Faturamento)
-- =====================================================================
-- ENUNCIADO: Retorne o nome do artista e o total de reproduções geradas. 
-- Filtre apenas músicas com o tamanho (length) preenchido (IS NOT NULL). 
-- Mostre apenas quem teve mais de 50 reproduções, ordenando decrescente.

SELECT 
    a.name AS nome_artista,
    COUNT(hit.artists_id) AS tempo_musica
FROM artista a
INNER JOIN HITMUSICAL hit ON a.id = hit.artists_id
INNER JOIN musica m ON hit.songs_id = m.id
WHERE m.length IS NOT NULL
GROUP BY(a.name)
HAVING tempo_musica > 50
ORDER BY tempo_musica DESC;

