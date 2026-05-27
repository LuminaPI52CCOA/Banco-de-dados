CREATE DATABASE IF NOT EXISTS Lumina;

USE Lumina;

CREATE TABLE estado_civil (
    id_estado_civil INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE convenio (
    id_convenio INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE perfil (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    fk_perfil INT NOT NULL,
    cro VARCHAR(15),
    ativo TINYINT(1) DEFAULT 1,
CONSTRAINT fkUsuarioPerfil
    FOREIGN KEY (fk_perfil)
    REFERENCES perfil(id_perfil)
);

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(15) UNIQUE,
    rg VARCHAR(15),
    data_nascimento DATE NOT NULL,
    numero_celular VARCHAR(15) NOT NULL,
    email VARCHAR(255),
    sexo CHAR(1),
    naturalidade VARCHAR(100),
    nacionalidade VARCHAR(100),
    fk_estado_civil INT,
    endereco_residencial VARCHAR(100),
    cep VARCHAR(8),
    fk_cliente_indicacao INT,
    fk_responsavel INT,
    grau_parentesco_responsavel VARCHAR(30),
    ativo TINYINT(1),
CONSTRAINT fkClienteEstadoCivil
    FOREIGN KEY (fk_estado_civil)
    REFERENCES estado_civil(id_estado_civil),
CONSTRAINT fkClienteClienteIndicacao
    FOREIGN KEY (fk_cliente_indicacao) 
    REFERENCES cliente(id_cliente),
CONSTRAINT fkClienteResponsavel
    FOREIGN KEY (fk_responsavel)
    REFERENCES cliente(id_cliente)
);

CREATE TABLE cliente_convenio (
    id_cliente_convenio INT AUTO_INCREMENT PRIMARY KEY,
    fk_cliente INT NOT NULL,
    fk_convenio INT NOT NULL,
    numero_inscricao VARCHAR(45),
CONSTRAINT fkClienteConvenio_Cliente
    FOREIGN KEY (fk_cliente)
    REFERENCES cliente(id_cliente),
CONSTRAINT fkClienteConvenio_Convenio
    FOREIGN KEY (fk_convenio)
    REFERENCES convenio(id_convenio)
);

CREATE TABLE anamnese (
    id_anamnese INT AUTO_INCREMENT PRIMARY KEY,
    fk_cliente INT NOT NULL,
    data_anamnese DATE NOT NULL,
    fazendo_tratamento TINYINT(1),
    descricao_tratamento VARCHAR(100),
    dores_cabeca_face_atm TINYINT(1),
    alergia_medicamentosa TINYINT(1),
    descricao_alergia_medicamentosa VARCHAR(100),
    reacao_anestesia_local TINYINT(1),
    sensibilidade_dentaria TINYINT(1),
    bruxismo_apertamento TINYINT(1),
    sangramento_gengival TINYINT(1),
    possui_habito TINYINT(1),
    descricao_habito VARCHAR(100),
    historico_diabetes TINYINT(1),
    sangramento_excessivo TINYINT(1),
    problema_cardiaco TINYINT(1),
    descricao_problema_cardiaco VARCHAR(100),
    pressao_arterial_normal TINYINT(1),
    descricao_pressao_arterial VARCHAR(100),
    historico_desmaio_convulsao TINYINT(1),
    gestante TINYINT(1),
CONSTRAINT fkAnamneseCliente
    FOREIGN KEY (fk_cliente)
    REFERENCES cliente(id_cliente)
);

CREATE TABLE consulta (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    fk_cliente INT NOT NULL,
    fk_usuario INT NOT NULL,
    data DATE NOT NULL,
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    status VARCHAR(20),
CONSTRAINT fkConsultaCliente
    FOREIGN KEY (fk_cliente)
    REFERENCES cliente(id_cliente),
CONSTRAINT fkConsultaUsuario
    FOREIGN KEY (fk_usuario)
    REFERENCES usuario(id_usuario)
);

CREATE TABLE especialidade (
    id_especialidade INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(45) NOT NULL
);

CREATE TABLE procedimento (
    id_procedimento INT AUTO_INCREMENT PRIMARY KEY,
    fk_especialidade INT NOT NULL,
    nome_procedimento VARCHAR(45) NOT NULL,
    exige_dente TINYINT(1),
    preco_base DECIMAL(10,2),
CONSTRAINT fkProcedimentoEspecialidade
    FOREIGN KEY (fk_especialidade)
    REFERENCES especialidade(id_especialidade)
);

CREATE TABLE consulta_procedimento (
    id_consulta_procedimento INT AUTO_INCREMENT PRIMARY KEY,
    fk_consulta INT NOT NULL,
    fk_procedimento INT NOT NULL,
    numero_dente INT,
    observacao VARCHAR(45),
    status VARCHAR(20),
    valor_aplicado DECIMAL(10,2),
CONSTRAINT fkConsultaProcedimento_Consulta
    FOREIGN KEY (fk_consulta)
    REFERENCES consulta(id_consulta),
CONSTRAINT fkConsultaProcedimento_Procedimento
    FOREIGN KEY (fk_procedimento)
    REFERENCES procedimento(id_procedimento)
);

INSERT INTO perfil (nome)
VALUES ('caio');

INSERT INTO usuario (nome, email, senha, fk_perfil, cpf)
VALUES ('John Doe', 'john@doe.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 1, '123456');

SELECT * FROM perfil;
SELECT * FROM cliente;

INSERT INTO estado_civil (descricao)
VALUES ('solteiro');