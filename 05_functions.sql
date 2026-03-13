DELIMITER //

-- Função para formatar moeda com proteção contra NULL
DROP FUNCTION IF EXISTS fn_format_currency //
CREATE FUNCTION fn_format_currency(amount DECIMAL(15,2)) -- Aumentado para suportar valores maiores
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    -- Se o valor for NULL, retorna '$ 0.00' em vez de NULL
    RETURN CONCAT('$ ', FORMAT(COALESCE(amount, 0), 2));
END //

-- Função para formatar data com proteção contra NULL
DROP FUNCTION IF EXISTS fn_format_date //
CREATE FUNCTION fn_format_date(d DATE) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF d IS NULL THEN
        RETURN 'N/A';
    END IF;
    RETURN DATE_FORMAT(d, '%b %d, %Y');
END //

DELIMITER ;