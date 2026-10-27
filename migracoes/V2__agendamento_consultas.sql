-- =============================================================================
-- MIGRAÇÃO INCREMENTAL: Agendamento de consultas (tela "Novo Agendamento")
-- =============================================================================
-- Pré-requisito: banco criado pelo script lumina.sql (versão anterior).
-- Preserva todos os registros existentes e pode ser executada mais de uma vez
-- (cada alteração verifica o information_schema antes de ser aplicada).
--
-- Alterações:
--   1. consulta: fk_especialidade, observacoes, tipo_dente, pular_odontograma
--      (colunas anuláveis/com default para não quebrar registros antigos).
--   2. consulta: índice (fk_usuario, data, horario_inicio) para a busca de
--      conflitos e de horários disponíveis por dentista/dia.
--   3. consulta_dente: associação consulta x dente (somente a seleção do
--      odontograma). consulta_procedimento continua reservada para
--      procedimentos de fato, pois exige fk_procedimento.
--   4. consulta.status: registros sem status passam a 'AGENDADA', valor
--      padrão já assumido pela aplicação.
--   5. notificacao_whatsapp: criada caso ainda não exista. A entidade
--      NotificacaoWhatsapp já é usada pelo back-end (lembretes D-1 e
--      confirmação pública) e agora também é atualizada no reagendamento e no
--      cancelamento lógico, mas a tabela não constava em lumina.sql.
--
-- Execução: mysql -u root -p Lumina < migracoes/V2__agendamento_consultas.sql
-- =============================================================================

USE Lumina;

DROP PROCEDURE IF EXISTS lumina_executar_se;

DELIMITER $$
CREATE PROCEDURE lumina_executar_se(IN condicao_satisfeita BOOLEAN, IN comando TEXT)
BEGIN
    IF condicao_satisfeita THEN
        SET @comando_migracao = comando;
        PREPARE stmt FROM @comando_migracao;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 1. Novas colunas em consulta
-- -----------------------------------------------------------------------------
CALL lumina_executar_se(
    (SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'consulta' AND COLUMN_NAME = 'fk_especialidade'),
    'ALTER TABLE consulta ADD COLUMN fk_especialidade INT NULL AFTER fk_usuario'
);

CALL lumina_executar_se(
    (SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'consulta' AND COLUMN_NAME = 'observacoes'),
    'ALTER TABLE consulta ADD COLUMN observacoes VARCHAR(500) NULL AFTER status'
);

CALL lumina_executar_se(
    (SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'consulta' AND COLUMN_NAME = 'tipo_dente'),
    'ALTER TABLE consulta ADD COLUMN tipo_dente VARCHAR(45) NULL AFTER observacoes'
);

CALL lumina_executar_se(
    (SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'consulta' AND COLUMN_NAME = 'pular_odontograma'),
    'ALTER TABLE consulta ADD COLUMN pular_odontograma TINYINT(1) NOT NULL DEFAULT 0 AFTER tipo_dente'
);

CALL lumina_executar_se(
    (SELECT COUNT(*) = 0 FROM information_schema.TABLE_CONSTRAINTS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'consulta' AND CONSTRAINT_NAME = 'fkConsultaEspecialidade'),
    'ALTER TABLE consulta ADD CONSTRAINT fkConsultaEspecialidade FOREIGN KEY (fk_especialidade) REFERENCES especialidade(id_especialidade)'
);

-- -----------------------------------------------------------------------------
-- 2. Índice para conflitos/disponibilidade por dentista e dia
-- -----------------------------------------------------------------------------
CALL lumina_executar_se(
    (SELECT COUNT(*) = 0 FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'consulta' AND INDEX_NAME = 'idx_consulta_dentista_data'),
    'CREATE INDEX idx_consulta_dentista_data ON consulta (fk_usuario, data, horario_inicio)'
);

-- -----------------------------------------------------------------------------
-- 3. Seleção de dentes do odontograma
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS consulta_dente (
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

-- -----------------------------------------------------------------------------
-- 4. Status padrão para registros antigos
-- -----------------------------------------------------------------------------
UPDATE consulta SET status = 'AGENDADA' WHERE status IS NULL;

-- -----------------------------------------------------------------------------
-- 5. Notificações WhatsApp (estrutura usada pela entidade NotificacaoWhatsapp)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notificacao_whatsapp (
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

CALL lumina_executar_se(
    (SELECT COUNT(*) = 0 FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'notificacao_whatsapp' AND INDEX_NAME = 'idx_notificacao_data_status'),
    'CREATE INDEX idx_notificacao_data_status ON notificacao_whatsapp (data_consulta, status)'
);

DROP PROCEDURE IF EXISTS lumina_executar_se;
