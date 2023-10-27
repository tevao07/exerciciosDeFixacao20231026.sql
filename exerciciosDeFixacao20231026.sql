CREATE DATABASE exercicios_trigger;
USE exercicios_trigger;

-- Criação das tabelas
CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE Auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE Pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

CREATE TRIGGER cliente_insert_trigger AFTER INSERT ON
Clientes 
FOR EACH ROW
INSERT INTO Auditoria (mensagem, data_hora) VALUES
('Novo cliente inserido em', current_timestamp());

CREATE TRIGGER cliente_delete_trigger BEFORE DELETE ON
Clientes
FOR EACH ROW
INSERT INTO Auditoria (mensagem) VALUES
('Tentativa de exclusão de cliente em', current_timestamp());

CREATE TRIGGER cliente_update_trigger BEFORE UPDATE ON
Clientes 
FOR EACH ROW
	IF NEW.nome IS NULL OR NEW.nome = '' THEN
            INSERT INTO Auditoria (mensagem) VALUES
('Tentativa de atualização do nome vazio ou nulo.');
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não
é permitido atualizar o nome para vazio ou nulo.';
    ELSE
	INSERT INTO Auditoria (mensagem) VALUES
('Nome alterado de "', OLD.nome, '" para "', NEW.nome, '"');

CREATE TRIGGER pedido_insert_trigger AFTER INSERT ON
Pedidos
FOR EACH ROW
    DECLARE estoque_atual INT;
    SELECT estoque INTO estoque_atual FROM Produtos
WHERE id = NEW.produto_id;
    
    IF estoque_atual - NEW.quantidade < 5 THEN
        INSERT INTO Auditoria (mensagem) VALUES
('Estoque baixo (abaixo de 5 unidades) para o
produto', NEW.produto_id, ' em ', NOW());
    

    UPDATE Produto SET estoque = estoque_atual -
NEW.quantidade WHERE id = NEW.produto_id;
