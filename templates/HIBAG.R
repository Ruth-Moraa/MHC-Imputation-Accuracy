#!/opt/conda/bin/Rscript
###############################################################################

# Load the HIBAG library
library("HIBAG")

model.objA <- get(load("${model_a}"))
model.objB <- get(load("${model_b}"))
model.objC <- get(load("${model_c}"))

model.a <- hlaModelFromObj(model.objA)
model.b <- hlaModelFromObj(model.objB)
model.c <- hlaModelFromObj(model.objC)


#Import a test data file and predict its hla types
# import a PLINK BED file
bed.fn <- ("${bed}")
fam.fn <- ("${fam}")
bim.fn <- ("${bim}")
test.geno <- hlaBED2Geno(bed.fn, fam.fn, bim.fn, assembly="hg18")

# Calculate allele frequencies
afreq = hlaGenoAFreq(test.geno)
summary(afreq)
write.table(afreq, file="${allele_out}_allelefreq", quote = F,col.names = F, row.names = F)
sink()

# Predict HLA alleles
A.guess <- predict(model.a, test.geno, type="response+prob", match.type="Position")
B.guess <- predict(model.b, test.geno, type="response+prob", match.type="Position")
C.guess <- predict(model.c, test.geno, type="response+prob", match.type="Position")


# Output results
output.table = data.frame(SampleID=A.guess\$value\$sample.id, A_allele1=A.guess\$value\$allele1, A_allele2=A.guess\$value\$allele2, A_prob=A.guess\$value\$prob,
               B_allele1=B.guess\$value\$allele1, B_allele2=B.guess\$value\$allele2, B_prob=B.guess\$value\$prob,
               C_allele1=C.guess\$value\$allele1, C_allele2=C.guess\$value\$allele2, C_prob=C.guess\$value\$prob)

output.file = paste("${hibag_out}_HIBAG_HLA.txt",sep="")
write.table(output.table, output.file, row.names=F, sep="\t", quote=F)


##LOAD TRUE HLA TYPES
HLA_Type_Table <- read.table(file="${ans_file}")


# HLA-A
##Convert the HLA type table fields to a vector
HLA_Type_Table\$sample.id <- as.vector(HLA_Type_Table\$sample.id)
HLA_Type_Table\$A.1 <- as.vector(HLA_Type_Table\$A.1)     
HLA_Type_Table\$A.2 <- as.vector(HLA_Type_Table\$A.2)

hlaA.id <- "A"
HLA_A <- hlaAllele(HLA_Type_Table\$sample.id,
                       H1 = HLA_Type_Table[, paste(hlaA.id, ".1", sep="")],
                       H2 = HLA_Type_Table[, paste(hlaA.id, ".2", sep="")],
                       locus=hlaA.id, assembly="hg18")

#Compare the predicted HLA allele to the original validation population
comp <- hlaCompareAllele(HLA_A, A.guess, allele.limit=model.a,
                        call.threshold=0)
comp\$overall

#REPORT OVERALL ACCURACY, PER ALLELE SENSITIVITY & SPECIFICITY

hlaReport(comp, export.fn="${hibag_out}_HLA_A_accuracy.html", type="html", header=TRUE)



# HLA-B 
##Convert the HLA type table fields to a vector
HLA_Type_Table\$sample.id <- as.vector(HLA_Type_Table\$sample.id)
HLA_Type_Table\$B.1 <- as.vector(HLA_Type_Table\$B.1)
HLA_Type_Table\$B.2 <- as.vector(HLA_Type_Table\$B.2)

hlaB.id <- "B"
HLA_B <- hlaAllele(HLA_Type_Table\$sample.id,
                         H1 = HLA_Type_Table[, paste(hlaB.id, ".1", sep="")],
                         H2 = HLA_Type_Table[, paste(hlaB.id, ".2", sep="")],
                         locus=hlaB.id, assembly="hg18")

#Compare the predicted HLA allele to the original validation population
comp <- hlaCompareAllele(HLA_B, B.guess, allele.limit=model.b,
                        call.threshold=0)
comp\$overall

#REPORT OVERALL ACCURACY, PER ALLELE SENSITIVITY & SPECIFICITY

hlaReport(comp, export.fn="${hibag_out}_HLA_B_accuracy.html", type="html", header=TRUE)


# HLA-C
##Convert the HLA type table fields to a vector
HLA_Type_Table\$sample.id <- as.vector(HLA_Type_Table\$sample.id)
HLA_Type_Table\$C.1 <- as.vector(HLA_Type_Table\$C.1)
HLA_Type_Table\$C.2 <- as.vector(HLA_Type_Table\$C.2)

hlaC.id <- "C"
HLA_C <- hlaAllele(HLA_Type_Table\$sample.id,
                         H1 = HLA_Type_Table[, paste(hlaC.id, ".1", sep="")],
                         H2 = HLA_Type_Table[, paste(hlaC.id, ".2", sep="")],
                         locus=hlaC.id, assembly="hg18")

#Compare the predicted HLA allele to the original validation population
comp <- hlaCompareAllele(HLA_C, C.guess, allele.limit=model.c,
                        call.threshold=0)
comp\$overall

#REPORT OVERALL ACCURACY, PER ALLELE SENSITIVITY & SPECIFICITY

hlaReport(comp, export.fn="${hibag_out}_HLA_C_accuracy.html", type="html", header=TRUE)