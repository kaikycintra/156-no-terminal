Repo for the second project of MAC0216 - Técnicas de Programação I at the University of São Paulo

Created by Kaiky Henrique Ribeiro Cintra

---

##
Este programa implementa uma ferramenta de terminal que mostra estatísticas do serviço 156 da Prefeitura de São Paulo.

Ele oferece maneiras de manipular os dados para facilitar sua análise.

As instruções de uso estão contidas no script bash, basta rodá-lo.

---

## Automating tests:

To set up the pre-commit hook, run the following commands:

```bash
$ touch .git/hooks/pre-commit
$ chmod +x .git/hooks/pre-commit
```

The pre-commit file should contain:
```bash
#!/bin/bash

# Run test script
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "${PROJECT_ROOT}/testing"
./tests.sh

if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

echo "Tests passed. Proceeding with commit."
exit 0
```
