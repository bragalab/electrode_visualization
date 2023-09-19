#################################################################
#For arranging png files created by elec_zoomer_######.sh onto a
#multi page pdf document. To be used within the elec_master.sh script
#
#Usage: Rscript elec_combiner_210903.R ATHUAT
# Must be run on R/4.0.3
# Made by Chris Cyr, Braga Lab, September 2021
################################################################
# load libraries
setwd('~')
if(!require("qpdf")) {install.packages(c("staplr")); require("qpdf")}
if (!require("gridExtra")) {install.packages(c("gridExtra")); require("gridExtra")}
if (!require("gtable")) {install.packages(c("gtable")); require("gtable")} 
if (!require("grid")) {install.packages(c("grid")); require("grid")} 
if (!require("png")) {install.packages(c("png")); require("png")}
if (!require("jpeg")) {install.packages(c("jpeg")); require("jpeg")}
if (!require("ggplot2")) {install.packages(c("ggplot2")); require("ggplot2")}
if (!require("stringr")) {install.packages(c("stringr")); require("stringr")}
if (!require("EBImage")) {BiocManager::install(c("EBImage")); require ("EBImage")}
if (!require("OpenImageR")) {install.packages(c("OpenImageR")); require("OpenImageR")}
options(EBImage.display = "raster")

SubjectID <- toString(commandArgs(trailingOnly=TRUE))

ELVISpath <- paste('/projects/b1134/processed/fs/', SubjectID, '/', SubjectID, '/elec_recon/PICS/', sep = '')
CSVpath <- paste('/projects/b1134/processed/fs/', SubjectID, '/', SubjectID, '/elec_recon/', sep = '')
subjectpath <- paste('/projects/b1134/processed/elec_zoom/', SubjectID, sep = "")
pngpath <- paste(subjectpath, 'pngs', sep = '/')

blank <- grid.rect(gp=gpar(fill="white", lwd = 0, col = "white"))
imagelabel <- textGrob(paste('Sagittal  ', '  Axial', '   Coronal', sep = "   "), 
x = 0.1, just ='center', gp=gpar(fontsize=8), rot = 270)

#find channel labels file (only contains iEEG channels)
infofile <- paste('/projects/b1134/processed/fs/', SubjectID, '/', SubjectID, '/elec_recon/brainmask_coords_0_wlabels.txt',sep = '')

#load file
electrodeinfo <- read.delim(infofile, header = FALSE, sep = '\n')

channel <- 1 #channel number
pdfcounter <- 1 #page number
filelist <- list()

#create front page of document with all electrode whole brain images, one page for each hemisphere

headertext <- textGrob(paste("Electrode Localization Report:", SubjectID,  sep = '   '),
                       x = 0.0, just ='left', gp=gpar(fontsize=14, fontface='bold'))

infotable <- read.csv(paste(CSVpath, 'electrodeinfotable.csv', sep = ''))
infotable <- tableGrob(infotable, rows = NULL, theme = ttheme_default())
infotable  <- gtable_add_grob(infotable, grobs=rectGrob(gp=gpar(fill=NA, lwd = 1)),
                               t = 2, b = nrow(infotable), l = 1, r = ncol(infotable))

ELVIS_all_Rimg_path <- paste(ELVISpath, '/', SubjectID, 'RightMgridElec.jpg'  , sep='')
if (file.exists(ELVIS_all_Rimg_path)){
  ELVIS_all_Rimg <- rasterGrob(readJPEG(ELVIS_all_Rimg_path))
} else {
  ELVIS_all_Rimg <- blank
}
ELVIS_all_Limg_path <- paste(ELVISpath, '/', SubjectID, 'LeftMgridElec.jpg'  , sep='')
if (file.exists(ELVIS_all_Limg_path)){
  ELVIS_all_Limg <- rasterGrob(readJPEG(ELVIS_all_Limg_path))
} else {
  ELVIS_all_Limg <- blank
}

setwd(subjectpath)

#Left Hemisphere Front Page
filename <- paste( 'tmp', pdfcounter, '.pdf', sep = '')
pdf(filename, height = 11, width = 8.5, onefile = T)
pdf <- grid.arrange(arrangeGrob(blank, nrow = 1),
                    arrangeGrob(blank, headertext, nrow = 1, widths = c(0.5, 8)),
                    arrangeGrob(blank, infotable, nrow = 1, widths = c(0.5, 8)),
                    arrangeGrob(blank, ELVIS_all_Limg,blank, nrow = 1, widths = c(0.5, 7.5, 0.5)),
                    nrow = 4, heights = c(0.5, 0.5, 4.75, 5.25))  

dev.off()
filelist[[pdfcounter]] <- filename
pdfcounter <- pdfcounter + 1 

#Right Hemisphere Front Page
filename <- paste( 'tmp', pdfcounter, '.pdf', sep = '')
pdf(filename, height = 11, width = 8.5, onefile = T)
pdf <- grid.arrange(arrangeGrob(blank, nrow = 1),
                    arrangeGrob(blank, headertext, nrow = 1, widths = c(0.5, 8)),
                    arrangeGrob(blank, infotable, nrow = 1, widths = c(0.5, 8)),
                    arrangeGrob(blank, ELVIS_all_Rimg,blank, nrow = 1, widths = c(0.5, 7.5, 0.5)),
                    nrow = 4, heights = c(0.5, 0.5, 4.75, 5.25))  

dev.off()
filelist[[pdfcounter]] <- filename
pdfcounter <- pdfcounter + 1

#create pages for each electrode shaft/grid/strip
while (!is.na(electrodeinfo[channel,1])) #go through electrode info file line by line until end
{
  setwd(pngpath)

#load page header (text + iELVis images) at the beginning of each shaft
  shaftID <- substr(unlist(str_split(electrodeinfo[channel,1],' '))[1], 
                    start = 1, stop = tail(unlist(gregexpr(pattern = "[[:alpha:]]", unlist(str_split(electrodeinfo[channel,1],' '))[1],' ')), n=1))
  nextshaftID <- shaftID
  
  headertext <- textGrob(paste("Electrode Localization Report:", SubjectID, "       Electrode:", shaftID, sep = '   '),
                          x = 0.0, just ='left', gp=gpar(fontsize=14, fontface='bold'))
  
  ELVIS_l_img <- rasterGrob(readPNG(paste(ELVISpath, SubjectID, '_WBview_', shaftID, '_lateral.png' , sep='')))
  ELVIS_m_img <- rasterGrob(readPNG(paste(ELVISpath, SubjectID, '_WBview_', shaftID, '_medial.png' , sep='')))
  ELVIS_f_img <- rasterGrob(readPNG(paste(ELVISpath, SubjectID, '_WBview_', shaftID, '_frontal.png' , sep='')))
  ELVIS_o_img <- rasterGrob(readPNG(paste(ELVISpath, SubjectID, '_WBview_', shaftID, '_occipital.png' , sep='')))

  electrodeID <- list()
  T1_ax_img <- list()
  T1_zoom_sag_img <- list()
  T1_zoom_ax_img <- list()
  T1_zoom_cor_img <- list()
  i <- 1
  #while looping through electrodes and on same on the shaft, and you have 15 or less electrodes so far, create a 1 page pdf
  while  (shaftID == nextshaftID & i < 16)
  { 
    electrodeID[[i]] <- strsplit(electrodeinfo[channel,1], ' ')[[1]][1]
    shaftID <- substr(unlist(str_split(electrodeinfo[channel,1],' '))[1], 
                      start = 1, stop = tail(unlist(gregexpr(pattern = "[[:alpha:]]", unlist(str_split(electrodeinfo[channel,1],' '))[1],' ')), n=1))
    nextshaftID <- substr(unlist(str_split(electrodeinfo[channel+1,1],' '))[1], 
                          start = 1, stop = tail(unlist(gregexpr(pattern = "[[:alpha:]]", unlist(str_split(electrodeinfo[channel+1,1],' '))[1],' ')), n=1))
    if (is.na(nextshaftID)){
      nextshaftID <-''
    }
    
    #load whole brain axial T1 image and add text
    T1_ax_file <- paste(electrodeID[[i]], '_T1_sphere_combined_WBaxial.png', sep = '')
    T1_ax_file_new <- paste(electrodeID[[i]], '_T1_sphere_combined_WBaxial_text.png', sep = '')
    img = EBImage::readImage(T1_ax_file)
    png(filename = T1_ax_file_new)
    display(img)
    text( x = 10, y = 10, label = electrodeID[[i]], adj = c(0,1), col = 'white', cex = 5)
    dev.off()  
    
    #downsize Whole Brain image
    newimg = EBImage::readImage(T1_ax_file_new)
    newimg <- resize(newimg, w = dim(img)[1]/2, h = dim(img)[2]/2)
    EBImage::writeImage(newimg, T1_ax_file_new)
    T1_ax_img[[i]] <- readPNG(T1_ax_file_new)
    
    #load zoomed in sagittal, axial, and coronal T1 images
    T1_zoom_sag_file <- paste(electrodeID[[i]], '_T1_sphere_combined_sag.png', sep = '')
    T1_zoom_sag_img[[i]] <- rotateFixed(readPNG(T1_zoom_sag_file), 90)
    T1_zoom_ax_file <- paste(electrodeID[[i]], '_T1_sphere_combined_ax.png', sep = '')
    T1_zoom_ax_img[[i]] <- readPNG(T1_zoom_ax_file)
    T1_zoom_cor_file <- paste(electrodeID[[i]], '_T1_sphere_combined_cor.png', sep = '')
    T1_zoom_cor_img[[i]] <- flipImage(rotateFixed(readPNG(T1_zoom_cor_file), 180), mode = 'horizontal')    
    i <- i + 1
    channel <- channel + 1
  }
  
  #if shaft has less than 15 contacts, fill the rest of the data structures with blanks for plotting purposes
  while (length(electrodeID) < 16){
    electrodeID[[i]] <- ' '
    T1_ax_img[[i]] <- 1
    T1_zoom_sag_img[[i]] <- 1
    T1_zoom_ax_img[[i]] <- 1
    T1_zoom_cor_img[[i]] <- 1
    i <- i + 1
  }
  
  setwd(subjectpath)
  filename <- paste( 'tmp', pdfcounter, '.pdf', sep = '')

  #place all images and info from data structures onto pdfs
  pdf(filename, height = 11, width = 8.5, onefile = T)
  pdf <- grid.arrange(arrangeGrob(blank, nrow = 1),
                      arrangeGrob(blank, headertext, nrow = 1, widths = c(0.5, 8)),
                      arrangeGrob(blank,
                                  ELVIS_l_img,
                                  ELVIS_f_img,
                                  ELVIS_m_img,
                                  ELVIS_o_img,
                                  blank,
                                  nrow = 1, widths = c(0.025, 2.6, 1.5, 2.6, 1.25, 0.025)),
                      arrangeGrob(blank,
                                  rasterGrob(T1_ax_img[[15]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[15]]), rasterGrob(T1_zoom_ax_img[[15]]), rasterGrob(T1_zoom_cor_img[[15]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[10]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[10]]), rasterGrob(T1_zoom_ax_img[[10]]), rasterGrob(T1_zoom_cor_img[[10]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[5]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[5]]), rasterGrob(T1_zoom_ax_img[[5]]), rasterGrob(T1_zoom_cor_img[[5]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  nrow = 1, widths = c(0.5, 1.6, .525, 0.5625, 1.6, .525, .5625, 1.6, .525, 0.5)),
                      arrangeGrob(blank, nrow = 1),
                      arrangeGrob(blank,
                                  rasterGrob(T1_ax_img[[14]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[14]]), rasterGrob(T1_zoom_ax_img[[14]]), rasterGrob(T1_zoom_cor_img[[14]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[9]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[9]]), rasterGrob(T1_zoom_ax_img[[9]]), rasterGrob(T1_zoom_cor_img[[9]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[4]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[4]]), rasterGrob(T1_zoom_ax_img[[4]]), rasterGrob(T1_zoom_cor_img[[4]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  nrow = 1, widths = c(0.5, 1.6, .525, 0.5625, 1.6, .525, .5625, 1.6, .525, 0.5)),
                      arrangeGrob(blank, nrow = 1),
                      arrangeGrob(blank,
                                  rasterGrob(T1_ax_img[[13]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[13]]), rasterGrob(T1_zoom_ax_img[[13]]), rasterGrob(T1_zoom_cor_img[[13]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[8]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[8]]), rasterGrob(T1_zoom_ax_img[[8]]), rasterGrob(T1_zoom_cor_img[[8]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[3]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[3]]), rasterGrob(T1_zoom_ax_img[[3]]), rasterGrob(T1_zoom_cor_img[[3]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  nrow = 1, widths = c(0.5, 1.6, .525, 0.5625, 1.6, .525, .5625, 1.6, .525, 0.5)),
                      arrangeGrob(blank, nrow = 1),
                      arrangeGrob(blank,
                                  rasterGrob(T1_ax_img[[12]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[12]]), rasterGrob(T1_zoom_ax_img[[12]]), rasterGrob(T1_zoom_cor_img[[12]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[7]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[7]]), rasterGrob(T1_zoom_ax_img[[7]]), rasterGrob(T1_zoom_cor_img[[7]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[2]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[2]]), rasterGrob(T1_zoom_ax_img[[2]]), rasterGrob(T1_zoom_cor_img[[2]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  nrow = 1, widths = c(0.5, 1.6, .525, 0.5625, 1.6, .525, .5625, 1.6, .525, 0.5)),
                      arrangeGrob(blank, nrow = 1),
                      arrangeGrob(blank,
                                  rasterGrob(T1_ax_img[[11]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[11]]), rasterGrob(T1_zoom_ax_img[[11]]), rasterGrob(T1_zoom_cor_img[[11]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[6]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[6]]), rasterGrob(T1_zoom_ax_img[[6]]), rasterGrob(T1_zoom_cor_img[[6]]), ncol = 1, heights = c(1,1,1)),
                                  blank,
                                  rasterGrob(T1_ax_img[[1]]),
                                  arrangeGrob(rasterGrob(T1_zoom_sag_img[[1]]), rasterGrob(T1_zoom_ax_img[[1]]), rasterGrob(T1_zoom_cor_img[[1]]), ncol = 1, heights = c(1,1,1)),
                                  imagelabel,
                                  nrow = 1, widths = c(0.5, 1.6, .525, 0.5625, 1.6, .525, .5625, 1.6, .525, 0.5)),
                      arrangeGrob(blank, nrow = 1),
                      nrow = 13, heights = c(0.5, 0.25, 1.75, 1.65, 0.05, 1.65, 0.05, 1.65, 0.05, 1.65, 0.05, 1.65, 0.5))  


  dev.off()
  filelist[[pdfcounter]] <- filename
  pdfcounter <- pdfcounter + 1
  
}

#combine temporary pdf files, but only ones that aren't blank
savelist <- list()
file_counter <- 1

for(i in 1:length(filelist)){
  currentfile <- paste('tmp', i, '.pdf', sep='')
  if (file.info(currentfile)$size > 10000){
    savelist[[file_counter]] <- currentfile
    file_counter <- file_counter + 1
  }
}  
outfile <- paste(subjectpath, '/', SubjectID, '_elec_zoom_surg1.pdf', sep='')
pdf_combine(savelist,
            outfile, password = "")
#remove temporary files
for (i in 1:length(filelist))
{
  file.remove(filelist[[i]])
}
#unlink(paste(subjectpath, '/', 'niftis', sep=''), recursive = TRUE)
#unlink(paste(subjectpath, '/', 'pngs', sep=''), recursive = TRUE)



