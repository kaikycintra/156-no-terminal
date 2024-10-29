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

    # Cria diretório especial para guardar CSVs baixados, -p pula se já existe, evitando erro
    mkdir -p ${DIRCSV}

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

# $1 = Caminho do arquivo
# Retorna o número de reclamações
function num_reclamacoes {
    local NUM_REC=$( wc -l ${1} | cut -d " " -f1)   # Obtém o número de linhas do arquivo
    let NUM_REC=NUM_REC-1
    echo ${NUM_REC}
}

# Modifica o valor da variável ARQSEL criada no modo de execução 2
function selecionar_arquivo {
    echo -e "\nEscolha uma opção de arquivo: "
    select arquivo in $( ls ${DIRCSV} ); do
        if [ -n ${arquivo} ]; then
            ARQSEL=${DIRCSV}/${arquivo}

            local NOME_ARQSEL=$(echo ${ARQSEL} | sed 's#.*/##')  # Extrai o nome do caminho do arquivo
            echo "+++ Arquivo atual: ${NOME_ARQSEL}"

            local NUM_REC=$( num_reclamacoes ${ARQSEL} )
            echo "+++ Número de reclamações: ${NUM_REC}"
            echo "+++++++++++++++++++++++++++++++++++++++"
            break
        else
            echo "Opção inválida. Tente novamente."
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

    # Arquivo padrão selecionado deve ser arquivocompleto.csv
    # É modificada pela função selecionar_arquivo
    ARQSEL="${DIRCSV}/arquivocompleto.csv"

    # Loop para mostrar o menu com o header
    while true; do
        # Header
       echo -e "\nEscolha uma opção de operação: "

        local OPCOES="selecionar_arquivo adicionar_filtro_coluna limpar_filtros_colunas mostrar_duracao_media_reclamacao mostrar_ranking_reclamacoes mostrar_reclamacoes sair"
        select opt in ${OPCOES}; do
            case $opt in
                "selecionar_arquivo")
                    selecionar_arquivo
                    break
                    ;;
                "adicionar_filtro_coluna")
                    echo "Opção adicionar_filtro_coluna selecionada"
                    # Adicione a lógica para adicionar_filtro_coluna aqui
                    break
                    ;;
                "limpar_filtros_colunas")
                    echo "Opção limpar_filtros_colunas selecionada"
                    # Adicione a lógica para limpar_filtros_colunas aqui
                    break
                    ;;
                "mostrar_duracao_media_reclamacao")
                    echo "Opção mostrar_duracao_media_reclamacao selecionada"
                    # Adicione a lógica para mostrar_duracao_media_reclamacao aqui
                    break
                    ;;
                "mostrar_ranking_reclamacoes")
                    echo "Opção mostrar_ranking_reclamacoes selecionada"
                    # Adicione a lógica para mostrar_ranking_reclamacoes aqui
                    break
                    ;;
                "mostrar_reclamacoes")
                    echo "Opção mostrar_reclamacoes selecionada"
                    # Adicione a lógica para mostrar_reclamacoes aqui
                    break
                    ;;
                "sair")
                    echo "Saindo..."
                    return 0
                    ;;
                *) 
                    echo "Opção inválida ${REPLY}"
                    break
                    ;;
            esac
        done
    done
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