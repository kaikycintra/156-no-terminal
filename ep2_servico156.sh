#!/bin/bash

# Modo de execução 1, um parâmetro
# Recebe um caminho para txt, baixa CSVs linkados por ele, muda sua codificação e os junta
if [ $# -eq 1 ]; then
    # Baixar os CSVs e gravar em um diretório especial para armazenar os dados
        # wget -nv <URL do arquivo a baixar> -P <diretório de destino>
    # Converter codificação de ISO-8859-1 para UTF-8
        # iconv -f ISO-8859-1 -t UTF8 <nome arq de entrada> -o <nome arq de saída>
    # Cria CSV com todas as linhas dos outros CSVs baixados 'arquivocompleto.csv'
    # Entra no Modo de execução 2

# Modo de execução 2, sem parâmetro
# 
elif [ $# -eq 0 ]; then
    # Verificar presença dos arquivos CSV
    # Opções de manipulação dos arquivos:
        # 1 selecionar_arquivo
        # 2 adicionar_filtro_coluna
        # 3 limpar_filtros_colunas
        # 4 mostrar_duracao_media_reclamacao
        # 5 mostrar_ranking_reclamacoes
        # 6 mostrar_reclamacoes

else
    # Mensagem explicando como usar o programa
fi

exit 0