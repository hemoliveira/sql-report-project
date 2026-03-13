-- Slow query without indexes
SELECT *
FROM tb_order_items oi, tb_orders o, tb_customers c
WHERE oi.order_id = o.order_id
AND o.customer_id = c.customer_id;

-- Otimização máxima para relatórios pesados
SELECT
    c.name,
    SUM(oi.total) AS total_gasto
FROM tb_customers c
INNER JOIN tb_orders o ON o.customer_id = c.customer_id
INNER JOIN tb_order_items oi ON oi.order_id = o.order_id
WHERE o.deleted_at IS NULL -- Sempre aplique o filtro de Soft Delete antes do Group By
GROUP BY c.customer_id; -- Agrupar pelo ID é mais rápido que pelo Nome (VARCHAR)

-- Explain the optimized query
EXPLAIN
SELECT
    c.name,
    SUM(oi.total) AS total_gasto
FROM tb_customers c
INNER JOIN tb_orders o ON o.customer_id = c.customer_id
INNER JOIN tb_order_items oi ON oi.order_id = o.order_id
WHERE o.deleted_at IS NULL -- Sempre aplique o filtro de Soft Delete antes do Group By
GROUP BY c.customer_id; -- Agrupar pelo ID é mais rápido que pelo Nome (VARCHAR)
