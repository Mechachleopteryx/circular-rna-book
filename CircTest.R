#!/usr/bin/env Rscript

require(devtools)
library(CircTest)
CircRNACount <- read.delim('CircRNACount',header=T)
LinearCount <- read.delim('LinearCount',header=T)
CircCoordinates <- read.delim('CircCoordinates',header=T)
CircSkip<-read.delim("CircSkipJunctions",header=T)

idx<-grep("_[MNOPQRST]_",colnames(CircRNACount))
idx<-c(1:3,idx)

CircRNACount <- CircRNACount[,idx]
LinearCount <- LinearCount[,idx]
CircSkip<-CircSkip[,idx]

CircRNACount_filtered <- Circ.filter(circ = CircRNACount, linear = LinearCount, Nreplicates = 4, filter.sample = 3, filter.count = 2, percentage = 0.01)
CircCoordinates_filtered <- CircCoordinates[rownames(CircRNACount_filtered),]
LinearCount_filtered <- LinearCount[rownames(CircRNACount_filtered),]

# create a PDF file with top 10 significant circles
pdf("Significant_circle_changes.pdf")
for (i in rownames(test$summary_table)[1:10])  {
 Circ.ratioplot( CircRNACount_filtered, LinearCount_filtered, CircCoordinates_filtered, plotrow=i,
                 groupindicator1=rep(c("RNAseR-","RNAseR+"),4),
                 lab_legend='Conditions' )
}
dev.off();

# Significant result show in a summary table
require(openxlsx)

wb <- createWorkbook()
addWorksheet(wb, sheetName = "Significant circles");
writeDataTable(wb, sheet = 1, x=test$summary_table[1:100,]);

idx<-rownames(test$summary_table[1:100,]);

addWorksheet(wb, sheetName = "Circle Counts");
writeDataTable(wb, sheet = 2, x=CircRNACount[idx,]);

addWorksheet(wb, sheetName = "Linear Counts");
writeDataTable(wb, sheet = 3, x=LinearCount[idx,]);

addWorksheet(wb, sheetName = "CircleSkips");
writeDataTable(wb, sheet = 4, x=CircSkip[idx,]);

saveWorkbook(wb, "Circular_RNA_analysis_DCC.xlsx", overwrite = TRUE)
