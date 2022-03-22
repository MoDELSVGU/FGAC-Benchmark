#!/usr/bin/env python3
# importing packages 
import pandas as pd 
import matplotlib.pyplot as plt 

FILE_NAME = "Query4Opt"  

df = pd.read_csv("../output/res_" + FILE_NAME + ".csv", delimiter=";")

df = df[['Scenario','ProcedureName','MetricValue']]

# view dataset 
print(df) 

groupby = df[['Scenario','ProcedureName','MetricValue']].groupby(['Scenario','ProcedureName']).agg({'MetricValue': ['mean']}).unstack().reset_index()

# df = df[['Scenario','ProcedureCall','MetricValue']]

# # view dataset 
# print(df) 

# groupby = df[['Scenario','ProcedureCall','MetricValue']].groupby(['Scenario','ProcedureCall']).agg({'MetricValue': ['mean']}).unstack().reset_index()

# view dataset 
print(groupby)  

# groupby = groupby[::-1]

groupby.plot(
    x = 'Scenario',
    y = 'MetricValue'
)

plt.xlabel("UnivX")
plt.ylabel("Execution time (seconds)")
plt.xticks([200,400,600,800,1000],[r'$2*10^2$',r'$4*10^2$',r'$6*10^2$',r'$8*10^2$',r'$10^3$'])
# plt.xticks(rotation=45)

ax1 = plt.subplot(111)

# ax2 = ax1.twiny()
# ax1Ticks = ax1.get_xticks() 
# ax2Ticks = ax1Ticks

# def tick_function(X):
#     V = X*X
#     return V

# ax2.set_xticks(ax2Ticks)
# ax2.set_xbound(ax1.get_xbound())
# ax2.set_xticklabels(tick_function(ax2Ticks))

# ax2.set_xlabel('Enrollments')
# ax2.set_xticks([100,200,400,600,800,1000])
# ax2.set_xticklabels(['10000','40000','160000','360000','640000','1000000'])


# plt.xticks([1,2,3,4,5,6])

# markers = ['o','p','<','*']

# for i, line in enumerate(ax1.get_lines()):
#     line.set_marker(markers[i])

# handles,labels = ax1.get_legend_handles_labels()

# handles = [handles[2], handles[3], handles[1], handles[0]]
# labels = [
#     r'$\ulcorner SecQuery(SecVGU$#$X3,Query$#$5) \urcorner (Vinh, Lecturer)$', 
#     r'$\ulcorner SecQuery(SecVGU$#$X2,Query$#$5) \urcorner (Michel, Lecturer)$', 
#     r'$\ulcorner SecQuery(SecVGU$#$X1,Query$#$5) \urcorner (Trang, Admin)$', 
#     'Query#5'
# ]

# handles = [handles[2], handles[1], handles[0]]
# labels = ['nornal', 'Scenario2-improved', 'Scenario2']

# ax1.legend(frameon=False, loc='upper left', ncol=4, fontsize=12)
# ax1.legend(handles,labels,loc=2,frameon=False, fontsize=8)

# plt.savefig("sqlsilineplotC2.pdf")
plt.savefig("../diagrams/graph_" + FILE_NAME + ".pdf")