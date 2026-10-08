# 🗄️ Lumina — Modelagem e Banco de Dados Relacional (MySQL)

Este repositório armazena o modelo de dados relacional e os scripts de inicialização (DDL e DML) do sistema **Lumina Odontológica**, garantindo integridade referencial, histórico de prontuários e auditoria de integrações de voz.

---

## 📋 Conteúdo do Repositório

* **`lumina.sql`**: Script completo em SQL contendo a criação do banco de dados `Lumina`, todas as tabelas com constraints de chave estrangeira (`FOREIGN KEY`) e inserts iniciais de massa de testes (seeds com usuários, clientes, convênios e consultas).
* **`lumina.mwb`**: Modelo visual do banco de dados para edição e visualização no **MySQL Workbench**.

---

## 🏛️ Estrutura das Tabelas

O schema `Lumina` é composto por 12 tabelas relacionais organizadas em módulos:

### 1. Gestão de Usuários e Acessos
* **`perfil`**: Perfis de controle de acesso (Ex: `ADMIN`, `DENTISTA`, `RECEPCIONISTA`).
* **`usuario`**: Dentistas, recepcionistas e administradores do consultório (com CPF, e-mail único, senha com hash BCrypt e número de CRO).

### 2. Pacientes e Prontuário
* **`estado_civil`**: Tabela de domínio para estados civis.
* **`cliente`**: Cadastro completo do paciente (dados pessoais, contato, endereço, indicação e auto-relacionamento para responsável legal de menores de idade).
* **`convenio`**: Planos de saúde e convênios odontológicos aceitos.
* **`cliente_convenio`**: Associação n-para-n de clientes e seus planos/carteirinhas.
* **`anamnese`**: Questionário de saúde clínico e histórico médico (alergias a medicamentos, condições crônicas, hipertensão, etc.).

### 3. Consultas e Procedimentos
* **`especialidade`**: Especialidades odontológicas (Ex: Ortodontia, Endodontia, Clínico Geral).
* **`procedimento`**: Catálogo de procedimentos executados pela clínica com valores e tempo médio.
* **`consulta`**: Agendamento de atendimentos com data, horário, status, paciente (`fk_cliente`) e dentista responsável (`fk_usuario`).
* **`consulta_procedimento`**: Procedimentos vinculados a uma consulta específica.

### 4. Integração de Voz (Alexa)
* **`usuario_alexa`**: Gerencia a associação segura entre o dispositivo Amazon Echo e o dentista:
  * `fk_usuario`: Dentista autenticado proprietário do dispositivo.
  * `alexa_user_id`: Identificador persistente da Amazon fornecido pela Skill.
  * `codigo_pareamento`: PIN temporário de 6 dígitos para pareamento em tela.
  * `expiracao_codigo`: Timestamp de validade do PIN (10 minutos).
  * `ativo`: Flag de conexão ativa do aparelho no consultório.

---

## ☁️ Automação na AWS (Terraform)

Durante o provisionamento automatizado da infraestrutura em nuvem (módulo [`Infraestrutura/modules/database`](../Infraestrutura/modules/database)):
1. A instância EC2 do MySQL Server é inicializada com o Ubuntu 22.04 LTS.
2. O repositório `Banco-de-dados` é clonado automaticamente na máquina.
3. O script `lumina.sql` é executado na inicialização via `user_data`, criando o banco `Lumina` e aplicando a massa de dados inicial sem intervenção manual.

---

## 💻 Como Executar Localmente

### Opção 1: Via Docker (Recomendado)
```bash
docker run --name lumina-mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=Lumina \
  -e MYSQL_USER=lumina_user \
  -e MYSQL_PASSWORD=lumina_password \
  -p 3306:3306 \
  -v $(pwd)/lumina.sql:/docker-entrypoint-initdb.d/init.sql \
  -d mysql:8.0
```

### Opção 2: Via MySQL Client / Workbench
```bash
mysql -u root -p < lumina.sql
```