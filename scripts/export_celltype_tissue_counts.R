library(tidyverse)
library(writexl)
library(magrittr)

FILE_IN="metadata/mca1_1.cell_annot.csv.gz"
FILE_OUT="metadata/counts_celltype_tissue_mca1_1.xlsx"
MIN_FRAC=0.1

df_annots <- read_csv(FILE_IN)

df_celltypes <- df_annots %>%
    dplyr::count(cluster, celltype_id, tissue, name="n_cells") %>%
    pivot_wider(id_cols=c("celltype_id", "cluster"), 
                names_from="tissue", 
                values_from="n_cells", values_fill=0)
    
mat_ct_tissue <- df_celltypes %>%
    mutate(cluster=NULL) %>%
    column_to_rownames("celltype_id") %>%
    as.matrix()

## compute top tissues per celltype
top_tissues <- mat_ct_tissue %>%
    ## normalize by row and test
    { (. / rowSums(.)) >= MIN_FRAC } %>%
    {
        ## detect tissues by celltype
        idxs_tissues <- apply(., 1, which)
        
        ## for each celltype
        names(idxs_tissues) %>%
            ## convert back to raw counts
            lapply(function (x) { mat_ct_tissue[x, idxs_tissues[[x]], drop=FALSE]}) %>%
            ## convert entries to named vectors
            lapply(function (x) { setNames(as.vector(x), dimnames(x)[[2]]) }) %>%
            ## sort by cells, then concat names
            sapply(function (x) { str_c(names(sort(x, decreasing=TRUE)), collapse=";") }) %>%
            ## reattach celltypes
            `names<-`(names(idxs_tissues))
    }

df_celltypes %>%
    ## attach top tissues
    mutate(tissues=top_tissues[celltype_id]) %>%
    ## sort tissues alphabetically
    select(order(colnames(.))) %>%
    ## put metadata first
    select(celltype_id, cluster, tissues, everything()) %>%
    ## write
    write_xlsx(FILE_OUT)


