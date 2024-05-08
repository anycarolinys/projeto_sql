## **PROJETO SQL**
O objetivo deste projeto de SQL é normalizar e manipular os dados de um banco de dados relacionais para uma melhor análise e consulta, incluindo tratamento de valores nulos, criação de tabelas separadas para elenco, gêneros, datas de adição, duração e países, e realizar conversões de formatos. Isso permite responder a uma variedade de perguntas analíticas sobre o conteúdo do Netflix.

<img src="https://www.caviarcriativo.com/storage/2020/06/Significados-da-Marca-Netflix-1.gif" alt="Zalando's article" width="500"/>

Fonte: Caviar Criativo (2024)

Para realizar as consultas foi necessário preparar o ambiente com um banco de dados local para o MySQL 8.4.0.

**No arquivo *mysql_etl.ipynb*:**
- Importar a base de dados de filmes e séries da Netflix do Kaggle (https://www.kaggle.com/datasets/shivamb/netflix-shows)
- Exportar os dados para o banco de dados local utilizando Python  

**Nos arquivos *netflix.sql* ou *SQL_notebook.ipynb***
- Realizar normalização de tabelas no banco de dados com SQL
- Responder questões de negócio com SQL  
