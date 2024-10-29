#!/bin/bash
##################################################################
# MAC0216 - Técnicas de Programação I (2024)
# EP2 - Programação em Bash
#
# Nome do(a) aluno(a): Kaiky Henrique Ribeiro Cintra
# NUSP: 13731160
##################################################################


# Definição de variáveis globais
##################################################################

# Nome do diretório especial criado e manipulado pelo script
DIRCSV="diretorio_csv"

# Arquivo CSV selecionado padrão
ARQSEL="${DIRCSV}/arquivocompleto.csv"

# Array associativo para armazenar filtros selecionados
declare -A FILTROS

# Funções de mensagens e tratamento de erros
##################################################################

# Imprime o cabeçalho do programa
function print_header {
    echo "+++++++++++++++++++++++++++++++++++++++"
    echo "Este programa mostra estatísticas do"
    echo "Serviço 156 da Prefeitura de São Paulo"
    echo "+++++++++++++++++++++++++++++++++++++++"
}

# Mensagem de erro quando não há dados baixados
function print_erro_sem_dados {
    echo "ERRO: Não há dados baixados."
    echo "Para baixar os dados antes de gerar as estatísticas, use:"
    echo "  ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
}

# Mensagem de erro para número incorreto de parâmetros
function print_erro_parametros {
    echo "Número incorreto de parâmetros passados"
    echo "Utilize um dos modos seguintes de execução:"
    echo "./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    echo "./ep2_servico156.sh"
}

# Mensagem de erro quando o arquivo especificado não existe
function print_erro_bad_path {
    echo "ERRO: O arquivo $1 não existe."
}

# Funções de carregamento de dados e inicialização
##################################################################

# Modo de execução 1: lê arquivo com URLs, baixa os CSVs e os adiciona ao DIRCSV
function execucao_modo_1 {
    local CAMINHO=$1

    # Verifica se o arquivo com URLs existe
    if [ ! -f "${CAMINHO}" ]; then
        print_erro_bad_path ${CAMINHO}
        return 1
    fi

    # Cria o diretório para guardar os CSVs, se não existir
    mkdir -p ${DIRCSV}

    # Baixa os arquivos CSV listados no arquivo de URLs
    chmod +r ${CAMINHO}
    for i in $(cat ${CAMINHO}); do
        local NOME_ARQ=$(echo ${i} | sed 's#.*/##')
        
        # Verifica se o arquivo já foi baixado
        if ! $(ls ${DIRCSV} | grep -q "${NOME_ARQ}"); then
            wget -nv ${i} -P ${DIRCSV}  # Baixa o arquivo
            # Converte o arquivo para UTF-8
            iconv -f ISO-8859-1 -t UTF8 "${DIRCSV}/${NOME_ARQ}" -o "${DIRCSV}/UTF${NOME_ARQ}"
            mv "${DIRCSV}/UTF${NOME_ARQ}" "${DIRCSV}/${NOME_ARQ}"
        fi
    done

    # Cria um CSV completo com todas as linhas dos outros CSVs baixados
    local OUTPUT_FILE="${DIRCSV}/arquivocompleto.csv"
    > "${OUTPUT_FILE}"  # Limpa o arquivo se já existir

    for csv_file in $(ls ${DIRCSV} | grep ".*\.csv"); do
        if [ "${DIRCSV}/${csv_file}" != "${OUTPUT_FILE}" ]; then
            if [ ! -s "${OUTPUT_FILE}" ]; then
                # Inclui o cabeçalho se o arquivo de saída estiver vazio
                cat "${DIRCSV}/${csv_file}" >> "${OUTPUT_FILE}"
            else
                # Exclui o cabeçalho caso contrário
                tail -n +2 "${DIRCSV}/${csv_file}" >> "${OUTPUT_FILE}"
            fi
        fi
    done
}

# Retorna o número de linhas com dados em um CSV (exclui o cabeçalho)
function num_linhas_csv {
    local NUM_LIN=$(wc -l ${1} | cut -d " " -f1)  # Obtém o número total de linhas
    let NUM_LIN=NUM_LIN-1  # Subtrai 1 para excluir o cabeçalho
    echo ${NUM_LIN}
}

# Seleciona um arquivo CSV para trabalhar e limpa os filtros selecionados
function selecionar_arquivo {
    echo -e "\nEscolha uma opção de arquivo:"
    select arquivo in $(ls ${DIRCSV}); do
        if [ -n "${arquivo}" ]; then
            ARQSEL="${DIRCSV}/${arquivo}"

            local NOME_ARQSEL=$(basename "${ARQSEL}")  # Extrai o nome do arquivo
            echo "+++ Arquivo atual: ${NOME_ARQSEL}"

            local NUM_REC=$(num_linhas_csv "${ARQSEL}")
            echo "+++ Número de reclamações: ${NUM_REC}"
            echo "+++++++++++++++++++++++++++++++++++++++"

            # Limpa os filtros atuais
            FILTROS=()  # Esvazia o array de filtros
            break
        else
            echo "Opção inválida. Tente novamente."
        fi
    done
}

# Funções de manipulação de filtros
##################################################################

# Obtém o índice de uma coluna no CSV
function obter_indice_coluna {
    local COLUNA="$1"
    local ARQ="$2"
    # Lê o cabeçalho e remove caracteres de retorno de carro
    local header_line=$(head -n 1 "${ARQ}" | tr -d '\r')
    # Divide o cabeçalho em colunas
    IFS=';' read -r -a colunas <<< "${header_line}"
    # Remove espaços em branco no início e no fim do nome da coluna
    COLUNA="$(echo -e "${COLUNA}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    # Procura o índice correspondente à coluna
    for ((i=0; i<${#colunas[@]}; i++)); do
        local coluna_nome="${colunas[$i]}"
        coluna_nome="$(echo -e "${coluna_nome}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        if [ "${coluna_nome}" == "${COLUNA}" ]; then
            echo "$((i + 1))"  # Índices começam em 1
            return
        fi
    done
    # Retorna vazio se não encontrar a coluna
    echo ""
}

# Adiciona um filtro baseado em uma coluna selecionada
function adicionar_filtro_coluna {
    # Extrai as colunas do cabeçalho
    IFS=';' read -r -a colunas <<< "$(head -n 1 "${ARQSEL}")"

    # Menu de seleção de coluna
    echo -e "\nEscolha uma opção de coluna para o filtro:"
    select COLUNA in "${colunas[@]}"; do
        if [ -n "${COLUNA}" ]; then
            break 
        else
            echo "Opção inválida. Tente novamente."
        fi
    done

    # Obtém o índice da coluna selecionada
    local col_index=${REPLY}

    # Construir o comando GREP_CMD aplicando os filtros existentes, excluindo a coluna atual
    local GREP_CMD=""
    if [ ${#FILTROS[@]} -gt 0 ]; then
        for key in "${!FILTROS[@]}"; do
            if [ "${key}" != "${COLUNA}" ]; then
                local idx=$(obter_indice_coluna "${key}" "${ARQSEL}")
                if [ -z "${idx}" ]; then
                    echo "Erro: Não foi possível encontrar a coluna '${key}' no arquivo."
                    return 1
                fi
                local val="${FILTROS[$key]}"
                val=$(echo "${val}" | sed 's/[]\/$*.^[]/\\&/g')  # Escapa caracteres especiais
                if [ -z "${GREP_CMD}" ]; then
                    GREP_CMD="grep -E \"^([^;]*;){$((${idx}-1))}${val}([;]|$)\""
                else
                    GREP_CMD+=" | grep -E \"^([^;]*;){$((${idx}-1))}${val}([;]|$)\""
                fi
            fi
        done
    fi

    # Extrai valores únicos da coluna selecionada com suas contagens, aplicando os filtros existentes
    if [ -n "${GREP_CMD}" ]; then
        valores=$(eval "tail -n +2 \"${ARQSEL}\" | ${GREP_CMD} | awk -F';' -v col=\"${col_index}\" '{print \$col}' | sort | uniq -c")
    else
        valores=$(tail -n +2 "${ARQSEL}" | awk -F';' -v col="${col_index}" '{print $col}' | sort | uniq -c)
    fi

    # Prepara o array de valores para o menu
    valores_array=()
    while IFS= read -r line; do
        # Remove a contagem do início da linha
        valor=$(echo "${line}" | sed 's/^[ \t]*[0-9]*[ \t]*//')
        if [ -n "${valor}" ]; then
            valores_array+=("$valor")
        fi
    done <<< "${valores}"

    # Verifica se há valores disponíveis
    if [ ${#valores_array[@]} -eq 0 ]; then
        echo "Não há valores disponíveis para esta coluna com os filtros atuais."
        return
    fi

    # Menu para selecionar o valor do filtro
    echo -e "\nEscolha uma opção de valor para ${COLUNA}:"
    select VALOR in "${valores_array[@]}"; do
        if [ -n "${VALOR}" ]; then
            break 
        else
            echo "Opção inválida. Tente novamente."
        fi
    done

    # Adiciona o filtro ao array FILTROS
    FILTROS["${COLUNA}"]="${VALOR}"

    # Exibe informações sobre o filtro adicionado
    echo "+++ Adicionado filtro: ${COLUNA} = ${VALOR}"
    echo "+++ Arquivo atual: $(basename "${ARQSEL}")"

    # Exibe os filtros atuais
    echo "+++ Filtros atuais: "
    local first=1
    for key in "${!FILTROS[@]}"; do
        if [ $first -eq 1 ]; then
            echo -n "${key} = ${FILTROS[$key]}"
            first=0
        else
            echo -n " | ${key} = ${FILTROS[$key]}"
        fi
    done
    echo

    # Obtém e exibe o número de reclamações com os filtros aplicados
    local NUM_REC=$(num_reclamacoes_filtros)
    echo "+++ Número de reclamações: ${NUM_REC}"
    echo "+++++++++++++++++++++++++++++++++++++++"
}

# Conta o número de reclamações que correspondem aos filtros aplicados
function num_reclamacoes_filtros {
    local ARQ="${ARQSEL}"

    # Inicializa o comando de filtro
    local GREP_CMD=""

    # Se houver filtros, constrói o comando grep
    if [ ${#FILTROS[@]} -gt 0 ]; then
        for key in "${!FILTROS[@]}"; do
            local col_index=$(obter_indice_coluna "${key}" "${ARQ}")
            if [ -z "${col_index}" ]; then
                echo "Erro: Não foi possível encontrar a coluna '${key}' no arquivo."
                return 1
            fi
            local value="${FILTROS[$key]}"

            # Escapa caracteres especiais no valor
            value=$(echo "${value}" | sed 's/[]\/$*.^[]/\\&/g')

            # Adiciona a condição de filtro ao comando grep
            if [ -z "${GREP_CMD}" ]; then
                GREP_CMD="grep -E \"^([^;]*;){$((${col_index}-1))}${value}([;]|$)\""
            else
                GREP_CMD+=" | grep -E \"^([^;]*;){$((${col_index}-1))}${value}([;]|$)\""
            fi
        done

        # Conta o número de linhas correspondentes aos filtros
        local NUM_REC=$(eval "tail -n +2 \"${ARQ}\" | ${GREP_CMD} | wc -l")
    else
        # Se não houver filtros, conta todas as linhas excluindo o cabeçalho
        local NUM_REC=$(tail -n +2 "${ARQ}" | wc -l)
    fi

    echo "${NUM_REC}"
}

# Limpa todos os filtros aplicados
function limpar_filtros_colunas {
    FILTROS=()  # Esvazia o array de filtros
    echo "+++ Filtros removidos"
    echo "+++ Arquivo atual: $(basename ${ARQSEL})"
    local NUM_REC=$(num_reclamacoes_filtros)
    echo "+++ Número de reclamações: ${NUM_REC}"
    echo "+++++++++++++++++++++++++++++++++++++++"
}

# Funções de análise de dados
##################################################################

# Mostra o ranking das reclamações com base em uma coluna selecionada
function mostrar_ranking_reclamacoes {
    local ARQ="${ARQSEL}"
    
    # Seleciona a coluna para o ranking
    IFS=';' read -r -a colunas <<< "$(head -n 1 "${ARQ}")"
    echo -e "\nEscolha uma opção de coluna para análise:"
    select COLUNA in "${colunas[@]}"; do
        if [ -n "${COLUNA}" ]; then
            break
        else
            echo "Opção inválida. Tente novamente."
        fi
    done
    
    # Obtém o índice da coluna
    local col_index=$(obter_indice_coluna "${COLUNA}" "${ARQ}")
    
    # Aplica filtros se houver
    local GREP_CMD=""
    if [ ${#FILTROS[@]} -gt 0 ]; then
        for key in "${!FILTROS[@]}"; do
            local idx=$(obter_indice_coluna "${key}" "${ARQ}")
            local val="${FILTROS[$key]}"
            val=$(echo "${val}" | sed 's/[]\/$*.^[]/\\&/g')
            if [ -z "${GREP_CMD}" ]; then
                GREP_CMD="grep -E \"^([^;]*;){$((${idx}-1))}${val}([;]|$)\""
            else
                GREP_CMD+=" | grep -E \"^([^;]*;){$((${idx}-1))}${val}([;]|$)\""
            fi
        done
    fi
    
    # Conta o número de reclamações com os filtros
    local NUM_REC=$(num_reclamacoes_filtros)
    
    # Extrai e conta os valores
    if [ -n "${GREP_CMD}" ]; then
        ranking=$(eval "tail -n +2 \"${ARQ}\" | ${GREP_CMD} | awk -F';' -v col=${col_index} '{print \$col}' | sort | uniq -c | sort -nr")
    else
        ranking=$(tail -n +2 "${ARQ}" | awk -F';' -v col=${col_index} '{print $col}' | sort | uniq -c | sort -nr)
    fi
    
    # Imprime o ranking
    echo "+++ ${COLUNA} com mais reclamações:"
    echo "${ranking}" | head -n 5
    echo "+++++++++++++++++++++++++++++++++++++++"
}

# Mostra as reclamações aplicando os filtros atuais
function mostrar_reclamacoes {
    local ARQ="${ARQSEL}"
    
    # Inicializa o comando de filtro
    local GREP_CMD=""
    
    # Construir o comando GREP_CMD aplicando os filtros atuais
    if [ ${#FILTROS[@]} -gt 0 ]; then
        for key in "${!FILTROS[@]}"; do
            local col_index=$(obter_indice_coluna "${key}" "${ARQ}")
            if [ -z "${col_index}" ]; then
                echo "Erro: Não foi possível encontrar a coluna '${key}' no arquivo."
                return 1
            fi
            local value="${FILTROS[$key]}"

            # Escapa caracteres especiais no valor
            value=$(echo "${value}" | sed 's/[]\/$*.^[]/\\&/g')

            # Adiciona a condição de filtro ao comando grep
            if [ -z "${GREP_CMD}" ]; then
                GREP_CMD="grep -E \"^([^;]*;){$((${col_index}-1))}${value}([;]|$)\""
            else
                GREP_CMD+=" | grep -E \"^([^;]*;){$((${col_index}-1))}${value}([;]|$)\""
            fi
        done
    fi
    
    # Aplica os filtros e exibe as linhas correspondentes
    if [ -n "${GREP_CMD}" ]; then
        eval "tail -n +2 \"${ARQ}\" | ${GREP_CMD}"
    else
        tail -n +2 "${ARQ}"
    fi
    
    # Adiciona uma quebra de linha
    echo
    
    # Exibe o nome do arquivo atual
    echo "+++ Arquivo atual: $(basename "${ARQSEL}")"
    
    # Exibe os filtros atuais
    if [ ${#FILTROS[@]} -gt 0 ]; then
        echo -n "+++ Filtros atuais: "
        local first=1
        for key in "${!FILTROS[@]}"; do
            if [ $first -eq 1 ]; then
                echo -n "${key} = ${FILTROS[$key]}"
                first=0
            else
                echo -n " | ${key} = ${FILTROS[$key]}"
            fi
        done
        echo
    else
        echo "+++ Filtros atuais:"
    fi
    
    # Obtém e exibe o número de reclamações com os filtros aplicados
    local NUM_REC=$(num_reclamacoes_filtros)
    echo "+++ Número de reclamações: ${NUM_REC}"
    echo "+++++++++++++++++++++++++++++++++++++++"
}

# Mostra a duração média das reclamações
function mostrar_duracao_media_reclamacao {
    local ARQ="${ARQSEL}"
    
    # Identifica os índices das colunas de data
    local col_data_abertura=$(obter_indice_coluna "Data de abertura" "${ARQ}")
    local col_data_parecer=$(obter_indice_coluna "Data do Parecer" "${ARQ}")
    
    if [ -z "${col_data_abertura}" ] || [ -z "${col_data_parecer}" ]; then
        echo "Erro: Não foi possível encontrar as colunas de datas no arquivo."
        return 1
    fi
    
    # Construir o comando GREP_CMD aplicando os filtros atuais
    local GREP_CMD=""
    if [ ${#FILTROS[@]} -gt 0 ]; then
        for key in "${!FILTROS[@]}"; do
            local idx=$(obter_indice_coluna "${key}" "${ARQ}")
            if [ -z "${idx}" ]; then
                echo "Erro: Não foi possível encontrar a coluna '${key}' no arquivo."
                return 1
            fi
            local val="${FILTROS[$key]}"
            val=$(echo "${val}" | sed 's/[]\/$*.^[]/\\&/g')
            if [ -z "${GREP_CMD}" ]; then
                GREP_CMD="grep -E \"^([^;]*;){$((${idx}-1))}${val}([;]|$)\""
            else
                GREP_CMD+=" | grep -E \"^([^;]*;){$((${idx}-1))}${val}([;]|$)\""
            fi
        done
    fi
    
    # Extrai as linhas aplicando os filtros
    if [ -n "${GREP_CMD}" ]; then
        linhas=$(eval "tail -n +2 \"${ARQ}\" | ${GREP_CMD}")
    else
        linhas=$(tail -n +2 "${ARQ}")
    fi
    
    # Variáveis para cálculo
    local total_duracao=0
    local count=0
    
    # Processa cada linha
    while IFS= read -r line; do
        IFS=';' read -r -a campos <<< "$line"
        data_abertura="${campos[$((col_data_abertura-1))]}"
        data_parecer="${campos[$((col_data_parecer-1))]}"
        
        # Verifica se as datas não estão vazias
        if [ -n "${data_abertura}" ] && [ -n "${data_parecer}" ]; then
            # Converte as datas para o formato "YYYY-MM-DD"
            data_abertura_fmt=$(echo "${data_abertura}" | sed 's/\([0-9]*\)\/\([0-9]*\)\/\([0-9]*\)/\3-\2-\1/')
            data_parecer_fmt=$(echo "${data_parecer}" | sed 's/\([0-9]*\)\/\([0-9]*\)\/\([0-9]*\)/\3-\2-\1/')
            
            # Converte as datas para segundos desde o Epoch
            segundos_abertura=$(date -d "${data_abertura_fmt}" +%s 2>/dev/null)
            segundos_parecer=$(date -d "${data_parecer_fmt}" +%s 2>/dev/null)
            
            # Verifica se as conversões foram bem-sucedidas
            if [ -n "${segundos_abertura}" ] && [ -n "${segundos_parecer}" ]; then
                # Calcula a diferença em segundos
                duracao=$((segundos_parecer - segundos_abertura))
                
                # Soma a duração total
                total_duracao=$((total_duracao + duracao))
                count=$((count + 1))
            fi
        fi
    done <<< "$linhas"
    
    # Verifica se houve reclamações válidas
    if [ $count -eq 0 ]; then
        echo "Não foi possível calcular a duração média. Verifique se as datas estão no formato correto."
        return 1
    fi
    
    # Calcula a duração média em dias
    media_segundos=$((total_duracao / count))
    media_dias=$((media_segundos / 86400))  # 86400 segundos em um dia
    
    # Exibe o resultado
    echo "+++ Duração média da reclamação: ${media_dias} dias"
    echo "+++++++++++++++++++++++++++++++++++++++"
}

# Função de execução do modo 2
##################################################################

# Modo de execução 2: manipula os dados presentes no DIRCSV
function execucao_modo_2 {
    # Verifica a presença dos arquivos CSV
    if [ ! -d "${DIRCSV}" ]; then
        print_erro_sem_dados
        return 1
    fi

    # Loop para mostrar o menu de operações
    while true; do
        echo -e "\nEscolha uma opção de operação: "

        local OPCOES="selecionar_arquivo adicionar_filtro_coluna limpar_filtros_colunas mostrar_duracao_media_reclamacao mostrar_ranking_reclamacoes mostrar_reclamacoes sair"
        select opt in ${OPCOES}; do
            case $opt in
                "selecionar_arquivo")
                    selecionar_arquivo
                    break
                    ;;
                "adicionar_filtro_coluna")
                    adicionar_filtro_coluna
                    break
                    ;;
                "limpar_filtros_colunas")
                    limpar_filtros_colunas
                    break
                    ;;
                "mostrar_duracao_media_reclamacao")
                    mostrar_duracao_media_reclamacao
                    break
                    ;;
                "mostrar_ranking_reclamacoes")
                    mostrar_ranking_reclamacoes
                    break
                    ;;
                "mostrar_reclamacoes")
                    mostrar_reclamacoes
                    break
                    ;;
                "sair")
                    echo "Fim do programa"
                    echo "+++++++++++++++++++++++++++++++++++++++"
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

# Início do script
##################################################################

print_header

# Verifica o número de parâmetros e executa o modo correspondente
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