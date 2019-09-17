#DATASPOT-TERADATA

CREATE TABLE test_db_1.example_table_a
AS (
  SELECT *
  FROM test_db_1.example_table_b
  JOIN test_db_2.example_table_a
  ON 1=1
  JOIN test_db_3.example_table_b
  ON 1=1
) WITH DATA AND STATS;

INSERT INTO test_db_1.example_table_b
SELECT *
FROM test_db_2.example_table_b
JOIN test_db_2.example_table_c
ON 1=1;