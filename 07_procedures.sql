DELIMITER //

-- 1. Total por Cliente (Reutilizando a View que já criamos)
CREATE OR REPLACE PROCEDURE prc_get_total_by_customer()
BEGIN
    SELECT * FROM vw_total_by_customer 
    ORDER BY total_value_raw DESC;
END //

-- 2. Busca de Pedidos por Nome (Com busca parcial e View)
CREATE OR REPLACE PROCEDURE prc_get_orders_by_customer(IN customerName VARCHAR(100))
BEGIN
    SELECT 
        order_id,
        formatted_date,
        customer,
        product,
        quantity,
        total_price_formatted
    FROM vw_sales_report
    WHERE customer LIKE CONCAT('%', customerName, '%');
END //

-- 3. Dashboard Mensal (Consolidado e formatado)
CREATE OR REPLACE PROCEDURE prc_monthly_dashboard()
BEGIN
    -- KPI 1: Faturamento e Volume Mensal
    SELECT 
        fn_format_currency(SUM(total_price_raw)) AS monthly_revenue,
        COUNT(DISTINCT order_id) AS total_orders
    FROM vw_sales_report
    WHERE MONTH(STR_TO_DATE(formatted_date, '%b %d, %Y')) = MONTH(CURRENT_DATE)
      AND YEAR(STR_TO_DATE(formatted_date, '%b %d, %Y')) = YEAR(CURRENT_DATE);

    -- KPI 2: Vendas por Categoria (Com filtro de ativos via View)
    SELECT 
        p.category, 
        fn_format_currency(SUM(oi.total)) AS revenue
    FROM tb_order_items oi
    JOIN tb_products p ON oi.product_id = p.product_id
    JOIN tb_orders o ON oi.order_id = o.order_id
    WHERE o.deleted_at IS NULL AND p.deleted_at IS NULL
    GROUP BY p.category
    ORDER BY SUM(oi.total) DESC;

    -- KPI 3: O "Cliente do Mês"
    SELECT 
        customer, 
        fn_format_currency(SUM(total_price_raw)) AS total_spent
    FROM vw_sales_report
    WHERE MONTH(STR_TO_DATE(formatted_date, '%b %d, %Y')) = MONTH(CURRENT_DATE)
    GROUP BY customer
    ORDER BY SUM(total_price_raw) DESC
    LIMIT 1;
END //

DELIMITER ;