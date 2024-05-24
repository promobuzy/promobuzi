Projeto PromoBuzi
Bem-vindo ao repositório do projeto PromoBuzi. Este projeto contém scripts e ferramentas para realizar web scraping de links de várias lojas e salvar os dados em arquivos Excel.

Estrutura do Repositório
link_in: Diretório onde os arquivos .xlsx contendo os links para web scraping devem ser colocados.
Funcoes_R: Diretório contendo os scripts R para realizar o web scraping de diferentes lojas.
Funcionalidades
Este projeto inclui scripts para realizar web scraping das seguintes lojas:

Amazon
Mercado Livre
Magazine Luiza
Os dados coletados são salvos em arquivos Excel separados e, posteriormente, combinados em um único arquivo.

Como Usar
Pré-requisitos
Certifique-se de ter R e os pacotes necessários instalados. Você pode instalar os pacotes necessários com o seguinte comando:

R
Copiar código
install.packages(c("purrr", "xml2", "stringr", "dplyr", "readr", "tibble", "tidyr", "openxlsx", "glue"))
Passo a Passo
Preparação dos Links:

Coloque os arquivos .xlsx contendo os links para web scraping na pasta link_in.
Executar o Script Principal:

No R, execute o script principal que irá realizar o web scraping e salvar os dados.
R
Copiar código
# Carregar a função principal
source("~/Projetos/promobuzi/Funcoes_R/le_lojas.R")

# Executar a função principal
result <- le_lojas(AMZ = 1, ML = 1, MGL = 1, 
                   dir_funcoes_R = "~/Projetos/promobuzi/Funcoes_R", 
                   dir_output = "~/Projetos/promobuzi/Links_OUT")
Verificar os Resultados:
Os dados coletados serão salvos em arquivos Excel na pasta Links_OUT.
Contribuição
Contribuições são bem-vindas! Se você encontrar problemas ou tiver sugestões de melhorias, sinta-se à vontade para abrir uma issue ou enviar um pull request.

Licença
Este projeto está licenciado sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

Contato
Se você tiver alguma dúvida ou precisar de ajuda, entre em contato conosco em seu-email@exemplo.com.

Estrutura do Projeto
plaintext
Copiar código
promobuzi/
├── link_in/              # Diretório para arquivos de links .xlsx
├── Funcoes_R/            # Diretório para scripts R
│   ├── le_lojas.R
│   ├── ler_amazon.R
│   ├── ler_mercado_livre.R
│   └── ler_magazine_luiza.R
├── Links_OUT/            # Diretório para arquivos de saída .xlsx
└── README.md             # Arquivo README
Exemplo de Arquivo de Links
Coloque seus arquivos de links no formato .xlsx na pasta link_in. O arquivo deve conter os links que serão utilizados para o web scraping.

