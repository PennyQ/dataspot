#DATASPOT-TERADATA

CREATE TABLE test_db_2.example_table_a
AS (
  SELECT *
  FROM test_db_3.example_table_a
  JOIN (SELECT *
        FROM test_db_3.example_table_b
        JOIN test_db_3.example_table_C
          ON 1=1)
  ON 1=1
) WITH DATA AND STATS;

INSERT INTO test_db_2.example_table_b
SELECT *
FROM (SELECT *
      FROM test_db_4.example_table_a)
JOIN golden_source.example_table_a
ON 1=1;

