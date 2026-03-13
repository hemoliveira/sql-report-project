-- Chaves Estrangeiras e Joins
-- Removido idx_orders_customer pois o idx_orders_customer_date já cobre o customer_id
CREATE INDEX idx_order_items_order ON tb_order_items(order_id);
CREATE INDEX idx_order_items_product ON tb_order_items(product_id);

-- Soft Delete (Crucial para as Views)
CREATE INDEX idx_customers_active ON tb_customers(deleted_at);
CREATE INDEX idx_products_active ON tb_products(deleted_at);
CREATE INDEX idx_orders_active ON tb_orders(deleted_at);

-- Performance de Relatórios (Composto)
-- Este índice cobre buscas por: (customer_id + order_date) E buscas por: (customer_id)
CREATE INDEX idx_orders_customer_date ON tb_orders(customer_id, order_date);

-- Busca por Data (Para relatórios gerais sem filtro de cliente)
CREATE INDEX idx_orders_date ON tb_orders(order_date);