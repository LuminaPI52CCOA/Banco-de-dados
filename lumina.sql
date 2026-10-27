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
    lembrete_enviado TINYINT(1) DEFAULT 0,
    alexa_reminder_id VARCHAR(255),
CONSTRAINT fkConsultaCliente
    FOREIGN KEY (fk_cliente)
    REFERENCES cliente(id_cliente),
CONSTRAINT fkConsultaUsuario
    FOREIGN KEY (fk_usuario)
    REFERENCES usuario(id_usuario)
);

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
(3, 'Administrador Lumina', 'admin@lumina.com', '$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC', 1, '11122233344', NULL, 1);

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
INSERT INTO cliente (id_cliente, nome, cpf, rg, data_nascimento, numero_celular, email, sexo, naturalidade, nacionalidade, fk_estado_civil, endereco_residencial, cep, ativo) VALUES 
(1, 'Carlos Silva', '12312312345', '123456789', '1990-05-15', '11987654321', 'carlos.silva@email.com', 'M', 'São Paulo', 'Brasileira', 1, 'Rua das Flores, 120', '01001000', 1),
(2, 'Maria Oliveira', '23423423456', '234567890', '1985-08-20', '11912345678', 'maria.oliveira@email.com', 'F', 'Campinas', 'Brasileira', 2, 'Av. Paulista, 1500', '01310100', 1),
(3, 'Lucas Santos', '34534534567', '345678901', '2000-11-10', '11998877665', 'lucas.santos@email.com', 'M', 'Santos', 'Brasileira', 1, 'Rua Augusta, 450', '01305000', 1),
(4, 'Juliana Costa', '45645645678', '456789012', '1995-03-25', '11977665544', 'juliana.costa@email.com', 'F', 'São Paulo', 'Brasileira', 1, 'Alameda Santos, 800', '01419001', 1);

-- 6. Convênios dos Clientes
INSERT INTO cliente_convenio (id_cliente_convenio, fk_cliente, fk_convenio, numero_inscricao) VALUES 
(1, 1, 1, 'PART-001'),
(2, 2, 2, 'AMIL-987654321'),
(3, 3, 3, 'BRAD-456789123'),
(4, 4, 1, 'PART-004');

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

-- 9. Consultas (Utiliza CURRENT_DATE para que as consultas SEMPRE caiam na data de hoje ao rodar o script)
INSERT INTO consulta (id_consulta, fk_cliente, fk_usuario, data, horario_inicio, horario_fim, status, lembrete_enviado, alexa_reminder_id) VALUES 
-- Consulta 1: John Doe - Já realizada mais cedo hoje
(1, 2, 1, CURRENT_DATE, '09:00:00', '09:45:00', 'CONCLUIDA', 1, 'reminder-concluido-01'),
-- Consulta 2: John Doe - PRÓXIMA CONSULTA DE HOJE (Paciente Carlos Silva com Alergia a Penicilina)
(2, 1, 1, CURRENT_DATE, '14:30:00', '15:15:00', 'AGENDADA', 0, NULL),
-- Consulta 3: John Doe - Atendimento da tarde
(3, 3, 1, CURRENT_DATE, '16:00:00', '16:45:00', 'AGENDADA', 0, NULL),
-- Consulta 4: John Doe - Último atendimento do dia
(4, 4, 1, CURRENT_DATE, '17:30:00', '18:15:00', 'AGENDADA', 0, NULL),
-- Consulta 5: Dra. Ana Maria Souza - Atendimento hoje
(5, 3, 2, CURRENT_DATE, '11:00:00', '11:45:00', 'AGENDADA', 0, NULL),
-- Consulta 6: John Doe - Consulta agendada para amanhã
(6, 1, 1, DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '10:00:00', '10:45:00', 'AGENDADA', 0, NULL);

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

-- 12. Carga Inicial de Tipos de Mídia Padrões (Seed Data)
INSERT INTO tipo_midia (id_tipo_midia, nome, descricao, fk_usuario, ativo) VALUES
(1, 'Foto Intraoral', 'Fotografias internas da cavidade bucal e arcadas', NULL, 1),
(2, 'Foto Extraoral', 'Fotografias de face, perfil e sorriso', NULL, 1),
(3, 'Radiografia Panorâmica', 'Radiografias panorâmicas completas', NULL, 1),
(4, 'Radiografia Periapical', 'Radiografias periapicais de dentes específicos', NULL, 1),
(5, 'Tomografia / 3D', 'Tomografias volumétricas ou escaneamentos intraorais 3D', NULL, 1),
(6, 'Documento / Laudo', 'Laudos periciais, termos de consentimento e exames em PDF', NULL, 1),
(7, 'Evolução de Tratamento', 'Registros sequenciais de acompanhamento clínico', NULL, 1);


-- =============================================================================
-- AGENDAMENTO DE CONSULTAS (tela "Novo Agendamento")
-- Bancos já existentes devem executar migracoes/V2__agendamento_consultas.sql,
-- que aplica estas mesmas alterações de forma incremental e idempotente.
-- =============================================================================

ALTER TABLE consulta
    ADD COLUMN fk_especialidade INT NULL AFTER fk_usuario,
    ADD COLUMN observacoes VARCHAR(500) NULL AFTER status,
    ADD COLUMN tipo_dente VARCHAR(45) NULL AFTER observacoes,
    ADD COLUMN pular_odontograma TINYINT(1) NOT NULL DEFAULT 0 AFTER tipo_dente,
    ADD CONSTRAINT fkConsultaEspecialidade
        FOREIGN KEY (fk_especialidade)
        REFERENCES especialidade(id_especialidade);

CREATE INDEX idx_consulta_dentista_data ON consulta (fk_usuario, data, horario_inicio);

-- Seleção de dentes do odontograma (consulta_procedimento segue reservada para procedimentos)
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

-- Lembretes D-1 via WhatsApp e confirmação pública (entidade NotificacaoWhatsapp do back-end)
CREATE TABLE notificacao_whatsapp (
    id_notificacao INT AUTO_INCREMENT PRIMARY KEY,
    fk_consulta INT NOT NULL,
    fk_cliente INT NOT NULL,
    fk_destinatario INT NOT NULL,
    nome_destinatario VARCHAR(100) NOT NULL,
    grau_parentesco VARCHAR(30),
    numero_telefone_higienizado VARCHAR(20),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDENTE',
    motivo_falha VARCHAR(255),
    data_consulta DATE NOT NULL,
    horario_consulta TIME NOT NULL,
    token_confirmacao VARCHAR(64) NOT NULL,
    limite_confirmacao_em DATETIME NOT NULL,
    confirmado_em DATETIME NULL,
    criado_em DATETIME NOT NULL,
    atualizado_em DATETIME NOT NULL,
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

-- Especialidade e dentes das consultas de exemplo
UPDATE consulta SET fk_especialidade = 1 WHERE id_consulta IN (1, 2, 4, 5, 6);
UPDATE consulta SET fk_especialidade = 3 WHERE id_consulta = 3;

INSERT INTO consulta_dente (fk_consulta, fk_dente) VALUES
(2, 16);
