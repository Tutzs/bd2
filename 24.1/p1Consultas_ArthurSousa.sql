-- ===========================================================
-- AA) Consulta que recupera isbn, titulo e media de avaliacao
--     dos livros com nota media entre 8 e 9, conforme M.A.L.
-- ===========================================================
select b.isbn, b.bookTitle, AVG(r.bookRating) as Media
from books b
inner join ratings r on b.isbn = r.isbn
group by b.isbn, b.bookTitle
having Media < 9 AND Media > 8
order by Media desc;

-- a consulta não precisa de índice adicional, porque o JOIN já está coberto 
-- e o filtro/ordenação restantes (HAVING/ORDER BY) atuam sobre uma coluna 
-- calculada (Media) que nenhum índice pode acelerar.

-- BB

create view P1A as 
select u.userId as IdAvaliador, u.age as Idade, r.isbn, b.bookTitle as Titulo, r.bookRating as Nota
from users u
join ratings r on r.userid = u.userid
join books b on r.isbn = b.isbn
order by isbn asc;

select * from P1A;

-- CC

select *
from P1A
where Idade is NOT NULL and Nota >= 10 and isbn in ('0451524934', '0006751504', '0007106130');
-- principal chave de procura é o isbn pois ele usa somente essa chave para fazer a busca

-- não precisa de índice pois o select na view já faz usando o usersID_FK e o isbn_FK também