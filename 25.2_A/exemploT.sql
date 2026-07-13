-- =====  Exame Pratico Final (EPF) - Base PRODUTO/DEPOSITO/MARCA/VENDEDOR  =====
--
--        SCRIPT DE CONSULTAS (DML)
--
-- Data Criacao ...........: 14/07/2026
-- Autor(es) ..............: Arthur Sousa
-- Banco de Dados .........: MySQL 8.0
-- Base de Dados (nome) ...: <preencher com o nome do banco restaurado do Modelo A>
--
-- PROJETO => 03 Consultas (02, 03 e 04)
--         => 01 Visao (VIEW)
--         => 01 Indice (somente se a analise da questao 02 indicar necessidade)
--
-- ULTIMAS ATUALIZACOES
--   14/07/2026 => Criacao do script de respostas do EPF (Questoes 02, 03 e 04).
--
-- ---------------------------------------------------------

-- =====================================================================
-- QUESTAO 02
-- =====================================================================

-- 02: Consulta traduzida do M.A.L. fornecido: uniao de PRODUTO e DEPOSITO pela FK id_deposito, excluindo depositos 1, 3 e 5, ordenada por tipo_produto ASC.
SELECT
    p.id_produto,
    p.nome_produto,
    d.id_deposito,
    d.nome_deposito,
    p.tipo_produto
FROM produto p
INNER JOIN deposito d ON d.id_deposito = p.id_deposito
WHERE d.id_deposito NOT IN (1, 3, 5)
ORDER BY p.tipo_produto ASC;

-- 02: Nao ha necessidade de indice adicional: id_deposito e FK em PRODUTO e PK em DEPOSITO, ja indexadas automaticamente pelo InnoDB.

-- =====================================================================
-- QUESTAO 03
-- =====================================================================

-- 03: View estrategica reunindo PRODUTO, MARCA e VENDEDOR por meio de juncoes internas, expondo dados de produto, marca e preco de venda por vendedor.
CREATE VIEW T2_AEPF_ARTHUR AS
SELECT
    p.id_produto,
    p.nome_produto,
    m.id_marca,
    m.nome_marca,
    v.id_vendedor,
    v.preco_vendedor
FROM produto p
INNER JOIN marca m ON m.id_marca = p.id_marca
INNER JOIN vendedor v ON v.id_produto = p.id_produto;

-- 03: Consulta simples e eficiente que aciona a VIEW ja pronta, sem filtros ou juncoes adicionais, apenas exibindo todos os dados projetados por ela.
SELECT * FROM T2_AEPF_ARTHUR;

-- =====================================================================
-- QUESTAO 04
-- =====================================================================

-- 04: Funcao de janela que soma preco_vendedor por marca (PARTITION BY idMarca), ordenada crescente pelo preco, acumulando o total por marca.
SELECT
    id_marca AS idMarca,
    id_vendedor AS idVendedor,
    preco_vendedor AS precoVendedor,
    SUM(preco_vendedor) OVER (
        PARTITION BY id_marca
        ORDER BY preco_vendedor ASC
    ) AS AcumulaMarca
FROM T2_AEPF_ARTHUR
WHERE id_marca > 10
  AND preco_vendedor > 1200
  AND id_vendedor BETWEEN 3038669 AND 16932693;
