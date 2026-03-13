-- 1. Sales Report View (Estilizada para Relatórios)
CREATE OR REPLACE VIEW vw_sales_report AS
SELECT
    o.order_id,
    fn_format_date(o.order_date) AS formatted_date,
    c.name AS customer,
    p.name AS product,
    oi.quantity,
    oi.unit_price, -- Adicionado para transparência
    fn_format_currency(oi.total) AS total_price_formatted,
    oi.total AS total_price_raw -- Útil para o Python processar somas
FROM tb_order_items oi
JOIN tb_orders o ON o.order_id = oi.order_id
JOIN tb_customers c ON c.customer_id = o.customer_id
JOIN tb_products p ON p.product_id = oi.product_id
WHERE o.deleted_at IS NULL 
  AND oi.deleted_at IS NULL; -- Garante que itens removidos não apareçam

-- 2. Total by Customer View (Financeira)
CREATE OR REPLACE VIEW vw_total_by_customer AS
SELECT
    c.name AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders, -- Adicionado: métrica extra
    SUM(oi.total) AS total_value_raw,
    fn_format_currency(SUM(oi.total)) AS total_value_formatted
FROM tb_customers c
JOIN tb_orders o ON o.customer_id = c.customer_id
JOIN tb_order_items oi ON oi.order_id = o.order_id
WHERE o.deleted_at IS NULL 
  AND c.deleted_at IS NULL -- Filtra apenas clientes ativos
GROUP BY c.customer_id, c.name; -- Agrupar por ID é mais seguro para nomes duplicados

-- 3. Never Sold Products View (Análise de Estoque)
CREATE OR REPLACE VIEW vw_never_sold_products AS
SELECT 
    p.product_id,
    p.name AS product_name,
    p.category,
    fn_format_currency(p.price) AS price
FROM tb_products p
LEFT JOIN tb_order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL 
  AND p.deleted_at IS NULL;

-- 4. Low Performance Products View (Análise de Desempenho)
CREATE OR REPLACE VIEW vw_low_performance_products AS
SELECT 
    p.name AS product,
    p.category,
    SUM(COALESCE(oi.quantity, 0)) AS total_units_sold,
    fn_format_currency(SUM(COALESCE(oi.total, 0))) AS total_revenue
FROM tb_products p
JOIN tb_order_items oi ON p.product_id = oi.product_id
WHERE p.deleted_at IS NULL
GROUP BY p.product_id, p.name, p.category
HAVING total_units_sold < 5
ORDER BY total_units_sold ASC;

-- 5. Audit Report View (Auditoria)
CREATE OR REPLACE VIEW vw_audit_report AS
SELECT 
    a.id AS log_id,
    a.table_name,
    a.action_name,
    a.record_id,
    a.user_context,
    fn_format_date(a.created_at) AS action_date,
    DATE_FORMAT(a.created_at, '%H:%i:%s') AS action_time
FROM tb_audit_log a
ORDER BY a.created_at DESC;
