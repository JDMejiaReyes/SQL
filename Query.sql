--====================================================================================================
--                            Probando funciones Práctica 10
--====================================================================================================
-- i. Probando función que reciba el identificador del cliente y nos regrese la edad de los mismos.
SELECT calcular_edad_cliente(1);

-- Verificar todos los clientes
SELECT 
    IdCliente,
    FechaNacimiento,
    calcular_edad_cliente(IdCliente) AS Edad
FROM Cliente;


