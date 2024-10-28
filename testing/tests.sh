# Testes executados automaticamente pre-commit
# Chamado em .git/hooks/pre-commit

#!/bin/bash
# Diretório temporário para testes
TEST_DIR="test_dir"
mkdir -p $TEST_DIR

# Arquivo temporário para URLs
URL_FILE="$TEST_DIR/urls1.txt"

# Função para testar print_erro_sem_dados
function test_print_erro_sem_dados {
    output=$(print_erro_sem_dados)
    expected_output="ERRO: Não há dados baixados.
Para baixar os dados antes de gerar as estatísticas, use:
  ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    if [ "$output" == "$expected_output" ]; then
        echo "test_print_erro_sem_dados PASSED"
    else
        echo "test_print_erro_sem_dados FAILED"
        return 1
    fi
}

# Função para testar print_erro_parametros
function test_print_erro_parametros {
    output=$(print_erro_parametros)
    expected_output="Número incorreto de parâmetros passados
Utilize um dos modos seguintes de execução
./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>
./ep2_servico156.sh"
    if [ "$output" == "$expected_output" ]; then
        echo "test_print_erro_parametros PASSED"
    else
        echo "test_print_erro_parametros FAILED"
        return 1
    fi
}

# Função para testar print_erro_bad_path
function test_print_erro_bad_path {
    output=$(print_erro_bad_path "invalid_path")
    expected_output="ERRO: O arquivo invalid_path não existe."
    if [ "$output" == "$expected_output" ]; then
        echo "test_print_erro_bad_path PASSED"
    else
        echo "test_print_erro_bad_path FAILED"
        return 1
    fi
}

# Função para testar execucao_modo_1
#function test_execucao_modo_1 {
    #echo "http://example.com/file.csv" > $URL_FILE
    #execucao_modo_1 $URL_FILE
    #if [ $? -eq 0 ]; then
    #    echo "test_execucao_modo_1 PASSED"
    #else
    #    echo "test_execucao_modo_1 FAILED"
    #    return 1
    #fi
#}

# Função para testar execucao_modo_2
#function test_execucao_modo_2 {
    #mkdir -p $DIRCSV
    #execucao_modo_2
    #if [ $? -eq 0 ]; then
    #    echo "test_execucao_modo_2 PASSED"
    #else
    #    echo "test_execucao_modo_2 FAILED"
    #    return 1
    #fi
#}

# Executar todos os testes
function run_tests {
    test_print_erro_sem_dados
    test_print_erro_parametros
    test_print_erro_bad_path
    #test_execucao_modo_1
    #test_execucao_modo_2
}

# Executar os testes e capturar o status
run_tests
TEST_STATUS=$?

# Limpar diretório de testes
rm -rf $TEST_DIR
rm -rf $DIRCSV

# Sair com o status dos testes
exit $TEST_STATUS