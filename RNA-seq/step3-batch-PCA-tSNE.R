## 
### ---------------
###
### Create: Jianming Zeng
### Date: nc18-12-29 23:24:48
### Email: jmzeng1314@163.com
### Blog: http://www.bio-info-trainee.com/
### Forum:  http://www.biotrainee.com/thread-1376-1-1.html
### CAFS/SUSTC/Eli Lilly/University of Macau
### Update Log: nc18-12-29  First version
###
### ---------------

rm(list = ls())  ## 魔幻操作，一键清空~
options(stringsAsFactors = F)
load(file = '../input.Rdata')
a[1:4,1:4]
head(df) 
## 载入第0步准备好的表达矩阵，及细胞的一些属性（hclust分群，plate批次，检测到的细胞数量）
# 注意 变量a是原始的counts矩阵，变量 dat是logCPM后的表达量矩阵。
group_list=df$g
plate=df$plate
table(plate)
## 这个时候需要从多个维度来探索两个不同的plate的单细胞群体是否有明显的差别。
# plate=group_list

## 最流行的细胞群体是否有明显的差别，肯定是hclust分群，热图展现，PCA,tSNE 等等

## 如果想了解PCA分析原理，需要阅读：https://mp.weixin.qq.com/s/Kw05PWD2m65TZu2Blhnl4w

if(F){
  set.seed(123456789)
  library(pheatmap)
  library(Rtsne)
  library(ggfortify)
  library(mvtnorm)
  
  ## 同样的正态分布随机表达矩阵，是无法区分开来。
  if(T){
    ng=500
    nc=20
    a1=rnorm(ng*nc);dim(a1)=c(ng,nc)
    a2=rnorm(ng*nc);dim(a2)=c(ng,nc) 
    a3=cbind(a1,a2)
    colnames(a3)=c(paste0('cell_01_',1:nc),paste0('cell_02_',1:nc))
    rownames(a3)=paste('gene_',1:ng,sep = '')
    pheatmap(a3)
    a3=t(a3);dim(a3) ## PCA分析，需要把细胞放在列，基因放在行。
    pca_dat <- prcomp(a3, scale. = TRUE)
    p=autoplot(pca_dat) + theme_classic() + ggtitle('PCA plot')
    print(p)
    # 可以看到细胞无法被区分开来。
    set.seed(42)
    tsne_out <- Rtsne(a3,pca=FALSE,perplexity=10,theta=0.0) # Run TSNE
    tsnes=tsne_out$Y
    colnames(tsnes) <- c("tSNE1", "tSNE2")
    ggplot(tsnes, aes(x = tSNE1, y = tSNE2))+ geom_point()
  }
  
  ## 同样的正态分布随机表达矩阵，但是其中部分细胞+3，可以区分开来。
  if(T){
    ng=500
    nc=20
    a1=rnorm(ng*nc);dim(a1)=c(ng,nc)
    a2=rnorm(ng*nc)+3;dim(a2)=c(ng,nc) 
    a3=cbind(a1,a2)
    colnames(a3)=c(paste0('cell_01_',1:nc),paste0('cell_02_',1:nc))
    rownames(a3)=paste('gene_',1:ng,sep = '')
    pheatmap(a3)
    a3=t(a3);dim(a3) ## PCA分析，需要把细胞放在列，基因放在行。
    
    pca_dat <- prcomp(a3, scale. = TRUE)
    p=autoplot(pca_dat) + theme_classic() + ggtitle('PCA plot')
    print(p)
    # 这个时候细胞被区分开，而且是很明显的一个主成分。
    
    set.seed(42)
    tsne_out <- Rtsne(a3,pca=FALSE,perplexity=10,theta=0.0) # Run TSNE
    tsnes=tsne_out$Y
    colnames(tsnes) <- c("tSNE1", "tSNE2")
    ggplot(tsnes, aes(x = tSNE1, y = tSNE2))+ geom_point()
  }
  
  ## 不同的正态分布随机表达矩阵，可以区分。
  if(T){
    ng=600
    nc=200
    mu1  = rnorm(ng, mean = 1)
    mu2  = rnorm(ng, mean = 5)
    a1=rmvnorm(nc,mu1);dim(a1)
    a2=rmvnorm(nc,mu2) ;dim(a2)
    
    a3=rbind(a1,a2);dim(a3)
    rownames(a3)=c(paste0('cell_01_',1:nc),paste0('cell_02_',1:nc))
    colnames(a3)=paste('gene_',1:ng,sep = '')
    pheatmap(a3)
    pca_dat <- prcomp(a3, scale. = TRUE)
    p=autoplot(pca_dat) + theme_classic() + ggtitle('PCA plot')
    print(p)
    set.seed(42)
    tsne_out <- Rtsne(a3,pca=FALSE,perplexity=30,theta=0.0) # Run TSNE
    tsnes=tsne_out$Y
    colnames(tsnes) <- c("tSNE1", "tSNE2")
    ggplot(tsnes, aes(x = tSNE1, y = tSNE2))+ geom_point()
  }
  
  
}

## 下面是画PCA的必须操作，需要看不同做PCA的包的说明书。
dat_back=dat

dat=dat_back
dat=t(dat)
dat=as.data.frame(dat)
dat=cbind(dat,plate )
dat[1:4,1:4]
table(dat$plate)

# 'princomp' can only be used with more units than variables
# Principal component analysis is underspecified if you have fewer samples than data point. 
# pca_dat =  princomp(t(dat[,-ncol(dat)]))$scores[,1:2]
pca_dat =  prcomp(t(dat[,-ncol(dat)])) 
plot(pca_dat$rotation[,1:2], t='n')
colors = rainbow(length(unique(dat$plate)))
names(colors) = unique(dat$plate)
text(pca_dat$rotation[ , 1:2], labels=dat$plate,col=colors[dat$plate])



library("FactoMineR")
library("factoextra") 
# The variable plate (index = ) is removed
# before PCA analysis
dat.pca <- PCA(dat[,-ncol(dat)], graph = FALSE)
fviz_pca_ind(dat.pca,repel =T,
             geom.ind = "point", # show points only (nbut not "text")
             col.ind = df$g, # color by groups
             #palette = c("#00AFBB", "#E7B800"),
             addEllipses = TRUE, # Concentration ellipses
             legend.title = "Groups"
)
## 事实上还是有很多基因dropout非常严重。
ggsave('all_cells_PCA_by_plate.png')

library(Rtsne) 
dat_matrix <- as.matrix(dat[,-ncol(dat)])
dat_matrix[1:4,1:4]
# Set a seed if you want reproducible results
set.seed(42)
tsne_out <- Rtsne(dat_matrix,pca=FALSE,perplexity=30,theta=0.0) # Run TSNE

# Show the objects in the 2D tsne representation
plot(tsne_out$Y,col=dat$plate, asp=1)
# https://distill.pub/nc16/misread-tsne/

library(ggpubr)
# Add marginal rug
head(tsne_out$Y)
df=as.data.frame(tsne_out$Y)
colnames(df)=c("X",'Y')
df$plate=dat$plate
head(df)
df$g=group_list
ggscatter(df, x = "X", y = "Y", color = "g" 
          # palette = c("#00AFBB", "#E7B800" ) 
          )


if(F){
  library(tsne)
  ## Not run:
  colors = rainbow(length(unique(iris$Species)))
  names(colors) = unique(iris$Species)
  ecb = function(x,y){ plot(x,t='n'); text(x,labels=iris$Species, col=colors[iris$Species]) }
  tsne_iris = tsne(iris[,1:4], epoch_callback = ecb, perplexity=ng)
  head(iris[,1:4])
  
  library(Rtsne)
  iris_unique <- unique(iris) # Remove duplicates
  iris_matrix <- as.matrix(iris_unique[,1:4])
  
  # Set a seed if you want reproducible results
  set.seed(42)
  tsne_out <- Rtsne(iris_matrix,pca=FALSE,perplexity=30,theta=0.0) # Run TSNE
  
  # Show the objects in the 2D tsne representation
  plot(tsne_out$Y,col=iris_unique$Species, asp=1)
  
  
}


