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

    # Recebe um caminho para txt, baixa CSVs linkados por ele, muda sua codificação e os junta
    # Verifica se o arquivo com URLs de fato se encontra no caminho dado
    if [ ! -f "${CAMINHO}" ]; then
        print_erro_bad_path ${CAMINHO}
        return 1
    fi

    # Cria diretório especial para guardar CSVs baixados
    mkdir ${DIRCSV}

    # Permite leitura do arquivo, baixa os CSVs indicados nele e os converte para UTF-8
    chmod +r ${CAMINHO}
    for i in $( cat ${CAMINHO} ); do
        local NOME_ARQ=$(echo ${i} | sed 's#.*/##')
        
        # Verifica se já não está baixado
        if ! $( ls ${DIRCSV} | grep -q "${NOME_ARQ}" ); then
            wget -nv ${i} -P ${DIRCSV}
            iconv -f ISO-8859-1 -t UTF8 "${DIRCSV}/${NOME_ARQ}" -o "${DIRCSV}/UTF${NOME_ARQ}"
            mv "${DIRCSV}/UTF${NOME_ARQ}" "${DIRCSV}/${NOME_ARQ}" 
        fi
    done

    # Criar CSV com todas as linhas dos outros CSVs baixados 'arquivocompleto.csv'
    local OUTPUT_FILE="${DIRCSV}/arquivocompleto.csv"
    > "${OUTPUT_FILE}"  # Limpa o arquivo se já existir

    for csv_file in $( ls ${DIRCSV} | grep ".*\.csv" ); do
        if [ "${DIRCSV}/${csv_file}" != "${OUTPUT_FILE}" ]; then
            tail -n +2 "${DIRCSV}/${csv_file}" >> "${OUTPUT_FILE}"
        fi
    done
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