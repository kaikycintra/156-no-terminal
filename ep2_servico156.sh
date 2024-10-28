#!/bin/bash
##################################################################
# MAC0216 - Técnicas de Programação I (2024)
# EP2 - Programação em Bash
#
# Nome do(a) aluno(a) 1: Kaiky Henrique Ribeiro Cintra
# NUSP 1: 13731160
##################################################################

# Definição do nome do diretório especial criado e manipulado pelo script
DIRCSV="diretorio_csv"

# Definição das funções que guiam o funcionamento do script
##################################################################

function print_header {
    echo "+++++++++++++++++++++++++++++++++++++++"
    echo "Este programa mostra estatísticas do"
    echo "Serviço 156 da Prefeitura de São Paulo"
    echo "+++++++++++++++++++++++++++++++++++++++"
}

function print_erro_sem_dados {
    echo "ERRO: Não há dados baixados."
    echo "Para baixar os dados antes de gerar as estatísticas, use:"
    echo "  ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
}

function print_erro_parametros {
    echo "Número incorreto de parâmetros passados"
    echo "Utilize um dos modos seguintes de execução"
    echo "./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    echo "./ep2_servico156.sh"
}

function print_erro_bad_path {
    echo "ERRO: O arquivo $1 não existe."
}

# Lê arquivo com URLs, baixa seus CSVs e adiciona ao DIRCSV
function execucao_modo_1 {
    local CAMINHO=$1

    # Verifica se o arquivo com URLs de fato se encontra no caminho dado
    if [ ! -f "${CAMINHO}" ]; then
        print_erro_bad_path ${CAMINHO}
        return 1
    fi

    # Recebe um caminho para txt, baixa CSVs linkados por ele, muda sua codificação e os junta
    # Baixar os CSVs e gravar em um diretório especial para armazenar os dados
    # Converter codificação de ISO-8859-1 para UTF-8
    # Criar CSV com todas as linhas dos outros CSVs baixados 'arquivocompleto.csv'
    # Se o arquivocompleto.csv já existir, substituí-lo
}

# Manipula os dados presentes no DIRCSV
function execucao_modo_2 {
    # Verificar presença dos arquivos CSV
    if [ ! -d "${DIRCSV}" ]; then
        print_erro_sem_dados
        return 1
    fi

    # Opções de manipulação dos arquivos:
    # 1 selecionar_arquivo
    # 2 adicionar_filtro_coluna
    # 3 limpar_filtros_colunas
    # 4 mostrar_duracao_media_reclamacao
    # 5 mostrar_ranking_reclamacoes
    # 6 mostrar_reclamacoes
}

##################################################################

print_header

# Um parâmetro, executa os dois modos
if [ $# -eq 1 ]; then
    execucao_modo_1 $1
    if [ $? -eq 1 ]; then
        exit 1
    fi

    execucao_modo_2
    if [ $? -eq 1 ]; then
        exit 1
    fi

    exit 0

# Sem parâmetros, executa somente o modo 2
elif [ $# -eq 0 ]; then
    execucao_modo_2
    if [ $? -eq 1 ]; then
        exit 1
    fi
    
    exit 0
else
    print_erro_parametros
    exit 1
fi