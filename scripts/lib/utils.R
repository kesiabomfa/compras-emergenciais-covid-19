recode <- function(df) {
  
  return <- df %>% 
    dplyr::mutate_if(lubridate::is.POSIXt, lubridate::as_date)
  
  return
  
}

read <- function(path) {

  infer_spec <- names(readxl::read_excel(path, n_max = 1, .name_repair = janitor::make_clean_names))
  
  expected_cols <- c("numero_processo_formatado", "url_portal_transparencia", "data_criacao_processo", "objeto_processo", 
                     "url_documentos_processo", "codigo_orgao_entidade_pedido", 
                     "nome_orgao_entidade_pedido", 
                     "situacao_processo", "procedimento_contratacao_detalhamento_1", 
                     "numero_contrato", "contrato_termo_aditivo_arquivos",
                     "codigo_orgao_entidade_contratante", 
                     "nome_orgao_entidade_contratante", "data_publicacao_contrato", 
                     "data_inicio_vigencia_contrato", "data_limite_vigencia_contrato", 
                     "data_termino_vigencia_contrato", "cnpj_cpf_fornecedor_formatado", 
                     "nome_empresarial_nome_fornecedor", "processo_sei", "url_processo_sei", "codigo_item_material_servico_numerico", 
                     "item_material_servico", "codigo_unidade_orcamentaria", 
                     "nome_unidade_orcamentaria", "descricao_linha_fornecimento", 
                     "cidade_entrega_item", "quantidade_homologada", "valor_unitario_referencia_item_processo", 
                     "valor_unitario_homologado_item_processo", "valor_total_referencia_item_processo", 
                     "valor_total_homologado")
  
  stopifnot(all(infer_spec == expected_cols))
  
  
  cols_spec <- c(
    NUMERO_PROCESSO_COMPRA = "text",
    URL_PORTAL_TRANSPARENCIA = "text",
    DATA_CADASTRAMENTO_PROCESSO = "date",
    OBJETO_PROCESSO = "text",
    URL_DOCUMENTOS_PROCESSO = "text",
    CODIGO_ORGAO_DEMANDANTE = "numeric",
    ORGAO_DEMANDANTE = "text",
    SITUACAO_PROCESSO = "text",
    PROCEDIMENTO_CONTRATACAO = "text",
    NUMERO_CONTRATO = "numeric",
    URL_INTEGRA_CONTRATO = "text",
    CODIGO_ORGAO_CONTRATO = "numeric",
    ORGAO_CONTRATO = "text",
    DATA_PUBLICACAO = "date",
    INICIO_VIGENCIA = "date",
    FIM_VIGENCIA = "date",
    FIM_VIGENCIA_ATUALIZADA = "date",
    CPF_CNPJ_CONTRATADO = "text",
    CONTRATADO = "text",
    PROCESSO_SEI = "text",
    URL_PROCESSO_SEI = "text",
    CODIGO_ITEM_MATERIAL_SERVICO = "numeric",
    ITEM_MATERIAL_SERVICO = "text",
    CODIGO_UNIDADE_ORCAMENTARIA = "numeric",
    UNIDADE_ORCAMENTARIA = "text",
    LINHA_FORNECIMENTO = "text",
    CIDADE_ENTREGA = "text",
    QUANTIDADE_HOMOLOGADA = "numeric",
    VALOR_REFERENCIA_UNITARIO = "numeric",
    VALOR_HOMOLOGADO_UNITARIO = "numeric",
    VALOR_REFERENCIA = "numeric",
    VALOR_HOMOLOGADO = "numeric")
  
  
  return <- readxl::read_excel(path, 
                               col_names = names(cols_spec),
                               col_types = cols_spec,
                               skip = 1)
  
  return
}

enrich <- function(df) {
  
  return <- df %>% 
    dplyr::mutate(
      PROCESSO_SEI = lookup_processo_sei(NUMERO_PROCESSO_COMPRA),
      URL_PROCESSO_SEI = lookup_link_sei(NUMERO_PROCESSO_COMPRA),  
      URL_PORTAL_TRANSPARENCIA = lookup_link_portal_transparencia(NUMERO_PROCESSO_COMPRA),
      URL_DOCUMENTOS_PROCESSO = create_documentos_processo(NUMERO_PROCESSO_COMPRA)
      )

  return
}


create_documentos_processo <- function(x) {
  
  url <- "https://www1.compras.mg.gov.br/processocompra/processo/consultaProcessoCompra.html?metodo=pesquisar&codigoUnidadeCompra={unidade}&numero={numero}&ano={ano}"
  
  unidade <- stringr::str_sub(x, 1, 7)
  numero <- stringr::str_sub(x, 9, 14) %>% as.numeric()
  ano <- stringr::str_sub(x, 16, 19)
  
  glue::glue(url)
}

lookup_link_portal_transparencia <- function(x) {
  table <- readr::read_csv2("data-raw/compras-coronavirus-controle.csv", col_types = c("ccnccccnc"), locale = readr::locale(decimal_mark = ",", grouping_mark = "."))
  
  lookup <- table %>% dplyr::pull(URL_PORTAL_TRANSPARENCIA)
  names(lookup) <- table %>% dplyr::pull(NUMERO_PROCESSO_COMPRA)
  
  lookup[x] %>% unname()
}

lookup_processo_sei <- function(x) {
  table <- readr::read_csv2("data-raw/compras-coronavirus-controle.csv", col_types = c("ccnccccnc"), locale = readr::locale(decimal_mark = ",", grouping_mark = "."))
  
  lookup <- table %>% dplyr::pull(PROCESSO_SEI)
  names(lookup) <- table %>% dplyr::pull(NUMERO_PROCESSO_COMPRA)
  
  lookup[x] %>% unname()
}

lookup_link_sei <- function(x) {
  table <- readr::read_csv2("data-raw/compras-coronavirus-controle.csv", col_types = c("ccnccccnc"), locale = readr::locale(decimal_mark = ",", grouping_mark = "."))
  
  lookup <- table %>% dplyr::pull(URL_PROCESSO_SEI)
  names(lookup) <- table %>% dplyr::pull(NUMERO_PROCESSO_COMPRA)
  
  lookup[x] %>% unname()
}

