path=getwd()
Online_Retail=read.csv(paste0(path,"/Online_Retail.csv"))
options(max.print=100000000)
#5%
findFreqItem=function(cIndex){
  CID=Customers[cIndex]
  freqItems=c()
  x=which(Online_Retail[, "CustomerID"]==CID)
  if(length(x)!=0){
    allGoods=Online_Retail[x, 'Description']
    dataFrame=table(allGoods)
    name=names(dataFrame)
    freq=as.numeric(dataFrame)
    uniqueGoods=unique(allGoods)
    for (index in 1:length(uniqueGoods)){
      if(freq[index]/length(x)>=0.05){
        freqItems=append(freqItems, name[index])
      }
    }
    return(freqItems)
  }
}
isSequent=function(s1, s2){
  isInside=FALSE
  j=1
  for (i in 1:length(s1))
    if(j<=length(s2))
      if(s1[i]==s2[j])
        j=j+1
  if(j==length(s2)+1)
    isInside=TRUE
  return(isInside)
}
prunedByFrequency=function(L, C, size){
  for (i in length(C):1) {
    section=unlist(strsplit(C[i], ' '))
    subset=paste(section[1], section[size])
    isFrequent=FALSE
    for (j in 1:length(L)) {
      seq1=as.numeric(unlist(strsplit(L[j], ' ')))
      seq2=as.numeric(unlist(strsplit(subset, ' ')))
      if(isSequent(seq1, seq2)){
        isFrequent=TRUE
      }
    }
    if(isFrequent==FALSE){
      C=C[-i]
    }
  }
  return(C)
}
prunedByMinsup=function(L, C, minsup=5){
  for (seqIndex in 1:length(C)) {
    sup=0
    list2=unlist(strsplit(C[seqIndex], ' '))
    for (i in 1:length(Customers)) {
      if(allFreqSeq[i]!=' NA '){
        list1=unlist(strsplit(allFreqSeq[i], ' '))
        if(isSequent(list1, list2)){
          sup=sup+1
        }
      }
    }
    if(sup>=minsup){
      print(paste0(C[seqIndex],': sup=',sup))
      L=append(L, C[seqIndex])
    }
  }
  return(L)
}

#---------------------------------------------------------------------------
Customers=unique(Online_Retail$CustomerID)
totalGoods=data.frame(unique(Online_Retail[, 'Description']))
allFreqSeq=c()
singleItemIndex=c()
for (k in 1:length(Customers)) {
  freqItem=findFreqItem(k) # k-input:(1:4373)
  str=''
  order=c()
  for (i in 1:length(freqItem)) {
    pos=which(totalGoods[,1]==freqItem[i])
    order=append(order, pos)
  }
  singleItemIndex=append(singleItemIndex, order)
  order=sort(order)
  for (i in 1:length(order)) {
    str=paste(str, order[i])
  }
  allFreqSeq=append(allFreqSeq, str)
}

C1=data.frame(table(singleItemIndex))
lessMinsup=which(C1['Freq']<40)
L1=c()
for (i in length(lessMinsup):1) {
  C1=C1[-lessMinsup[i],]
}
for (i in 1:length(C1[, 1])) {
  L1=append(L1, as.numeric(as.character(C1[i, 1])))
}

C2=c()
L2=c()
for (i in 1:length(L1)) {
  for (j in 1:length(L1)){
    C2=append(C2, paste(L1[i], L1[j]))
  }
}
L2=prunedByMinsup(L2, C2)

C3=c()
L3=c()
for (i in 1:(length(L2)-1)) {
  part1=unlist(strsplit(L2[i], ' '))
  for (j in (i+1):length(L2)) {
    part2=unlist(strsplit(L2[j], ' '))
    if(part1[2]==part2[1]){
      C3=append(C3, paste(L2[i], part2[2]))
    }
  }
}
C3=prunedByFrequency(L2, C3, 3)
L3=prunedByMinsup(L3, C3)

C4=c()
L4=c()
for (i in 1:(length(L3)-1)) {
  part1=unlist(strsplit(L3[i], ' '))
  for (j in (i+1):length(L3)) {
    part2=unlist(strsplit(L3[j], ' '))
    if(part1[2]==part2[1] & part1[3]==part2[2]){
      C4=append(C4, paste(L3[i], part2[3]))
    }
  }
}
C4=prunedByFrequency(L3, C4, 4)
L4=prunedByMinsup(L4, C4)


# To check each k-frequent sequence
L1_table=data.frame(L1)
L2_table=data.frame(L2)
L3_table=data.frame(L3)
L4_table=data.frame(L4)
L1_table
L2_table
L3_table
L4_table
