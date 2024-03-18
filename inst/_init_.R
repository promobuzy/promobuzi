

lista <- c("https://amzn.to/4a733OZ",
           "https://www.amazon.com.br/dp/B0BTW3LPCF/?_encoding=UTF8&ref_=dlx_gate_dd_dcl_tlt_ffa84d84_dt_pd_gw_unk&pd_rd_w=IQ8ON&content-id=amzn1.sym.1998b660-aebe-49f8-9960-47452c1e2086&pf_rd_p=1998b660-aebe-49f8-9960-47452c1e2086&pf_rd_r=8E8BWVZV4563PRQ2KCTG&pd_rd_wg=ZQWNR&pd_rd_r=960c6405-5ed2-4a6e-98f4-c317b15bf57f&th=1",
           "https://www.magazinevoce.com.br/magazinepromobuzy/lavadora-de-roupas-consul-12kg-16-programas-de-lavagem-branca-cwh12/p/236161000/ed/lava/",
           "https://www.mercadolivre.com.br/notebook-gamer-predator-phn16-71-76pl-ci7-16gb512ssd-rtx4050/p/MLB33314384#reco_item_pos=0&reco_backend=item_decorator&reco_backend_type=function&reco_client=home_items-decorator-legacy&reco_id=940c6e62-b99f-4d82-8d49-a8a444df7660&c_id=/home/navigation-recommendations-seed/element&c_uid=0b2bf2e5-8aeb-419d-b559-231648f5d297&da_id=navigation&da_position=0&id_origin=/home/dynamic_access&da_sort_algorithm=ranker")

lista <- "https://www.mercadolivre.com.br/ventilador-coluna-40cm-super-power-vsp-40c-nb-mondial-cor-da-estrutura-preto-cor-das-pas-cinza-dimetro-40-cm-frequncia-60-material-das-pas-plastico-quantidade-de-pas-6-110v/p/MLB27577458?pdp_filters=category:MLB5726%7Cdeal:MLB779362-1#searchVariation=MLB27577458&position=4&search_layout=stack&type=product&tracking_id=99aa0286-29bc-48a1-8539-65ea90997f5a&deal_print_id=c54ddb40-e537-11ee-a066-8514dc2abc1a&c_id=carouseldynamic-normal&c_element_order=undefined&c_campaign=OFERTAS-PARA-COMPRAR-AGORA-%F0%9F%94%A5&c_uid=c54ddb40-e537-11ee-a066-8514dc2abc1a"

diretorio <- "data-raw"

baixar_paginas(lista_url = lista, diretorio = diretorio)


arquivos <- list.files(diretorio, full.names = T)


dados_amz <- ler_amazon(diretorio = diretorio)

dados_mgl <- ler_magazine_luiza(diretorio = diretorio)

dados_mcl <- ler_mercado_livre(diretorio = diretorio)

ler_pagina <- function(arquivo) {
  if (grepl("amazon", arquivo)) {
    return(ler_amazon(arquivos = arquivo))
  } else if (grepl("magazine", arquivo)) {
    return(ler_magazine_luiza(arquivos = arquivo))
  } else if (grepl("mercado", arquivo)) {
    return(ler_mercado_livre(arquivos = arquivo))
  } else {
    warning("Loja não reconhecida no nome do arquivo:", arquivo)
    return(NULL)
  }
}
