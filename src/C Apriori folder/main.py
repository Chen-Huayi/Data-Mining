import os

import numpy as np
import pandas as pd
from mlxtend.frequent_patterns import apriori, association_rules


#give 5% as the minimum support
__minSup=0.05
colName=['InvoiceNo','Description','InvoiceDate','CustomerID', 'Country']
__dataSet=pd.read_csv("Online Retail.csv")

countryList=["United Kingdom","Germany","France","EIRE","Spain"]
countryItem=[]
encodedCtry=[]

def cleanData(dataset):
    print("Cleaning data...\n")
    #We won't need the StockCode and CustomerID, we will focus on the goods itself in this case.
    dataset['Description'] =dataset['Description'].str.strip()
    dataset.dropna(axis=0, subset=['InvoiceNo'], inplace = True)
    dataset['InvoiceNo'] =dataset ['InvoiceNo'].astype('str')
    #take those credit trade off the calculation
    dataset =dataset[~dataset['InvoiceNo'].str.contains('C')]
    # print(dataset.head())
    return dataset


#return a list divide by each country to find the frequent item
# we will count the top five countries in sales of goods.
def countryset(__dataset,countryList,countryItem):
    print("Creating country Item set...\n")
    for i in range(5):
        countryItem.append( (__dataSet[__dataSet['Country'] == countryList[i]]
                          .groupby(['InvoiceNo', 'Description'])['Quantity']
                          .sum().unstack().reset_index().fillna(0).set_index('InvoiceNo')) )
        # print(countryItem[i].head())
    return countryItem

#--------
def codeMap(x):
    k=-1
    if(x<=0):
        k= 0
    if(x>=1):
        k= 1
    return k

#--------
def encode(encodedCtry,countryItem):
    print("Encoding datasets...\n")
    for i in range(5):
        encodedCtry.append(countryItem[i].applymap(codeMap) )
        # print("-------encoded--------\n")
        # print(encodedCtry[i].head())
    return encodedCtry


if __name__ == "__main__":
    print("\nMining frequency pattern by Apriori rules:\n")

    __dataSet=cleanData(__dataSet)
    countryItem=countryset(__dataSet,countryList,countryItem)
    encodedCtry=encode(encodedCtry,countryItem)
#example output for frequent Item UK
    print("Creating .csv files...\n")
    #change the number inside encodedCtry from 0-4 to check different countries.
    frqI_UK=apriori(encodedCtry[0],min_support=__minSup,use_colnames=True)
    frqI_UK.to_csv("frequent_Item_Sp.csv")
    ruleUK=association_rules(frqI_UK,metric="lift",min_threshold=1)
    ruleUK=ruleUK.sort_values(['confidence','lift'],ascending =[False, False])
    ruleUK.to_csv("Association_Rule_Sp.csv")


    print("\nEnd Of Processing")






