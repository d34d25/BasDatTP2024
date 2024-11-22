CREATE DATABASE tp4;
USE tp4;
DELIMITER $$

CREATE TABLE Pedidos (
    PedidoId INT PRIMARY KEY AUTO_INCREMENT,
    ClienteId INT NOT NULL,
    FechaPedido DATE NOT NULL,
    TotalPedido DECIMAL(10 , 2 ) NOT NULL,
    Facturado BIT DEFAULT 0
);

CREATE TABLE Facturas (
    FacturaId INT PRIMARY KEY AUTO_INCREMENT,
    PedidoId INT NOT NULL,
    FechaFactura DATE NOT NULL,
    MontoFacturado DECIMAL(10 , 2 ) NOT NULL,
    CONSTRAINT PedidoId FOREIGN KEY (PedidoId) REFERENCES Pedidos (PedidoId)
);

-- Insertando datos de ejemplo en la tabla Pedidos
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (101, '2024-01-10', 150.00, 1);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (102, '2024-01-11', 200.00, 0);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (103, '2024-01-12', 300.00, 1);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (104, '2024-01-13', 450.00, 1);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (105, '2024-01-14', 120.00, 0);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (106, '2024-01-15', 250.00, 1);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (107, '2024-01-16', 180.00, 1);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (108, '2024-01-17', 220.00, 0);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (109, '2024-01-18', 500.00, 1);
INSERT INTO Pedidos (ClienteId, FechaPedido, TotalPedido, Facturado) VALUES (110, '2024-01-19', 350.00, 0);

-- Insertando datos de ejemplo en la tabla Facturas
-- Solo para los pedidos que han sido marcados como facturados (Facturado = 1)
INSERT INTO Facturas (PedidoId, FechaFactura, MontoFacturado) VALUES (1, '2024-01-20', 150.00);
INSERT INTO Facturas (PedidoId, FechaFactura, MontoFacturado) VALUES (3, '2024-01-21', 300.00);
INSERT INTO Facturas (PedidoId, FechaFactura, MontoFacturado) VALUES (4, '2024-01-22', 450.00);
INSERT INTO Facturas (PedidoId, FechaFactura, MontoFacturado) VALUES (6, '2024-01-23', 250.00);
INSERT INTO Facturas (PedidoId, FechaFactura, MontoFacturado) VALUES (7, '2024-01-24', 180.00);
INSERT INTO Facturas (PedidoId, FechaFactura, MontoFacturado) VALUES (9, '2024-01-25', 500.00);

DELIMITER $$
CREATE PROCEDURE GenerarFacturas()
BEGIN
    DECLARE PedidoIdV INT;
    DECLARE ClienteIdV INT;
    DECLARE TotalPedidoV DECIMAL(10,2);
    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_pedidos CURSOR FOR
        SELECT PedidoId, ClienteId, TotalPedido FROM Pedidos WHERE Facturado = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;

    OPEN cursor_pedidos;

    FETCH cursor_pedidos INTO PedidoIdV, ClienteIdV, TotalPedidoV;

    WHILE NOT done DO
        BEGIN
            INSERT INTO Facturas (PedidoId, FechaFactura, MontoFacturado)
            VALUES (PedidoIdV, CURDATE(), TotalPedidoV);
            
            UPDATE Pedidos 
            SET Facturado = 1
            WHERE PedidoId = PedidoIdV;

            FETCH cursor_pedidos INTO PedidoIdV, ClienteIdV, TotalPedidoV;
        END;
    END WHILE;

    CLOSE cursor_pedidos;
    
    COMMIT;
END$$
DELIMITER ;