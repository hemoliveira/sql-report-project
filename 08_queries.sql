-- 1. Total gasto por cada cliente (Apenas clientes e pedidos ativos)
SELECT 
    customer_name, 
    total_value_formatted AS total 
FROM vw_total_by_customer
ORDER BY total_value_raw DESC;

-- 2. Quantidade total vendida de cada produto
SELECT 
    p.name, 
    SUM(oi.quantity) AS total_qty
FROM tb_order_items oi
JOIN tb_products p ON p.product_id = oi.product_id
JOIN tb_orders o ON o.order_id = oi.order_id
WHERE o.deleted_at IS NULL AND p.deleted_at IS NULL
GROUP BY p.name
ORDER BY total_qty DESC;

-- 3. Vendas totais por mês (Numérico, para gráficos)
SELECT 
    MONTH(o.order_date) AS mes_num, 
    SUM(oi.total) AS total_bruto
FROM tb_orders o
JOIN tb_order_items oi ON oi.order_id = o.order_id
WHERE o.deleted_at IS NULL
GROUP BY MONTH(o.order_date)
ORDER BY mes_num;

-- 4. Vendas totais por mês (Formatado para relatórios)
SELECT
    DATE_FORMAT(o.order_date, '%M %Y') AS mes_extenso,
    fn_format_currency(SUM(oi.total)) AS total_formatado
FROM tb_orders o
JOIN tb_order_items oi ON oi.order_id = o.order_id
WHERE o.deleted_at IS NULL
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), mes_extenso
ORDER BY DATE_FORMAT(o.order_date, '%Y-%m');

-- 5. Total de vendas por categoria de produto
SELECT 
    p.category, 
    fn_format_currency(SUM(oi.total)) AS total_categoria
FROM tb_products p
JOIN tb_order_items oi ON p.product_id = oi.product_id
JOIN tb_orders o ON o.order_id = oi.order_id
WHERE o.deleted_at IS NULL AND p.deleted_at IS NULL
GROUP BY p.category
ORDER BY SUM(oi.total) DESC;

-- 6. Log de auditoria detalhado (Usando a View de Auditoria)
SELECT * FROM vw_audit_report;