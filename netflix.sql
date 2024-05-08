/* 1. A base possui diversos valores nulos. 
Preencha nas colunas onde os valores são nulls com 'NAN'. */

-- Obtendo uma lista com nomes das colunas
SELECT 
    column_name 
FROM 
    INFORMATION_SCHEMA.COLUMNS 
WHERE 
    table_name='netflix';

-- Substituindo NULL por 'NAN'
UPDATE netflix SET cast=COALESCE(cast, 'NAN');
UPDATE netflix SET country=COALESCE(country, 'NAN');
UPDATE netflix SET date_added=COALESCE(date_added, 'NAN');
UPDATE netflix SET director=COALESCE(director, 'NAN');
UPDATE netflix SET duration=COALESCE(duration, 'NAN');
UPDATE netflix SET listed_in=COALESCE(listed_in, 'NAN');
UPDATE netflix SET media_type=COALESCE(media_type, 'NAN');
UPDATE netflix SET rating=COALESCE(rating, 'NAN');
UPDATE netflix SET release_year=COALESCE(release_year, 'NAN');
UPDATE netflix SET show_id=COALESCE(show_id, 'NAN');
UPDATE netflix SET synopsis=COALESCE(synopsis, 'NAN');
UPDATE netflix SET title=COALESCE(title, 'NAN');

/* 2. Normalize a coluna CAST criando uma nova tabela 'cast_table' de modo que tenhamos separadamente, ou seja,
uma coluna com o nome do elenco de cada filme. Exemplo:

Linha: n1 joao, maria, roberto

coluna:

id CAST
n1 joao
n1 maria
n1 roberto */

-- Criando tabela cast_table para armazenar o elenco e o respectivo id
CREATE TABLE projeto.cast_table(
		show_id VARCHAR(20),
		cast VARCHAR(100)
);

-- Excluindo a procedure caso já exista alguma com mesmo nome
DROP PROCEDURE IF EXISTS dowhile;

-- Inicializando a procedure
DELIMITER //
CREATE PROCEDURE dowhile()
BEGIN
    /* Declarando uma variável chamada done do tipo inteiro (INT) e a inicializando como FALSE
    Essa variável é usada como uma flag para indicar se todas as linhas já foram processadas ou não */
    DECLARE done INT DEFAULT FALSE;
    DECLARE max_cast INT;
    -- Variável para percorrer o texto da coluna cast
    DECLARE i INT DEFAULT 1;
    -- Variável para armazenar o show_id do cursor
    DECLARE cur_id VARCHAR(20);
    -- Variável para armazenar o cast do cursor
    DECLARE cur_cast VARCHAR(1000);
    /* Declarando um cursor para percorrer as linhas de 'show_id'
    e 'cast' da tabela netflix */
    DECLARE cur1 CURSOR FOR SELECT show_id,cast FROM netflix;
    /* Declarando um manipulador de continuação para o caso de
    nenhuma linha ser encontrada enquanto se percorre o cursor 'cur1' */
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN cur1;
    
    -- Loop para percorrer todas as linhas do cursor
	read_loop: LOOP
        -- Recuperando os valores do cursor
		FETCH cur1 INTO cur_id, cur_cast;
        -- Verificando se o cursor chegou ao fim
		IF done THEN    
          -- Sair do loop se o cursor estiver vazio
		  LEAVE read_loop;
		END IF;
		
        -- Contar o número de elementos separados por vírgula na string
        SELECT LENGTH(cur_cast) - LENGTH(REPLACE(cur_cast, ',', '')) + 1 INTO max_cast;
        
        -- Exibir valores para depuração
        SELECT i, cur_id, max_cast;
        
        -- Iterar sobre cada elemento separado por vírgula
		WHILE i <= max_cast DO
            -- Inserir cada elemento na tabela de elenco
			INSERT INTO cast_table(show_id, cast)
			SELECT 
				cur_id,
				SUBSTRING_INDEX(SUBSTRING_INDEX(cur_cast, ',', i), ',', -1);
            -- Avançar para o próximo elemento
			SET i = i + 1;
		END WHILE;
        -- Reiniciar contador para próxima iteração
        SELECT 1 INTO i;
	END LOOP; -- Fim do loop
    CLOSE cur1; -- Fechar o cursor após o término
END;
//
DELIMITER ;

-- Chamar o procedimento armazenado
CALL dowhile();
-- Testando o resultado na produção de id 's2'
SELECT cast FROM netflix where show_id = 's2';
SELECT * FROM cast_table where show_id = 's2';


3. Normalize a coluna listed_in criando uma nova tabela 'genre_table' de modo que tenhamos separadamente os gêneros
de cada programação. Exemplo:

Linha: n1 Ação, Aventura, Comédia

coluna:

n1 Ação
n1 Comédia
n1 Aventura

CREATE TABLE projeto.genre_table(
		show_id VARCHAR(20),
		genre VARCHAR(100)
);

-- Excluindo a procedure caso já exista alguma com mesmo nome
DROP PROCEDURE IF EXISTS dowhile;

-- Inicializando a procedure
DELIMITER //
CREATE PROCEDURE dowhile()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE max_length INT;
    DECLARE i INT DEFAULT 1;
    DECLARE cur_id VARCHAR(20);
    DECLARE cur_item VARCHAR(1000);
    DECLARE cur1 CURSOR FOR SELECT show_id,listed_in FROM netflix;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN cur1;
    
	read_loop: LOOP
		FETCH cur1 INTO cur_id, cur_item;
		IF done THEN    
		  LEAVE read_loop;
		END IF;
		
        SELECT LENGTH(cur_item) - LENGTH(REPLACE(cur_item, ',', '')) + 1 INTO max_length;
        
        SELECT i, cur_id, max_length;
        
		WHILE i <= max_length DO
			INSERT INTO genre_table(show_id, genre)
			SELECT 
				cur_id,
				SUBSTRING_INDEX(SUBSTRING_INDEX(cur_item, ',', i), ',', -1);
			SET i = i + 1;
		END WHILE;
        SELECT 1 INTO i;
	END LOOP; -- Fim do loop
    CLOSE cur1; -- Fechar o cursor após o término
END;
//
DELIMITER ;

CALL dowhile();
SELECT genre FROM netflix where show_id = 's2';
SELECT * FROM genre_table where show_id = 's2';

4. Normalize a coluna date_added em uma nova base 'date_table' e 
construa as seguintes colunas:

-- coluna day: DD
ALTER TABLE netflix
ADD COLUMN day INT;

UPDATE netflix
SET day = (substring_index(
			substring_index(date_added,',', 1),
            ' ', -1))
                WHERE date_added != 'NAN';

-- coluna month: MM
ALTER TABLE netflix
ADD COLUMN month INT;

UPDATE netflix
SET month = MONTH(STR_TO_DATE(date_added, '%M %d, %Y'))
                WHERE date_added != 'NAN';

-- coluna year: YY
ALTER TABLE netflix
ADD COLUMN year INT;

UPDATE netflix
SET year = YEAR(STR_TO_DATE(date_added, '%M %d, %Y'))
                WHERE date_added != 'NAN';


-- coluna iso_date_1: YYYY-MM-DD
ALTER TABLE netflix
ADD COLUMN iso_date_1 DATE;

UPDATE netflix
SET iso_date_1 = date_format(STR_TO_DATE(date_added, '%M %d, %Y'), '%Y-%m-%d') 
                WHERE date_added != 'NAN';

-- coluna iso_date_2: YYYY/MM/DD
ALTER TABLE netflix
ADD COLUMN iso_date_2 VARCHAR(20);

UPDATE netflix
SET iso_date_2 = date_format(STR_TO_DATE(date_added, '%M %d, %Y'), "%Y/%m/%d") 
                WHERE date_added != 'NAN';

-- coluna iso_date_3: YYMMDD
ALTER TABLE netflix
ADD COLUMN iso_date_3 VARCHAR(20);

UPDATE netflix
SET iso_date_3 = date_format(STR_TO_DATE(date_added, '%M %d, %Y'), '%y%m%d') 
                WHERE date_added != 'NAN';


-- coluna iso_date_4: YYYYMMDD
ALTER TABLE netflix
ADD COLUMN iso_date_4 VARCHAR(20);

UPDATE netflix
SET iso_date_4 = date_format(STR_TO_DATE(date_added, '%M %d, %Y'), '%Y%m%d') 
                WHERE date_added != 'NAN';

/* 5. Normalize a coluna duration e construa uma nova base 'time_table' e faça as seguintes conversões. */

/* Converta a coluna duration para horas e crie a coluna hours hh. Obs. A média de cada
season TV SHOW é 10 horas, assim também converta para horas */

/* Converta todas as horas para minutos e armazena na coluna minutes mm */

CREATE TABLE projeto.time_table(
		show_id VARCHAR(20),
		hours FLOAT, 
        minutes INT
);

ALTER TABLE netflix
ADD COLUMN hours FLOAT;

UPDATE netflix
SET hours = 
    CASE
		WHEN LOWER(duration) REGEXP '.*season.*' THEN (SUBSTRING_INDEX(duration, ' ', 1) * 10)
        ELSE (SUBSTRING_INDEX(duration, ' ', 1) / 60)
    END
where duration != 'NAN';

ALTER TABLE netflix
ADD COLUMN minutes INT;

UPDATE netflix
SET minutes = hours * 60
WHERE hours IS NOT NULL;

INSERT INTO time_table(show_id, hours, minutes)
select show_id, hours, minutes from netflix;

ALTER TABLE netflix DROP COLUMN hours;
ALTER TABLE netflix DROP COLUMN minutes;

/* 6. Normalize a coluna country criando uma nova tabela 'country_table' de modo que tenhamos separadamente
uma coluna com o nome do país de cada filme. */

CREATE TABLE projeto.country_table(
		show_id VARCHAR(20),
		country VARCHAR(100)
);

-- Excluindo a procedure caso já exista alguma com mesmo nome
DROP PROCEDURE IF EXISTS dowhile;

-- Inicializando a procedure
DELIMITER //
CREATE PROCEDURE dowhile()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE max_length INT;
    DECLARE i INT DEFAULT 1;
    DECLARE cur_id VARCHAR(20);
    DECLARE cur_item VARCHAR(1000);
    DECLARE cur1 CURSOR FOR SELECT show_id,country FROM netflix;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN cur1;
    
	read_loop: LOOP
		FETCH cur1 INTO cur_id, cur_item;
		IF done THEN    
		  LEAVE read_loop;
		END IF;
		
        SELECT LENGTH(cur_item) - LENGTH(REPLACE(cur_item, ',', '')) + 1 INTO max_length;
        
        SELECT i, cur_id, max_length;
        
		WHILE i <= max_length DO
			INSERT INTO country_table(show_id, country)
			SELECT 
				cur_id,
				SUBSTRING_INDEX(SUBSTRING_INDEX(cur_item, ',', i), ',', -1);
			SET i = i + 1;
		END WHILE;
        SELECT 1 INTO i;
	END LOOP; -- Fim do loop
    CLOSE cur1; -- Fechar o cursor após o término
END;
//
DELIMITER ;

CALL dowhile();
SELECT country FROM netflix where show_id = 's2';
SELECT * FROM country_table where show_id = 's2';

------------------------------Questoes de negócio -----------------------------------------------------

/* 7. Qual o filme de duração máxima em minutos? */

-- Obtendo somente o primeiro filme da lista de valor maximo
SELECT netflix.title, netflix.show_id, time_table.minutes
FROM  time_table
LEFT JOIN netflix 
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Movie'
ORDER BY time_table.minutes DESC
LIMIT 1;

-- Obtendo todos os filmes com duracao maxima
SELECT netflix.show_id, netflix.title, time_table.minutes
FROM time_table
LEFT JOIN netflix 
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Movie' and time_table.minutes=(SELECT max(minutes)
FROM time_table
LEFT JOIN netflix
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Movie');


/* 8. Qual o filme de duração mínima em minutos? */

SELECT netflix.show_id, netflix.title, time_table.minutes
FROM time_table
LEFT JOIN netflix 
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Movie' and time_table.minutes IS NOT NULL
ORDER BY time_table.minutes
LIMIT 1;

SELECT netflix.show_id, netflix.title, time_table.minutes
FROM time_table
LEFT JOIN netflix 
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Movie' and time_table.minutes=(SELECT min(minutes)
FROM time_table
LEFT JOIN netflix
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Movie');


/* 9. Qual a série de duração máxima em minutos? */

SELECT netflix.title, netflix.show_id, time_table.minutes
FROM  time_table
LEFT JOIN netflix 
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'TV Show'
ORDER BY time_table.minutes DESC
LIMIT 1;

SELECT netflix.show_id, netflix.title, time_table.minutes
FROM time_table
LEFT JOIN netflix 
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'TV Show' and time_table.minutes=(SELECT max(minutes)
FROM time_table
LEFT JOIN netflix
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'TV Show');

/* 10. Qual a série de duração mínima em minutos? */

SELECT netflix.show_id, netflix.title, time_table.minutes
FROM time_table
LEFT JOIN netflix 
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'TV Show' and time_table.minutes IS NOT NULL
ORDER BY time_table.minutes
LIMIT 1;

SELECT netflix.show_id, netflix.title, time_table.minutes
FROM time_table
LEFT JOIN netflix 
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'TV Show' and time_table.minutes=(SELECT min(minutes)
FROM time_table
LEFT JOIN netflix
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'TV Show');

/* 11. Qual a média de tempo de duração dos filmes? */

-- Em minutos
SELECT avg(minutes)
FROM time_table
LEFT JOIN netflix
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Movie';

-- Em horas
SELECT avg(hours)
FROM time_table
LEFT JOIN netflix
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Movie';

/* 12. Qual a média de tempo de duração das séries? */

-- Em minutos
SELECT avg(minutes)
FROM time_table
LEFT JOIN netflix
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Tv Show';

-- Em horas
SELECT avg(hours)
FROM time_table
LEFT JOIN netflix
ON time_table.show_id = netflix.show_id
WHERE netflix.media_type = 'Tv Show';

/* 13. Qual a lista de filmes o ator Leonardo DiCaprio participa? */

select title
from netflix
where cast LIKE '%Leonardo DiCaprio%'AND media_type='Movie';

/* 14. Quantas vezes o ator Tom Hanks apareceu nas telas do netflix, ou seja, tanto série quanto filmes? */

select count(*)
from netflix
where cast LIKE '%Tom Hanks%';

/* 15. Quantas produções séries e filmes brasileiras já foram ao ar no netflix? */

-- Contabilizando produções unicamente brasileiras 
select count(*)
from netflix
where country='Brazil';

-- Contabilizando produções que também envolvem outros países além do Brasil
select count(*)
from netflix
where country LIKE '%Brazil%';

/* 16. Quantos filmes americanos já foram para o ar no netflix? */
select count(*)
from netflix
where country='United States';

select count(*)
from netflix
where country LIKE '%United States%';

/* 17. Crie uma nova coluna com o nome last_name_director com uma nova formatação para o nome dos diretores, por exemplo. João Roberto para Roberto, João. */

ALTER TABLE netflix
ADD COLUMN last_director_name VARCHAR(255);

-- Excluindo a procedure caso já exista alguma com mesmo nome
DROP PROCEDURE IF EXISTS dowhile;

-- Inicializando a procedure
DELIMITER //
CREATE PROCEDURE dowhile()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE max_length INT;
    DECLARE i INT DEFAULT 1;
    DECLARE cur_id VARCHAR(20);
    DECLARE cur_item VARCHAR(1000);
    DECLARE director_name VARCHAR(100);
    DECLARE cur1 CURSOR FOR SELECT show_id, director FROM netflix where director != 'NAN';
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN cur1;
    
	read_loop: LOOP
		FETCH cur1 INTO cur_id, cur_item;
		IF done THEN    
		  LEAVE read_loop;
		END IF;
		
        SELECT LENGTH(cur_item) - LENGTH(REPLACE(cur_item, ',', '')) + 1 INTO max_length;
        
        SELECT i, cur_id, max_length;
        
		WHILE i <= max_length DO
			SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(cur_item, ',', i), ',', -1) INTO director_name;
            
			INSERT INTO netflix(show_id, last_director_name)
			SELECT 
				cur_id,
				CONCAT(SUBSTRING_INDEX(director_name , ' ', -1), ', ', SUBSTRING_INDEX(director_name , ' ', 1));
			SET i = i + 1;
		END WHILE;
        SELECT 1 INTO i;
	END LOOP; -- Fim do loop
    CLOSE cur1; -- Fechar o cursor após o término
END;
//
DELIMITER ;

CALL dowhile();
SELECT director FROM netflix where show_id = 's31';
SELECT last_director_name from netflix where show_id = 's31';

/* 18. Procure a lista de conteúdos que tenha como temática a segunda guerra mundial (WWII)? */
select title from netflix where synopsis LIKE '%WWII%';

/* 19. Conte o número de produções dos países que apresentaram conteúdos no netflix? */
select country, count(country) as numero_producoes from 
netflix group by country order by country;