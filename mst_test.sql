CREATE SCHEMA IF NOT EXISTS pggraph_mst_test;

CREATE TABLE IF NOT EXISTS pggraph_mst_test.graph (
  id BIGINT
, source BIGINT
, target BIGINT
, cost DOUBLE PRECISION
);

INSERT INTO pggraph_mst_test.graph (id, source, target, cost) VALUES
(1, 1, 5, 1),
(2, 1, 2, 3),
(3, 2, 5, 4),
(4, 2, 3, 5),
(5, 3, 5, 6),
(6, 3, 4, 2),
(7, 4, 5, 7);

SELECT pggraph.kruskal('SELECT id, source, target, cost FROM pggraph_mst_test.graph');