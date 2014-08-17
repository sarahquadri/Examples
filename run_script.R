setwd("~/datathon/")

net_data <- fread("data/input/nb_adj2.csv", sep="|")
net_data <- net_data[net_data$source != "Downtown" & net_data$sink != "Downtown",]
net_data <- net_data[net_data$sink != net_data$source]

hoods_to_use <- unique(c(net_data$source,net_data$sink))


census_block_data <- fread("data/input/census_data.csv", sep="|")
census_block_data$pop_female_pct <- NULL
census_block_data$pop_male_pct <- NULL
census_block_data$pop_white_not_hisp_pct <- NULL
census_block_data$pop_of_color_pct <- NULL
census_block_data$pop_hs_not_comp_pct <- NULL
census_block_data$pop_hs_diploma_pct <- NULL
census_block_data$pop_assoc_some_coll_pct <- NULL
census_block_data$pop_coll_degree_pct <- NULL
census_block_data$pop_grad_degree_pct <- NULL
census_block_data$placetype_id <- NULL
census_block_data$urban_ldc <- NULL
census_block_data$compact_ldc<- NULL
census_block_data$county <- NULL
census_block_data$id_grid <- NULL
census_block_data$hh1 <- NULL
census_block_data$hh2 <- NULL
census_block_data$hh3 <- NULL
census_block_data$hh4 <- NULL
census_block_data$hh5 <- NULL

agg_census_data <- census_block_data[,
                      lapply(.SD[,2:ncol(.SD),with=F],
                            function(t){as.double( median(t,na.rm=T))}),
                      by=neighborho]

agg_census_data <- agg_census_data[agg_census_data$neighborho %in% hoods_to_use,]

not_has_na <- apply(agg_census_data,2, function(t){sum(is.na(t)) == 0})
agg_census_data <- agg_census_data[,names(not_has_na[not_has_na]),with=F]

library(huge)

h <- huge(as.matrix(agg_census_data[,2:ncol(agg_census_data),with=F]))
g <- graph.adjacency(h$path[[2]])
V(g)$name <- colnames(h$data)
write.csv(get.edgelist(g), "data/output/variable_edges.csv",row.names=F)


g <- graph.data.frame(net_data)
write.csv(get.edgelist(g),"data/output/neighb_net.csv",row.names=F)

agg_census_data$log_hh_avg_inc <- log(agg_census_data$hh_avg_inc)
write.csv(agg_census_data[,c("neighborho","hh_avg_inc"),with=F],"data/output/hh_inc.csv",row.names=F)


##run python file gen_income_disparity.py
##sorry...time...

income_disp <- read.csv("data/output/income_disparity.csv")