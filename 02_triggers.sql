DELIMITER //

-- 1. Cálculo de Total e Histórico de Preço Unitário
DROP TRIGGER IF EXISTS trg_calculate_total //
CREATE TRIGGER trg_calculate_total
BEFORE INSERT ON tb_order_items
FOR EACH ROW
BEGIN
    DECLARE current_price DECIMAL(10,2);

    -- Busca o preço atual do produto
    SELECT price INTO current_price
    FROM tb_products
    WHERE product_id = NEW.product_id;

    -- Define o preço unitário da venda (congelando o valor histórico)
    SET NEW.unit_price = current_price;
    
    -- Calcula o total da linha
    SET NEW.total = current_price * NEW.quantity;
END //

-- 2. Auditoria de Pedidos (Insert)
DROP TRIGGER IF EXISTS trg_orders_insert //
CREATE TRIGGER trg_orders_insert
AFTER INSERT ON tb_orders
FOR EACH ROW
BEGIN
    INSERT INTO tb_audit_log (table_name, action_name, record_id, user_context)
    VALUES ('tb_orders', 'INSERT', NEW.order_id, 'system_integration');
END //

-- 3. Auditoria de Pedidos (Update)
DROP TRIGGER IF EXISTS trg_orders_update //
CREATE TRIGGER trg_orders_update
AFTER UPDATE ON tb_orders
FOR EACH ROW
BEGIN
    INSERT INTO tb_audit_log (table_name, action_name, record_id, user_context)
    VALUES ('tb_orders', 'UPDATE', NEW.order_id, 'system_integration');
END //

-- 4. Auditoria de Clientes (Update)
-- O campo updated_at é atualizado automaticamente pelo MySQL (ON UPDATE CURRENT_TIMESTAMP)
DROP TRIGGER IF EXISTS trg_customers_update //
CREATE TRIGGER trg_customers_update
AFTER UPDATE ON tb_customers
FOR EACH ROW
BEGIN
    INSERT INTO tb_audit_log (table_name, action_name, record_id, user_context)
    VALUES ('tb_customers', 'UPDATE', NEW.customer_id, 'system_integration');
END //

-- 5. Auditoria de Produtos (Update)
DROP TRIGGER IF EXISTS trg_products_update //
CREATE TRIGGER trg_products_update
AFTER UPDATE ON tb_products
FOR EACH ROW
BEGIN
    INSERT INTO tb_audit_log (table_name, action_name, record_id, user_context)
    VALUES ('tb_products', 'UPDATE', NEW.product_id, 'system_integration');
END //

-- 1. Auditoria de Clientes (Insert)
DROP TRIGGER IF EXISTS trg_customers_insert //
CREATE TRIGGER trg_customers_insert
AFTER INSERT ON tb_customers
FOR EACH ROW
BEGIN
    INSERT INTO tb_audit_log (table_name, action_name, record_id, user_context)
    VALUES ('tb_customers', 'INSERT', NEW.customer_id, 'system_integration');
END //

-- 2. Auditoria de Produtos (Insert)
DROP TRIGGER IF EXISTS trg_products_insert //
CREATE TRIGGER trg_products_insert
AFTER INSERT ON tb_products
FOR EACH ROW
BEGIN
    INSERT INTO tb_audit_log (table_name, action_name, record_id, user_context)
    VALUES ('tb_products', 'INSERT', NEW.product_id, 'system_integration');
END //

DELIMITER ;