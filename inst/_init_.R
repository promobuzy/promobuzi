

lista <- c("https://amzn.to/4a733OZ",
           "https://www.amazon.com.br/dp/B0BTW3LPCF/?_encoding=UTF8&ref_=dlx_gate_dd_dcl_tlt_ffa84d84_dt_pd_gw_unk&pd_rd_w=IQ8ON&content-id=amzn1.sym.1998b660-aebe-49f8-9960-47452c1e2086&pf_rd_p=1998b660-aebe-49f8-9960-47452c1e2086&pf_rd_r=8E8BWVZV4563PRQ2KCTG&pd_rd_wg=ZQWNR&pd_rd_r=960c6405-5ed2-4a6e-98f4-c317b15bf57f&th=1",
           "https://www.magazinevoce.com.br/magazinepromobuzy/lavadora-de-roupas-consul-12kg-16-programas-de-lavagem-branca-cwh12/p/236161000/ed/lava/",
           "https://www.mercadolivre.com.br/notebook-gamer-predator-phn16-71-76pl-ci7-16gb512ssd-rtx4050/p/MLB33314384#reco_item_pos=0&reco_backend=item_decorator&reco_backend_type=function&reco_client=home_items-decorator-legacy&reco_id=940c6e62-b99f-4d82-8d49-a8a444df7660&c_id=/home/navigation-recommendations-seed/element&c_uid=0b2bf2e5-8aeb-419d-b559-231648f5d297&da_id=navigation&da_position=0&id_origin=/home/dynamic_access&da_sort_algorithm=ranker")

lista <- "https://www.amazon.com.br/LYOR-Bandeja-Bambu-Marrom-Natural/dp/B08X1B72TP?__mk_pt_BR=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=3O2G3I0BSD19&keywords=bandeja&qid=1695737914&refinements=p_72%3A17833786011&rnid=5560472011&sprefix=bande%2Caps%2C326&sr=8-5&th=1&linkCode=sl1&tag=promobuzy-20&linkId=daf4acd3815ef51f47c04843b34c479c&language=pt_BR&ref_=as_li_ss_tl"

diretorio <- "data-raw"

baixar_paginas(lista_url = lista, diretorio = diretorio)

arquivos <- list.files(diretorio, full.names = T)


dados_amz <- ler_amazon(diretorio = diretorio)
dados_mgl <- ler_magazine_luiza(diretorio = diretorio)
dados_mcl <- ler_mercado_livre(diretorio = diretorio)

dados <- rbind(dados_amz,dados_mgl,dados_mcl)
