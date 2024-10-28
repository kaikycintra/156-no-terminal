#!/bin/bash
# Testes executados automaticamente pre-commit
# Chamado em .git/hooks/pre-commit

# Diretório raiz do projeto
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Diretório temporário para testes
TEST_DIR="${PROJECT_ROOT}/testing/test_dir"
mkdir "${TEST_DIR}"

# Copiar script principal para o TEST_DIR
SCRIPT="${TEST_DIR}/ep2_servico156.sh"
cp "${PROJECT_ROOT}/ep2_servico156.sh" "${SCRIPT}"

# Copiar arquivo com URLs para teste para o TEST_DIR
URL_FILE="${TEST_DIR}/urls1.txt"
cp "${PROJECT_ROOT}/testing/urls1.txt" "${URL_FILE}"

# Definir o diretório de trabalho para o TEST_DIR
cd "${TEST_DIR}"

function test_erro_sem_dados {
    echo "Executando test_erro_sem_dados"

    # Executa o script principal sem parâmetros
    local OUTPUT
    OUTPUT=$("${SCRIPT}")

    # Saída esperada
    local EXPECTED_OUTPUT
    EXPECTED_OUTPUT="ERRO: Não há dados baixados.
Para baixar os dados antes de gerar as estatísticas, use:
  ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"

    # Verifica se a saída contém a mensagem de erro esperada
    if echo "${OUTPUT}" | grep -q "ERRO: Não há dados baixados."; then
        echo "test_erro_sem_dados passou"
        return 0
    else
        echo "test_erro_sem_dados falhou"
        echo "Saída esperada:"
        echo "${EXPECTED_OUTPUT}"
        echo "Saída atual:"
        echo "${OUTPUT}"
        return 1
    fi
}

function test_erro_parametros {
    echo "Executando test_erro_parametros"

    # Executa o script principal com parâmetros incorretos
    local OUTPUT
    OUTPUT=$("${SCRIPT}" param1 param2)

    local EXPECTED_OUTPUT
    EXPECTED_OUTPUT="Número incorreto de parâmetros passados
Utilize um dos modos seguintes de execução
./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>
./ep2_servico156.sh"

    # Verifica se a saída contém a mensagem de erro esperada
    if echo "${OUTPUT}" | grep -q "Número incorreto de parâmetros passados"; then
        echo "test_erro_parametros passou"
        return 0
    else
        echo "test_erro_parametros falhou"
        echo "Saída esperada:"
        echo "${EXPECTED_OUTPUT}"
        echo "Saída atual:"
        echo "${OUTPUT}"
        return 1
    fi
}

function test_erro_bad_path {
    echo "Executando test_erro_bad_path"

    # Executa o script principal com um arquivo inexistente
    local OUTPUT
    OUTPUT=$("${SCRIPT}" "bad.txt")

    local EXPECTED_OUTPUT
    EXPECTED_OUTPUT="ERRO: O arquivo bad.txt não existe."

    # Verifica se a saída contém a mensagem de erro esperada
    if echo "${OUTPUT}" | grep -q "ERRO: O arquivo bad.txt não existe."; then
        echo "test_erro_bad_path passou"
        return 0
    else
        echo "test_erro_bad_path falhou"
        echo "Saída esperada:"
        echo "${EXPECTED_OUTPUT}"
        echo "Saída atual:"
        echo "${OUTPUT}"
        return 1
    fi
}

function test1_execucao_modo_1 {
    echo "Executando test1_execucao_modo_1"

    # Executa o script principal com um arquivo de URLs válido
    local OUTPUT
    OUTPUT=$("${SCRIPT}" "${URL_FILE}")

    # Verifica se nenhuma mensagem de erro é impressa
    # Verifica se o arquivocompleto.csv foi criado dentro de DIRCSV
    local DIRCSV="${TEST_DIR}/diretorio_csv"

    if echo "${OUTPUT}" | grep -q "ERRO"; then
        echo "test1_execucao_modo_1 falhou"
        echo "A saída contém um erro:"
        echo "${OUTPUT}"
        return 1
    elif [ ! -f "${DIRCSV}/arquivocompleto.csv" ]; then
        echo "test1_execucao_modo_1 falhou"
        echo "O arquivo arquivocompleto.csv não foi criado em ${DIRCSV}"
        return 1
    else
        echo "test1_execucao_modo_1 passou"
        return 0
    fi
}

# Sair com erro se algum teste retornar 1
function run_tests {
    test_erro_sem_dados || exit 1
    test_erro_parametros || exit 1
    test_erro_bad_path || exit 1
    #test1_execucao_modo_1 || exit 1
}

run_tests

# Voltar para o diretório inicial
cd "${PROJECT_ROOT}"

# Limpeza do diretório de teste
rm -rf "${TEST_DIR}"

exit 0
