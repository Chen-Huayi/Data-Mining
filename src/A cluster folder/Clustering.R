install.packages("factoextra")

path=getwd()
customerCluster=read.csv(paste0(path,"/customer.csv"))
library(factoextra)
customerCluster=customerCluster[-4]
customerCluster=customerCluster[-1]
df=scale(customerCluster)
k=kmeans(df, centers = 5, nstart = 20)
fviz_cluster(k, data = df)

k$centers
k$size
