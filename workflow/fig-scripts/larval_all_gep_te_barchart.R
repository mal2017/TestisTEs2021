library(tidyverse)
library(arrow)
library(ragg)
library(jsonlite)

source("workflow/fig-scripts/theme.R")

optimal_ica <- read_json('results/finalized/optimal-gep-params/larval-w1118-testes.json') %>% unlist()

w1118.gep_membership <- open_dataset("results/finalized/larval-w1118-testes/optimal_gep_membership", format='arrow')

te.lookup <- read_tsv('resources/te_id_lookup.curated.tsv.txt')


df <- w1118.gep_membership %>%
  filter(qval < optimal_ica[['qval']]) %>%
  collect() %>%
  left_join(te.lookup, by=c(X1='merged_te')) %>%
  filter(!str_detect(X1,'FBgn')) %>%
  dplyr::select(module, X1, repClass, repFamily) %>%
  distinct() %>%
  group_by(module) %>%
  mutate(n_tes=n()) %>%
  filter(n_tes > 1) %>%
  mutate(repClass=replace_na(repClass,replace = 'other')) #%>%
  #mutate(module=paste0("GEP-",module))


g <-  ggplot(df, aes(reorder(module, n_tes), fill=repClass)) +
  geom_bar(position='stack') +
  scale_fill_brewer(type='qual',palette=6, name="TE class") +
  theme_gte21() +
  xlab("") + ylab('N')


df %>% group_by(module, repClass) %>%
  summarise(count=n()) %>%
  group_by(module) %>%
  mutate(pct = count/sum(count)) %>%
  filter(module==27)


agg_png(snakemake@output[['png']], width=10, height =10, units = 'in', scaling = 1.5, bitsize = 16, res = 300, background = 'transparent')
print(g)
dev.off()

saveRDS(g,snakemake@output[['ggp']])
write_tsv(df,snakemake@output[['dat']])
