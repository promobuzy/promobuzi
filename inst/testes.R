

lista <- c("https://amzn.to/4a733OZ","https://www.amazon.com.br/dp/B0BTW3LPCF/?_encoding=UTF8&ref_=dlx_gate_dd_dcl_tlt_ffa84d84_dt_pd_gw_unk&pd_rd_w=IQ8ON&content-id=amzn1.sym.1998b660-aebe-49f8-9960-47452c1e2086&pf_rd_p=1998b660-aebe-49f8-9960-47452c1e2086&pf_rd_r=8E8BWVZV4563PRQ2KCTG&pd_rd_wg=ZQWNR&pd_rd_r=960c6405-5ed2-4a6e-98f4-c317b15bf57f&th=1")

baixar_paginas(nome_loja = "Amazon2", url = lista, diretorio = "data-raw")

nome_loja <- "Amazon"

arquivos <- list.files(diretorio, full.names = T)

dados <- ler_amazon(arquivos = arquivos)
