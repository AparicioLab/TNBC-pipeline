# These commands must be specifed in order for this script to work
#source("http://www.bioconductor.org/biocLite.R"); source("http://www.bioconductor.org/biocLite.R"); biocLite("BSgenome"); biocLite("BSgenome.Hsapiens.UCSC.hg19"); library('BSgenome.Hsapiens.UCSC.hg19')

library('BSgenome.Hsapiens.UCSC.hg19')
biocLite("SNPlocs.Hsapiens.dbSNP.20120608")

getSeqHardMasked <-
  function(BSg,GR,maskList,letter) {
### PURPOSE: return list of DNAString sequences extracted from the
### BSgenome <BSg> corresponding to each location in GenomicRange
### <GR>, and masked with <letter> according to the masks named in
### <maskList> (which are encoded following BSParams convention).
###
### USE CASE - write fasta file of hard masked regions, using
###            RepeatMasker (RM) and Tandem Repeat Finder (TRF):
###
### GR <- GRanges('chr2L',IRanges(c(1,100),c(15,125)))
### writeFASTA(getSeqHardMasked(BSgenome, GR, c(RM=TRUE,TRF=TRUE), "N")
###            ,"myExtractForGR.fa"
###            ,paste(seqnames(GR),start(GR),end(GR),strand(GR),sep=':')
###            )
###
### NB: The implementation was coded 'pay(ing) attention to memory
### management' following suggestions from Herve in:
### https://stat.ethz.ch/pipermail/bioconductor/2011-March/038143.html.
### In particular, the inidividual chromosomes and their
### subseq(uences) should be garbage collectable after the function
### exits and they go out of scope, (although the chromosomes _are_
### all simultaneously loaded which I think is unavoidable if the
### results are to preserve the arbitrary order of GR).
###
### NB: My initial implementation FAILed as it used bsapply & BSParams
### whose FUN can not 'know' the name of the sequence (which was
### needed to know which subseqs to extract).
    ']]' <-
      ## utility to subscript b by a.
      function(a,b) b[[a]]
    Vsubseq <-
      ## vectorized version of subseq.
      Vectorize(subseq)
    VinjectHardMask <-
      ## vectorized version of injectHardMask.
      Vectorize(injectHardMask)
    activeMask <-
      ## A logical vector indicating whether each mask should be ON or
      ## OFF to be applied to each chromosome in BSg.
      masknames(BSg) %in% names(maskList[which(maskList)])
    BSg_seqList <-
      ## BSg as a list of named MaskedDNAString (one per chromosome)...
      sapply(seqnames(BSg),']]',BSg)
    BSg_seqList <-
      ## ... with the masks for each chromosome activated.
      sapply(BSg_seqList,function(x) {active(masks(x)) <- activeMask;x})
    GR_seq <-
      ## the MaskedDNAString corresponding to GR
      sapply(as.character(seqnames(GR)),']]',BSg_seqList)
    VinjectHardMask(Vsubseq(GR_seq,start(GR),end(GR)),letter=letter)
}


#################################################
# Directory structure - uncomment for first running of script
Project="TNBC"
homebase="/home/dyap/Projects"
setwd(homebase)
# system('mkdir TNBC')
setwd(paste(homebase,Project,sep="/"))
# system('mkdir primer3')
# system('mkdir positions')
# system('mkdir Annotate')
getwd()

#######################################
# Save input files under $homebase/positions#
#######################################

##############################################
######            User defined variables               ######
# Directory and file references
basedir=paste(homebase,Project,sep="/")
sourcedir=paste(basedir,"positions", sep="/")
# outdir=paste(basedir,"positions", sep="/")
p3dir=paste(basedir,"primer3", sep="/")
outpath=paste(basedir,"Annotate", sep="/")

######################
# These are the input files
#type="indel"
type="SNV"

file=paste(paste("primerIn-TNBC",type,sep="-"), "fix-List.txt",sep="-")

p3file=paste(type,"design.txt",sep="_")

annofile = paste(outpath, paste(type, "Annotate.csv", sep="_") ,sep="/")

outfile=paste(p3dir,p3file,sep="/")
input=paste(sourcedir,file,sep="/")

# offsets (sequences on either side of SNV,indel for design space)
offset=200
WToffset=5

# Select the appropriate Genome (mask) - for reference only
#BSg="Hsapiens" # normal-reference
#BSg="SNP_Hsapiens" # SNP-hard masked genome

##############################################

snvdf <- read.table(file=input,  stringsAsFactors = FALSE, header=TRUE)

# This is how the data is found in the dataset
table(snvdf$samp)

# defining the data frame with placeholder data
outdf <- data.frame(ID = rep("", nrow(snvdf)),
  Chr = rep("", nrow(snvdf)),
	Start = rep(0, nrow(snvdf)),
	End = rep(0, nrow(snvdf)),
	Ref = rep("", nrow(snvdf)),
	Context = rep("", nrow(snvdf)),
	Design = rep("", nrow(snvdf)),
	stringsAsFactors = FALSE)

#inject snps into the sequence
SnpHsapiens <- injectSNPs(Hsapiens, "SNPlocs.Hsapiens.dbSNP.20120608")
                     
     
# Note that the output up and downstream sequences will not contain the SNV nucleotide     

for (ri in seq(nrow(snvdf))) {

	id <- snvdf$ID[ri]
   chr <- paste("chr", snvdf$chr[ri], sep="")
#     chr <- snvdf$chr[ri]
  start <- as.numeric(snvdf$startPos[ri])
    end <- as.numeric(snvdf$endPos[ri])
  		
# 		WT <- paste(getSeq(Hsapiens,chr,position,position), sep='')
  		GR <- GRanges(chr,IRanges(start,end))
		tmp <- getSeqHardMasked(SnpHsapiens, GR, c(RM=TRUE,TRF=TRUE), "N")
		WT <- paste(tmp$chr,sep='')
		  		
#   		seqUp <- paste(getSeq(Hsapiens,chr,position-offset,position-1), sep='')
  		GR <- GRanges(chr,IRanges(start-offset,start-1))
		tmp <- getSeqHardMasked(SnpHsapiens, GR, c(RM=TRUE,TRF=TRUE), "N")
		seqUp <- paste(tmp$chr,sep='')

#              seqDown <- paste(getSeq(Hsapiens,chr,position+1,position+offset), sep='')
                GR <- GRanges(chr,IRanges(end+1,end+offset))
		tmp <- getSeqHardMasked(SnpHsapiens, GR, c(RM=TRUE,TRF=TRUE), "N")
		seqDown <- paste(tmp$chr,sep='')

# Design space is the seqUp,WT,seqDown
dseq=paste(seqUp, paste(WT,seqDown,sep=""), sep="")

 # If the index <5 or it is an SNV then we need 5 bp on either side to match (for visualization only)
   		
   if (nchar(WT) < 5) 
   		{
   		GR <- GRanges(chr,IRanges(start-WToffset,end+WToffset))
		tmp <- getSeqHardMasked(SnpHsapiens, GR, c(RM=TRUE,TRF=TRUE), "N")
		cxt <- paste(tmp$chr,sep='')
			}   else 	{
		 				cxt <- WT
 		                 }

  		  outdf$ID[ri] <- id          
      	  outdf$Chr[ri] <- chr
          outdf$Start[ri] <- start
          outdf$End[ri] <- end
          outdf$Ref[ri] <- WT
          outdf$Context[ri] <- cxt
          outdf$Design[ri] <- dseq
  
}	



write.csv(outdf, file = outfile)

