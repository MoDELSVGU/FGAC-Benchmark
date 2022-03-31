#!/usr/bin/env python3
# importing packages 
import pandas as pd 
import matplotlib.pyplot as plt 

FILE_NAMES = [
    "Query4full", 
    "Query5full", 
    "Query6full"
]

for file_name in FILE_NAMES:
    df = pd.read_csv("../output/" + file_name + ".csv", delimiter=";") # Getting the csv file into dataframe
    df['Scenario'] = pd.to_numeric(df['Scenario'].str[3:]) # Transform the scenario into numeric (i.e. vgu100 -> 100)
    df = df[['RunName','Scenario','MetricValue']] # Shepherding dataframe to the minimum needed info
    rs = df.groupby(['RunName','Scenario'], as_index=False).mean() # Calculate the mean based on RunName and Scenario

    xs = rs['Scenario'].drop_duplicates().to_numpy() # Setting the x-axis
    ys = rs['RunName'].drop_duplicates().to_numpy() # Setting the line themes
    markers = ['o','p','s','*'] # Markers placeholders

    fig = plt.figure() # Creating figures
    ax = plt.subplot(111) # Adding first subplot (in case I have more, then 2x2 or something)
    ax.set_xlabel("Database size") # Setting labels
    ax.set_ylabel("seconds") 

    for i, runname in enumerate(ys): # Creating line by lines
        lineframe = rs.loc[rs['RunName'] == runname, ['Scenario','MetricValue']] # Getting dataframe for line
        line, = ax.plot(lineframe['Scenario'], lineframe['MetricValue'], label = runname, lw=1) # plot it!
        line.set_marker(markers[i])
        

    # Shrink current axis's height by 10% on the bottom
    box = ax.get_position()
    ax.set_position([box.x0, box.y0 + box.height * 0.1, box.width, box.height * 0.8])
    ax.grid('on', which='minor', axis='y')
    ax.grid('off', which='major', axis='y')

    # Put a legend below current axis
    ax.legend(loc='upper center', bbox_to_anchor=(0.5, 1.15), fancybox=True, shadow=True, ncol=4, fontsize=8)

    plt.xticks(xs) # Setting x-axis to display fully from 100 to 1000

    plt.savefig("../graph_" + file_name + ".pdf") # Save the plot under this name
