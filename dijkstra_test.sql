CREATE SCHEMA IF NOT EXISTS pggraph_dijkstra_test;

CREATE TABLE IF NOT EXISTS pggraph_dijkstra_test.graph (
  id BIGINT
, source BIGINT
, target BIGINT
, cost DOUBLE PRECISION
);

INSERT INTO pggraph_dijkstra_test.graph (id, source, target, cost) VALUES
(1, 1, 2, 4),
(2, 1, 3, 2),
(3, 2, 3, 5),
(4, 2, 4, 10),
(5, 3, 5, 3),
(6, 5, 4, 4),
(7, 4, 6, 11);

SELECT * FROM pggraph.dijkstra('SELECT id, source, target, cost FROM pggraph_dijkstra_test.graph', 1, NULL);

SELECT * FROM pggraph.dijkstra('SELECT id, source, target, cost FROM pggraph_dijkstra_test.graph', 1, 6);