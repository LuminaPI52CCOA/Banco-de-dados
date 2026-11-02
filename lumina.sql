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

CREATE TABLE especialidade (
    id_especialidade INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(45) NOT NULL
);

CREATE TABLE consulta (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    fk_cliente INT NOT NULL,
    fk_usuario INT NOT NULL,
    fk_especialidade INT NULL,
    data DATE NOT NULL,
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'AGENDADA',
    observacoes VARCHAR(500) NULL,
    tipo_dente VARCHAR(45) NULL,
    pular_odontograma TINYINT(1) NOT NULL DEFAULT 0,
    lembrete_enviado TINYINT(1) DEFAULT 0,
    alexa_reminder_id VARCHAR(255),
CONSTRAINT fkConsultaCliente
    FOREIGN KEY (fk_cliente)
    REFERENCES cliente(id_cliente),
CONSTRAINT fkConsultaUsuario
    FOREIGN KEY (fk_usuario)
    REFERENCES usuario(id_usuario),
CONSTRAINT fkConsultaEspecialidade
    FOREIGN KEY (fk_especialidade)
    REFERENCES especialidade(id_especialidade)
);

CREATE INDEX idx_consulta_dentista_data ON consulta (fk_usuario, data, horario_inicio);

CREATE TABLE usuario_alexa (
    id_usuario_alexa INT AUTO_INCREMENT PRIMARY KEY,
    fk_usuario INT NOT NULL,
    alexa_user_id VARCHAR(255) NOT NULL UNIQUE,
    api_endpoint VARCHAR(100) DEFAULT 'https://api.amazonalexa.com',
    codigo_pareamento VARCHAR(6) NULL,
    codigo_expiracao DATETIME NULL,
    ativo TINYINT(1) DEFAULT 1,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
CONSTRAINT fkUsuarioAlexa_Usuario
    FOREIGN KEY (fk_usuario)
    REFERENCES usuario(id_usuario)
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

CREATE TABLE dente (
    numero_dente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    arcada VARCHAR(15) NOT NULL,
    quadrante TINYINT NOT NULL
);

CREATE TABLE consulta_procedimento (
    id_consulta_procedimento INT AUTO_INCREMENT PRIMARY KEY,
    fk_consulta INT NOT NULL,
    fk_procedimento INT NOT NULL,
    fk_dente INT NULL,
    observacao VARCHAR(45),
    status VARCHAR(20),
    valor_aplicado DECIMAL(10,2),
CONSTRAINT fkConsultaProcedimento_Consulta
    FOREIGN KEY (fk_consulta)
    REFERENCES consulta(id_consulta),
CONSTRAINT fkConsultaProcedimento_Procedimento
    FOREIGN KEY (fk_procedimento)
    REFERENCES procedimento(id_procedimento),
CONSTRAINT fkConsultaProcedimento_Dente
    FOREIGN KEY (fk_dente)
    REFERENCES dente(numero_dente)
);

CREATE TABLE consulta_dente (
    fk_consulta INT NOT NULL,
    fk_dente INT NOT NULL,
CONSTRAINT pkConsultaDente
    PRIMARY KEY (fk_consulta, fk_dente),
CONSTRAINT fkConsultaDente_Consulta
    FOREIGN KEY (fk_consulta)
    REFERENCES consulta(id_consulta),
CONSTRAINT fkConsultaDente_Dente
    FOREIGN KEY (fk_dente)
    REFERENCES dente(numero_dente)
);

CREATE TABLE IF NOT EXISTS notificacao_whatsapp (
    id_notificacao BIGINT AUTO_INCREMENT PRIMARY KEY,
    fk_consulta INT NOT NULL,
    fk_cliente INT NOT NULL,
    fk_destinatario INT NOT NULL,
    nome_destinatario VARCHAR(100) NOT NULL,
    grau_parentesco VARCHAR(30) NULL,
    numero_telefone_higienizado VARCHAR(20) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDENTE',
    motivo_falha VARCHAR(255) NULL,
    data_consulta DATE NOT NULL,
    horario_consulta TIME NOT NULL,
    token_confirmacao VARCHAR(64) NOT NULL,
    limite_confirmacao_em DATETIME NOT NULL,
    confirmado_em DATETIME NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    disparado_em DATETIME NULL,
    fk_usuario_disparo INT NULL,
    CONSTRAINT uk_notificacao_consulta UNIQUE (fk_consulta),
    CONSTRAINT uk_notificacao_token UNIQUE (token_confirmacao),
    CONSTRAINT fkNotificacao_Consulta FOREIGN KEY (fk_consulta) REFERENCES consulta(id_consulta),
    CONSTRAINT fkNotificacao_Cliente FOREIGN KEY (fk_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fkNotificacao_Destinatario FOREIGN KEY (fk_destinatario) REFERENCES cliente(id_cliente),
    CONSTRAINT fkNotificacao_UsuarioDisparo FOREIGN KEY (fk_usuario_disparo) REFERENCES usuario(id_usuario)
);

CREATE INDEX idx_notificacao_data_status ON notificacao_whatsapp (data_consulta, status);
CREATE INDEX idx_notificacao_token ON notificacao_whatsapp (token_confirmacao);

CREATE TABLE IF NOT EXISTS tipo_midia (
    id_tipo_midia INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NULL,
    fk_usuario INT NULL, 
    ativo TINYINT(1) DEFAULT 1,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fkTipoMidia_Usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE IF NOT EXISTS cliente_midia (
    id_cliente_midia INT AUTO_INCREMENT PRIMARY KEY,
    fk_cliente INT NOT NULL,
    fk_usuario INT NOT NULL, 
    fk_tipo_midia INT NOT NULL,
    fk_consulta INT NULL, 
    chave_s3 VARCHAR(500) NOT NULL UNIQUE,
    nome_original VARCHAR(255) NOT NULL,
    extensao VARCHAR(20) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    tamanho_bytes BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    legenda VARCHAR(500) NULL,
    ativo TINYINT(1) DEFAULT 1, 
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    data_exclusao DATETIME NULL,
    fk_usuario_exclusao INT NULL,
    CONSTRAINT fkClienteMidia_Cliente FOREIGN KEY (fk_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fkClienteMidia_Usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fkClienteMidia_TipoMidia FOREIGN KEY (fk_tipo_midia) REFERENCES tipo_midia(id_tipo_midia),
    CONSTRAINT fkClienteMidia_Consulta FOREIGN KEY (fk_consulta) REFERENCES consulta(id_consulta),
    CONSTRAINT fkClienteMidia_UsuarioExclusao FOREIGN KEY (fk_usuario_exclusao) REFERENCES usuario(id_usuario)
);

CREATE INDEX idx_cliente_midia_busca ON cliente_midia (fk_cliente, ativo, fk_tipo_midia, criado_em);
CREATE INDEX idx_tipo_midia_usuario ON tipo_midia (fk_usuario, ativo);

-- =============================================================================
-- MASSA DE DADOS DE TESTE (SEED DATA)
-- =============================================================================

-- 1. Perfis de Acesso
INSERT INTO perfil (id_perfil, nome) VALUES 
(1, 'Admin'),
(2, 'Dentista'),
(3, 'Recepcionista');

-- 2. Usuários (Senha padrão para todos: '123456' em BCrypt)
INSERT INTO usuario (id_usuario, nome, email, senha, fk_perfil, cpf, cro, ativo) VALUES 
(1, 'John Doe', 'john@doe.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '12345678901', 'SP-123456', 1),
(2, 'Dra. Ana Maria Souza', 'ana.souza@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '98765432100', 'SP-654321', 1),
(3, 'Administrador Lumina', 'admin@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 1, '11122233344', NULL, 1),
(4, 'Recepção Lumina', 'recepcao@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 3, '22233344455', NULL, 1),
(5, 'Dr. Roberto Almeida', 'roberto.almeida@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '33344455566', 'SP-112233', 1),
(6, 'Dra. Beatriz Ferreira', 'beatriz.ferreira@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '44455566677', 'SP-223344', 1),
(7, 'Dr. Fernando Henrique Costa', 'fernando.costa@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '55566677788', 'SP-334455', 1),
(8, 'Dra. Camila Rodrigues', 'camila.rodrigues@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '66677788899', 'SP-445566', 1),
(9, 'Dr. Marcelo Ribeiro', 'marcelo.ribeiro@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '77788899900', 'SP-556677', 1),
(10, 'Dra. Patrícia Mendes', 'patricia.mendes@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '88899900011', 'SP-667788', 1),
(11, 'Dr. Gustavo Nascimento', 'gustavo.nascimento@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '99900011122', 'SP-778899', 1),
(12, 'Dra. Helena Carvalho', 'helena.carvalho@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 2, '10120230344', 'SP-889900', 0);

-- 3. Estado Civil
INSERT INTO estado_civil (id_estado_civil, descricao) VALUES 
(1, 'Solteiro(a)'),
(2, 'Casado(a)'),
(3, 'Divorciado(a)'),
(4, 'Viúvo(a)');

-- 4. Convênios
INSERT INTO convenio (id_convenio, nome) VALUES 
(1, 'Particular'),
(2, 'Amil Dental'),
(3, 'Bradesco Dental'),
(4, 'SulAmérica Odonto');

-- 5. Clientes / Pacientes
INSERT INTO cliente (id_cliente, nome, cpf, rg, data_nascimento, numero_celular, email, sexo, naturalidade, nacionalidade, fk_estado_civil, endereco_residencial, cep, fk_cliente_indicacao, fk_responsavel, grau_parentesco_responsavel, ativo) VALUES 
(1, 'Carlos Silva', '12312312345', '123456789', '1990-05-15', '11954684815', 'carlos.silva@email.com', 'M', 'São Paulo', 'Brasileira', 1, 'Rua das Flores, 120', '01001000', NULL, NULL, NULL, 1),
(2, 'Maria Oliveira', '23423423456', '234567890', '1985-08-20', '11954684815', 'maria.oliveira@email.com', 'F', 'Campinas', 'Brasileira', 2, 'Av. Paulista, 1500', '01310100', NULL, NULL, NULL, 1),
(3, 'Lucas Santos', '34534534567', '345678901', '2000-11-10', '11954684815', 'lucas.santos@email.com', 'M', 'Santos', 'Brasileira', 1, 'Rua Augusta, 450', '01305000', NULL, NULL, NULL, 1),
(4, 'Juliana Costa', '45645645678', '456789012', '1995-03-25', '11954684815', 'juliana.costa@email.com', 'F', 'São Paulo', 'Brasileira', 1, 'Alameda Santos, 800', '01419001', NULL, NULL, NULL, 1),
-- Paciente 5: Menor de idade com responsável legal (Mãe = Maria Oliveira) para teste de disparo via responsável no RabbitMQ
(5, 'Enzo Oliveira', '56756756789', '567890123', '2016-04-10', '11954684815', 'maria.oliveira@email.com', 'M', 'Campinas', 'Brasileira', 1, 'Av. Paulista, 1500', '01310100', NULL, 2, 'Mãe', 1),
-- Paciente 6: Paciente com telefone fixo / sem 9º dígito para teste de falha de validação (FALHA_CONTATO_INVALIDO)
(6, 'Roberto Ferreira', '67867867890', '678901234', '1978-11-03', '1133445566', 'roberto.ferreira@email.com', 'M', 'São Paulo', 'Brasileira', 2, 'Rua da Consolação, 900', '01301000', NULL, NULL, NULL, 1);

INSERT INTO cliente (id_cliente, nome, cpf, rg, data_nascimento, numero_celular, email, sexo, naturalidade, nacionalidade, fk_estado_civil, endereco_residencial, cep, ativo) VALUES
(7, 'Adriana Pereira', '50150150101', '501234561', '1988-02-14', '11981112201', 'adriana.pereira@email.com', 'F', 'São Paulo', 'Brasileira', 2, 'Rua Oscar Freire, 210', '01426000', 1),
(8, 'Bruno Gonçalves', '50250250202', '501234562', '1992-07-09', '11981112202', 'bruno.goncalves@email.com', 'M', 'Guarulhos', 'Brasileira', 1, 'Rua Voluntários da Pátria, 900', '02010000', 1),
(9, 'Carolina Nogueira', '50350350303', '501234563', '2001-01-30', '11981112203', 'carolina.nogueira@email.com', 'F', 'São Paulo', 'Brasileira', 1, 'Rua Vergueiro, 2100', '04101000', 1),
(10, 'Daniel Martins', '50450450404', '501234564', '1975-11-22', '11981112204', 'daniel.martins@email.com', 'M', 'Sorocaba', 'Brasileira', 2, 'Av. Ibirapuera, 1800', '04028001', 1),
(11, 'Eduarda Barbosa', '50550550505', '501234565', '2016-04-18', '11981112205', 'eduarda.barbosa@email.com', 'F', 'São Paulo', 'Brasileira', 1, 'Rua Domingos de Morais, 320', '04010000', 1),
(12, 'Felipe Azevedo', '50650650606', '501234566', '1982-09-05', '11981112206', 'felipe.azevedo@email.com', 'M', 'Santo André', 'Brasileira', 3, 'Rua Bela Cintra, 740', '01415000', 1),
(13, 'Gabriela Rocha', '50750750707', '501234567', '1997-12-12', '11981112207', 'gabriela.rocha@email.com', 'F', 'São Bernardo', 'Brasileira', 1, 'Rua Haddock Lobo, 510', '01414001', 1),
(14, 'Henrique Dias', '50850850808', '501234568', '1960-06-28', '11981112208', 'henrique.dias@email.com', 'M', 'São Paulo', 'Brasileira', 2, 'Av. Brigadeiro Luís Antônio, 1200', '01318001', 1),
(15, 'Isabela Cardoso', '50950950909', '501234569', '2018-08-03', '11981112209', 'isabela.cardoso@email.com', 'F', 'Campinas', 'Brasileira', 1, 'Rua da Consolação, 1100', '01302000', 1),
(16, 'João Pedro Teixeira', '51051051010', '501234570', '1994-03-17', '11981112210', 'joao.teixeira@email.com', 'M', 'São Paulo', 'Brasileira', 1, 'Rua Harmonia, 77', '05435000', 1),
(17, 'Larissa Monteiro', '51151151111', '501234571', '1989-10-25', '11981112211', 'larissa.monteiro@email.com', 'F', 'Jundiaí', 'Brasileira', 2, 'Rua Teodoro Sampaio, 1400', '05406100', 1),
(18, 'Matheus Moreira', '51251251212', '501234572', '1999-01-08', '11981112212', 'matheus.moreira@email.com', 'M', 'São Paulo', 'Brasileira', 1, 'Rua Cardeal Arcoverde, 600', '05408000', 1),
(19, 'Natália Freitas', '51351351313', '501234573', '1963-05-19', '11981112213', 'natalia.freitas@email.com', 'F', 'Santos', 'Brasileira', 4, 'Av. Rebouças, 2300', '05402300', 1),
(20, 'Otávio Vieira', '51451451414', '501234574', '1980-12-01', '11981112214', 'otavio.vieira@email.com', 'M', 'São Paulo', 'Brasileira', 2, 'Rua Estados Unidos, 430', '01427000', 1),
(21, 'Priscila Barros', '51551551515', '501234575', '1993-07-14', '11981112215', 'priscila.barros@email.com', 'F', 'Osasco', 'Brasileira', 1, 'Rua Pamplona, 890', '01405001', 1),
(22, 'Rafael Cavalcanti', '51651651616', '501234576', '1978-04-02', '11981112216', 'rafael.cavalcanti@email.com', 'M', 'Recife', 'Brasileira', 2, 'Alameda Jaú, 350', '01420000', 1),
(23, 'Sabrina Campos', '51751751717', '501234577', '2003-09-21', '11981112217', 'sabrina.campos@email.com', 'F', 'São Paulo', 'Brasileira', 1, 'Rua Tutóia, 620', '04007003', 1),
(24, 'Thiago Correia', '51851851818', '501234578', '1991-02-27', '11981112218', 'thiago.correia@email.com', 'M', 'São Paulo', 'Brasileira', 2, 'Rua Joaquim Floriano, 500', '04534002', 1),
(25, 'Vanessa Araújo', '51951951919', '501234579', '1958-11-11', '11981112219', 'vanessa.araujo@email.com', 'F', 'Ribeirão Preto', 'Brasileira', 4, 'Av. Faria Lima, 3100', '01452000', 1),
(26, 'William Pinto', '52052052020', '501234580', '1986-06-06', '11981112220', 'william.pinto@email.com', 'M', 'São Paulo', 'Brasileira', 3, 'Rua Clélia, 1050', '05042000', 1),
(27, 'Arthur Almeida Gomes', '60010370739', '600010191', '1969-02-02', '11970011023', 'arthur.gomes.1@email.com', 'M', 'Campinas', 'Brasileira', 2, 'Av. Brasil, 107', '01430000', 1),
(28, 'Bernardo Barbosa Lima', '60020741468', '600020382', '1970-03-03', '11970021046', 'bernardo.lima.2@email.com', 'M', 'Santos', 'Brasileira', 3, 'Rua Augusta, 114', '01305000', 1),
(29, 'Davi Cardoso Ribeiro', '60031112197', '600030573', '1971-04-04', '11970031069', 'davi.ribeiro.3@email.com', 'M', 'Guarulhos', 'Brasileira', 1, 'Alameda Santos, 121', '01419001', 1),
(30, 'Gabriel Castro Rocha', '60041482826', '600040764', '1972-05-05', '11970041092', 'gabriel.rocha.4@email.com', 'M', 'São Paulo', 'Brasileira', 4, 'Rua Oscar Freire, 128', '01426000', 1),
(31, 'Heitor Cunha Santos', '60051853555', '600050955', '1973-06-06', '11970051115', 'heitor.santos.5@email.com', 'M', 'Santo André', 'Brasileira', 2, 'Rua Haddock Lobo, 135', '01414001', 1),
(32, 'Lorenzo Dias Silva', '60062224284', '600061146', '1974-07-07', '11970061138', 'lorenzo.silva.6@email.com', 'M', 'São Bernardo do Campo', 'Brasileira', 1, 'Rua Bela Cintra, 142', '01415000', 1),
(33, 'Pedro Ferreira Sousa', '60072595113', '600071337', '1975-08-08', '11970071161', 'pedro.monteiro.7@email.com', 'M', 'Osasco', 'Brasileira', 2, 'Rua Maranhão, 149', '01240000', 1),
(34, 'Gabriel Cruz Pereira', '60082965842', '600081528', '1976-09-09', '11970081184', 'gabriel.pereira.8@email.com', 'M', 'Ribeirão Preto', 'Brasileira', 3, 'Rua Sergipe, 156', '01243001', 1),
(35, 'Enzo Ferreira Sampaio', '60093336571', '600091719', '1955-10-10', '11970091207', 'enzo.sampaio.9@email.com', 'M', 'São José dos Campos', 'Brasileira', 4, 'Av. Higienópolis, 163', '01238001', 1),
(36, 'Matheus Araújo Vieira', '60103707300', '600101900', '2016-11-11', '11970101230', 'matheus.vieira.10@email.com', 'M', 'Jundiaí', 'Brasileira', 1, 'Rua Cardoso de Almeida, 170', '05013001', 1),
(37, 'Lucas Campos Martins', '60114078039', '600112091', '1979-12-12', '11970111253', 'lucas.martins.11@email.com', 'M', 'Piracicaba', 'Brasileira', 3, 'Rua Homem de Melo, 177', '05007001', 1),
(38, 'Benjamin Costa Nogueira', '60124448768', '600122282', '1980-01-13', '11970121276', 'benjamin.nogueira.12@email.com', 'M', 'Bauru', 'Brasileira', 1, 'Rua Apinajés, 184', '05017000', 1),
(39, 'Nicolas Farias Reis', '60134819497', '600132473', '1981-02-14', '11970131299', 'nicolas.reis.13@email.com', 'M', 'Mogi das Cruzes', 'Brasileira', 2, 'Av. Sumaré, 191', '05016090', 1),
(40, 'Guilherme Alves Souza', '60145180226', '600142664', '1960-03-15', '11970141322', 'guilherme.souza.14@email.com', 'M', 'Barueri', 'Brasileira', 2, 'Rua Cayowaá, 198', '05018000', 1),
(41, 'Rafael Borges Leite', '60155550955', '600152855', '2021-04-16', '11970151345', 'rafael.leite.15@email.com', 'M', 'São Paulo', 'Brasileira', 1, 'Rua Fradique Coutinho, 205', '05416010', 1),
(42, 'Joaquim Coelho Monteiro', '60165921684', '600163046', '1984-05-17', '11970161368', 'joaquim.monteiro.16@email.com', 'M', 'Campinas', 'Brasileira', 2, 'Rua dos Pinheiros, 212', '05422001', 1),
(43, 'Samuel Dias Pereira', '60176292413', '600173237', '1985-06-18', '11970171391', 'samuel.pereira.17@email.com', 'M', 'Santos', 'Brasileira', 3, 'Rua Girassol, 219', '05433001', 1),
(44, 'Enzo Gabriel Freitas Sampaio', '60186663142', '600183428', '1986-07-19', '11970181414', 'enzo.gabriel.sampaio.18@email.com', 'M', 'Guarulhos', 'Brasileira', 1, 'Rua Aspicuelta, 226', '05433010', 1),
(45, 'João Miguel Barros Vieira', '60197033871', '600193619', '1946-08-20', '11970191437', 'joao.miguel.vieira.19@email.com', 'M', 'Sorocaba', 'Brasileira', 4, 'Av. Pedroso de Morais, 233', '05419000', 1),
(46, 'Henrique Castro Marques', '60207404600', '600203800', '2017-09-21', '11970201460', 'henrique.marques.20@email.com', 'M', 'Santo André', 'Brasileira', 1, 'Rua Joaquim Antunes, 240', '05415010', 1),
(47, 'Gustavo Cunha Nogueira', '60217775339', '600213991', '1989-10-22', '11970211483', 'gustavo.nogueira.21@email.com', 'M', 'São Bernardo do Campo', 'Brasileira', 1, 'Rua Mateus Grou, 247', '05415000', 1),
(48, 'Murilo Figueiredo Reis', '60228146068', '600224182', '1990-11-23', '11970221506', 'murilo.reis.22@email.com', 'M', 'Osasco', 'Brasileira', 2, 'Rua Afonso Braz, 254', '04511011', 1),
(49, 'Pedro Henrique Azevedo Souza', '60238516797', '600234373', '1991-12-24', '11970231529', 'pedro.henrique.souza.23@email.com', 'M', 'Ribeirão Preto', 'Brasileira', 3, 'Rua Diogo Jácome, 261', '04512001', 1),
(50, 'Pietro Cardoso Leite', '60248887526', '600244564', '1951-01-25', '11970241552', 'pietro.leite.24@email.com', 'M', 'São José dos Campos', 'Brasileira', 2, 'Av. Santo Amaro, 268', '04506000', 1);

-- 6. Convênios dos Clientes
INSERT INTO cliente_convenio (id_cliente_convenio, fk_cliente, fk_convenio, numero_inscricao) VALUES 
(1, 1, 1, 'PART-001'),
(2, 2, 2, 'AMIL-987654321'),
(3, 3, 3, 'BRAD-456789123'),
(4, 4, 1, 'PART-004'),
(5, 5, 2, 'AMIL-112233445'),
(6, 6, 1, 'PART-006'),
(7, 7, 2, 'INSC-501501'),
(8, 8, 1, 'INSC-502502'),
(9, 9, 4, 'INSC-503503'),
(10, 10, 3, 'INSC-504504'),
(11, 11, 2, 'INSC-505505'),
(12, 12, 1, 'INSC-506506'),
(13, 13, 4, 'INSC-507507'),
(14, 14, 3, 'INSC-508508'),
(15, 15, 2, 'INSC-509509'),
(16, 16, 1, 'INSC-510510'),
(17, 17, 3, 'INSC-511511'),
(18, 18, 1, 'INSC-512512'),
(19, 19, 4, 'INSC-513513'),
(20, 20, 2, 'INSC-514514'),
(21, 21, 1, 'INSC-515515'),
(22, 22, 3, 'INSC-516516'),
(23, 23, 1, 'INSC-517517'),
(24, 24, 2, 'INSC-518518'),
(25, 25, 4, 'INSC-519519'),
(26, 26, 1, 'INSC-520520'),
(27, 27, 2, 'INSC-600103'),
(28, 28, 3, 'INSC-600207'),
(29, 29, 4, 'INSC-600311'),
(30, 30, 1, 'INSC-600414'),
(31, 31, 2, 'INSC-600518'),
(32, 32, 3, 'INSC-600622'),
(33, 33, 4, 'INSC-600725'),
(34, 34, 1, 'INSC-600829'),
(35, 35, 2, 'INSC-600933'),
(36, 36, 3, 'INSC-601037'),
(37, 37, 4, 'INSC-601140'),
(38, 38, 1, 'INSC-601244'),
(39, 39, 2, 'INSC-601348'),
(40, 40, 3, 'INSC-601451'),
(41, 41, 4, 'INSC-601555'),
(42, 42, 1, 'INSC-601659'),
(43, 43, 2, 'INSC-601762'),
(44, 44, 3, 'INSC-601866'),
(45, 45, 4, 'INSC-601970'),
(46, 46, 1, 'INSC-602074'),
(47, 47, 2, 'INSC-602177'),
(48, 48, 3, 'INSC-602281'),
(49, 49, 4, 'INSC-602385'),
(50, 50, 1, 'INSC-602488');

-- 7. Fichas de Anamnese
-- Carlos Silva (Paciente com Alergia a Penicilina, Hipertensão e Histórico Cardíaco para teste de voz na Alexa)
INSERT INTO anamnese (id_anamnese, fk_cliente, data_anamnese, fazendo_tratamento, descricao_tratamento, dores_cabeca_face_atm, alergia_medicamentosa, descricao_alergia_medicamentosa, reacao_anestesia_local, sensibilidade_dentaria, bruxismo_apertamento, sangramento_gengival, possui_habito, descricao_habito, historico_diabetes, sangramento_excessivo, problema_cardiaco, descricao_problema_cardiaco, pressao_arterial_normal, descricao_pressao_arterial, historico_desmaio_convulsao, gestante) VALUES 
(1, 1, CURRENT_DATE, 1, 'Controle de pressão', 0, 1, 'Penicilina e Dipirona', 0, 1, 0, 1, 0, NULL, 0, 0, 1, 'Histórico de arritmia cardíaca', 0, 'Hipertensão arterial controlada', 0, 0),
-- Maria Oliveira (Gestante com sensibilidade dentária)
(2, 2, CURRENT_DATE, 0, NULL, 0, 0, NULL, 0, 1, 0, 0, 0, NULL, 0, 0, 0, NULL, 1, 'Normal', 0, 1),
-- Lucas Santos (Sem alergias ou restrições graves)
(3, 3, CURRENT_DATE, 0, NULL, 1, 0, NULL, 0, 0, 1, 0, 0, NULL, 0, 0, 0, NULL, 1, 'Normal', 0, 0);

-- 8. Especialidades e Procedimentos
INSERT INTO especialidade (id_especialidade, nome) VALUES 
(1, 'Clínica Geral'),
(2, 'Ortodontia'),
(3, 'Endodontia'),
(4, 'Periodontia');

INSERT INTO procedimento (id_procedimento, fk_especialidade, nome_procedimento, exige_dente, preco_base) VALUES 
(1, 1, 'Limpeza e Profilaxia', 0, 150.00),
(2, 1, 'Restauração em Resina', 1, 220.00),
(3, 3, 'Tratamento de Canal', 1, 850.00),
(4, 1, 'Clareamento Dental', 0, 600.00);

-- 9. Consultas (40 consultas: 20 na semana vigente e 20 na semana passada, 5 por dia)
INSERT INTO consulta (id_consulta, fk_cliente, fk_usuario, fk_especialidade, data, horario_inicio, horario_fim, status, lembrete_enviado, alexa_reminder_id) VALUES 
-- =========================================================================
-- SEMANA VIGENTE (20 consultas - 5 por dia em 4 dias)
-- =========================================================================

-- Ontem: 5 consultas realizadas
(1, 7, 5, 1, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), '08:30:00', '09:15:00', 'CONCLUIDA', 1, NULL),
(2, 8, 5, 2, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), '10:00:00', '10:45:00', 'CONCLUIDA', 1, NULL),
(3, 9, 6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), '11:30:00', '12:15:00', 'CONCLUIDA', 1, NULL),
(4, 10, 6, 3, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), '14:00:00', '14:45:00', 'CONCLUIDA', 1, NULL),
(5, 11, 1, 1, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), '16:00:00', '16:45:00', 'CONCLUIDA', 1, NULL),

-- Hoje: 5 consultas (Atendimentos do dia para recepção, dentista e Alexa)
(6, 2, 1, 1, CURRENT_DATE, '09:00:00', '09:45:00', 'CONCLUIDA', 1, 'reminder-concluido-01'),
(7, 3, 2, 1, CURRENT_DATE, '11:00:00', '11:45:00', 'AGENDADA', 0, NULL),
(8, 1, 1, 1, CURRENT_DATE, '14:30:00', '15:15:00', 'AGENDADA', 0, NULL),
(9, 4, 1, 3, CURRENT_DATE, '16:00:00', '16:45:00', 'AGENDADA', 0, NULL),
(10, 5, 1, 1, CURRENT_DATE, '17:30:00', '18:15:00', 'AGENDADA', 0, NULL),

-- Amanhã (D-1): 5 consultas (Elegíveis para teste do RabbitMQ / Lembretes)
(11, 1, 1, 1, DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '10:00:00', '10:45:00', 'AGENDADA', 0, NULL),
(12, 5, 1, 1, DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '11:00:00', '11:45:00', 'AGENDADA', 0, NULL),
(13, 6, 2, 2, DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '14:00:00', '14:45:00', 'AGENDADA', 0, NULL),
(14, 4, 1, 1, DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '15:30:00', '16:15:00', 'AGENDADA', 0, NULL),
(15, 3, 2, 3, DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '16:30:00', '17:15:00', 'CONFIRMADA', 0, NULL),

-- Daqui a 2 dias: 5 consultas agendadas
(16, 12, 5, 1, DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY), '09:00:00', '09:45:00', 'CONFIRMADA', 0, NULL),
(17, 13, 6, 2, DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY), '10:30:00', '11:15:00', 'AGENDADA', 0, NULL),
(18, 14, 7, 3, DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY), '14:00:00', '14:45:00', 'CONFIRMADA', 0, NULL),
(19, 15, 8, 4, DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY), '15:30:00', '16:15:00', 'AGENDADA', 0, NULL),
(20, 16, 1, 1, DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY), '17:00:00', '17:45:00', 'AGENDADA', 0, NULL),

-- =========================================================================
-- SEMANA PASSADA (20 consultas - 5 por dia em 4 dias)
-- =========================================================================

-- 10 dias atrás (5 consultas)
(21, 17, 1, 1, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), '08:30:00', '09:15:00', 'CONCLUIDA', 1, NULL),
(22, 18, 2, 2, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), '10:00:00', '10:45:00', 'CONCLUIDA', 1, NULL),
(23, 19, 5, 3, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), '11:30:00', '12:15:00', 'CANCELADA', 0, NULL),
(24, 20, 6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), '14:00:00', '14:45:00', 'CONCLUIDA', 1, NULL),
(25, 21, 7, 4, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), '16:00:00', '16:45:00', 'CONCLUIDA', 1, NULL),

-- 9 dias atrás (5 consultas)
(26, 22, 1, 1, DATE_SUB(CURRENT_DATE, INTERVAL 9 DAY), '09:00:00', '09:45:00', 'CONCLUIDA', 1, NULL),
(27, 23, 2, 2, DATE_SUB(CURRENT_DATE, INTERVAL 9 DAY), '10:30:00', '11:15:00', 'CONCLUIDA', 1, NULL),
(28, 24, 5, 3, DATE_SUB(CURRENT_DATE, INTERVAL 9 DAY), '14:00:00', '14:45:00', 'CONCLUIDA', 1, NULL),
(29, 25, 6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 9 DAY), '15:30:00', '16:15:00', 'CONCLUIDA', 1, NULL),
(30, 26, 1, 4, DATE_SUB(CURRENT_DATE, INTERVAL 9 DAY), '17:00:00', '17:45:00', 'CANCELADA', 0, NULL),

-- 8 dias atrás (5 consultas)
(31, 27, 1, 1, DATE_SUB(CURRENT_DATE, INTERVAL 8 DAY), '09:00:00', '09:45:00', 'CONCLUIDA', 1, NULL),
(32, 28, 2, 2, DATE_SUB(CURRENT_DATE, INTERVAL 8 DAY), '10:30:00', '11:15:00', 'CONCLUIDA', 1, NULL),
(33, 29, 5, 1, DATE_SUB(CURRENT_DATE, INTERVAL 8 DAY), '14:00:00', '14:45:00', 'CONCLUIDA', 1, NULL),
(34, 30, 6, 3, DATE_SUB(CURRENT_DATE, INTERVAL 8 DAY), '15:30:00', '16:15:00', 'CONCLUIDA', 1, NULL),
(35, 31, 7, 1, DATE_SUB(CURRENT_DATE, INTERVAL 8 DAY), '17:00:00', '17:45:00', 'CONCLUIDA', 1, NULL),

-- 7 dias atrás (5 consultas)
(36, 32, 1, 1, DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY), '09:00:00', '09:45:00', 'CONCLUIDA', 1, NULL),
(37, 33, 2, 2, DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY), '10:30:00', '11:15:00', 'CONCLUIDA', 1, NULL),
(38, 34, 5, 3, DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY), '14:00:00', '14:45:00', 'CONCLUIDA', 1, NULL),
(39, 35, 6, 1, DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY), '15:30:00', '16:15:00', 'CONCLUIDA', 1, NULL),
(40, 36, 1, 4, DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY), '17:00:00', '17:45:00', 'CONCLUIDA', 1, NULL);

-- 10. Catálogo de Dentes (Padrão FDI - 32 Dentes Permanentes)
INSERT INTO dente (numero_dente, nome, arcada, quadrante) VALUES
-- Quadrante 1: Superior Direito
(11, 'Incisivo Central Superior Direito', 'SUPERIOR', 1),
(12, 'Incisivo Lateral Superior Direito', 'SUPERIOR', 1),
(13, 'Canino Superior Direito', 'SUPERIOR', 1),
(14, '1º Pré-Molar Superior Direito', 'SUPERIOR', 1),
(15, '2º Pré-Molar Superior Direito', 'SUPERIOR', 1),
(16, '1º Molar Superior Direito', 'SUPERIOR', 1),
(17, '2º Molar Superior Direito', 'SUPERIOR', 1),
(18, '3º Molar Superior Direito (Siso)', 'SUPERIOR', 1),
-- Quadrante 2: Superior Esquerdo
(21, 'Incisivo Central Superior Esquerdo', 'SUPERIOR', 2),
(22, 'Incisivo Lateral Superior Esquerdo', 'SUPERIOR', 2),
(23, 'Canino Superior Esquerdo', 'SUPERIOR', 2),
(24, '1º Pré-Molar Superior Esquerdo', 'SUPERIOR', 2),
(25, '2º Pré-Molar Superior Esquerdo', 'SUPERIOR', 2),
(26, '1º Molar Superior Esquerdo', 'SUPERIOR', 2),
(27, '2º Molar Superior Esquerdo', 'SUPERIOR', 2),
(28, '3º Molar Superior Esquerdo (Siso)', 'SUPERIOR', 2),
-- Quadrante 3: Inferior Esquerdo
(31, 'Incisivo Central Inferior Esquerdo', 'INFERIOR', 3),
(32, 'Incisivo Lateral Inferior Esquerdo', 'INFERIOR', 3),
(33, 'Canino Inferior Esquerdo', 'INFERIOR', 3),
(34, '1º Pré-Molar Inferior Esquerdo', 'INFERIOR', 3),
(35, '2º Pré-Molar Inferior Esquerdo', 'INFERIOR', 3),
(36, '1º Molar Inferior Esquerdo', 'INFERIOR', 3),
(37, '2º Molar Inferior Esquerdo', 'INFERIOR', 3),
(38, '3º Molar Inferior Esquerdo (Siso)', 'INFERIOR', 3),
-- Quadrante 4: Inferior Direito
(41, 'Incisivo Central Inferior Direito', 'INFERIOR', 4),
(42, 'Incisivo Lateral Inferior Direito', 'INFERIOR', 4),
(43, 'Canino Inferior Direito', 'INFERIOR', 4),
(44, '1º Pré-Molar Inferior Direito', 'INFERIOR', 4),
(45, '2º Pré-Molar Inferior Direito', 'INFERIOR', 4),
(46, '1º Molar Inferior Direito', 'INFERIOR', 4),
(47, '2º Molar Inferior Direito', 'INFERIOR', 4),
(48, '3º Molar Inferior Direito (Siso)', 'INFERIOR', 4);

-- 11. Procedimentos das Consultas
INSERT INTO consulta_procedimento (id_consulta_procedimento, fk_consulta, fk_procedimento, fk_dente, observacao, status, valor_aplicado) VALUES 
(1, 1, 1, NULL, 'Profilaxia periódica', 'CONCLUIDA', 150.00),
(2, 2, 2, 16, 'Restauração dente molar superior', 'AGENDADA', 220.00),
(3, 3, 4, NULL, 'Clareamento caseiro supervisionado', 'AGENDADA', 600.00);

-- 12. Dentes do Odontograma Vinculados às Consultas
INSERT INTO consulta_dente (fk_consulta, fk_dente) VALUES
(2, 16);

-- 13. Carga Inicial de Tipos de Mídia Padrões (Seed Data)
INSERT INTO tipo_midia (id_tipo_midia, nome, descricao, fk_usuario, ativo) VALUES
(1, 'Foto Intraoral', 'Fotografias internas da cavidade bucal e arcadas', NULL, 1),
(2, 'Foto Extraoral', 'Fotografias de face, perfil e sorriso', NULL, 1),
(3, 'Radiografia Panorâmica', 'Radiografias panorâmicas completas', NULL, 1),
(4, 'Radiografia Periapical', 'Radiografias periapicais de dentes específicos', NULL, 1),
(5, 'Tomografia / 3D', 'Tomografias volumétricas ou escaneamentos intraorais 3D', NULL, 1),
(6, 'Documento / Laudo', 'Laudos periciais, termos de consentimento e exames em PDF', NULL, 1),
(7, 'Evolução de Tratamento', 'Registros sequenciais de acompanhamento clínico', NULL, 1);

