CREATE SCHEMA IF NOT EXISTS pggraph;

CREATE OR REPLACE FUNCTION pggraph.f_make_set(
  i_id BIGINT
)
RETURNS void AS $$
BEGIN
  INSERT INTO disjoint_set_forest (id, parent_id) VALUES (i_id, i_id);
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pggraph, pg_temp;

CREATE OR REPLACE FUNCTION pggraph.f_find(
  i_id BIGINT
)
RETURNS bigint AS $$
DECLARE
  i_parent_id BIGINT;
BEGIN
  SELECT parent_id INTO i_parent_id FROM disjoint_set_forest WHERE id = i_id;
  IF i_parent_id = i_id THEN
    RETURN i_id;
  ELSE
    RETURN f_find(i_parent_id);
  END IF;
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pggraph, pg_temp;

CREATE OR REPLACE FUNCTION pggraph.f_union(
  i_id1 BIGINT
, i_id2 BIGINT
)
RETURNS void AS $$
DECLARE
  i_root1 BIGINT;
  i_root2 BIGINT;
BEGIN
  i_root1 := f_find(i_id1);
  i_root2 := f_find(i_id2);
  UPDATE disjoint_set_forest SET parent_id = i_root2 WHERE id = i_root1;
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pggraph, pg_temp;

CREATE OR REPLACE FUNCTION pggraph.kruskal (
  v_graph_sql TEXT
)
RETURNS TABLE (
  id BIGINT
, source BIGINT
, target BIGINT
, cost DOUBLE PRECISION
) AS $$
DECLARE
  r_edge RECORD;
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS disjoint_set_forest (
    id BIGINT
  , parent_id BIGINT
  ) ON COMMIT DROP;

  CREATE TEMP TABLE IF NOT EXISTS kruskal_graph (
    id BIGINT
  , source BIGINT
  , target BIGINT
  , cost DOUBLE PRECISION
  ) ON COMMIT DROP;

  CREATE TEMP TABLE IF NOT EXISTS mst (
    id BIGINT
  , source BIGINT
  , target BIGINT
  , cost DOUBLE PRECISION
  ) ON COMMIT DROP;

  DELETE FROM disjoint_set_forest;
  DELETE FROM kruskal_graph;
  DELETE FROM mst;

  EXECUTE 'INSERT INTO kruskal_graph (id, source, target, cost) ' || v_graph_sql;

  PERFORM f_make_set(vertex.id) FROM (
    SELECT DISTINCT g.source AS id FROM kruskal_graph g
    UNION 
    SELECT DISTINCT g.target AS id FROM kruskal_graph g
  ) vertex;

  FOR r_edge IN (SELECT g.id, g.source, g.target, g.cost FROM kruskal_graph g ORDER BY g.cost ASC)
  LOOP
    IF (f_find(r_edge.source) <> f_find(r_edge.target)) THEN
      INSERT INTO mst (id, source, target, cost)
      VALUES (r_edge.id, r_edge.source, r_edge.target, r_edge.cost);
      PERFORM f_union(r_edge.source, r_edge.target);
    END IF;
  END LOOP;

  RETURN QUERY SELECT mst.id, mst.source, mst.target, mst.cost FROM mst;
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = pggraph, pg_temp;