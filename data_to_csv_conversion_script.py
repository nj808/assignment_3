import os

# Loop the script for every dataset
# Creates a .csv file for each raw data file
for file in os.listdir("./rawDatasets"):
    rawFilePath = "./rawDatasets/" + file
    csvFileName = "./csvDatasets/" + file.split(".")[0] + ".csv"
    # read the data file to check it has no data loss/encoding errors
    rawDataFile = open(rawFilePath, "r")
    rawDataLines = rawDataFile.readlines()
    print("Raw Data in {} read successfully".format(file))
    rawDataFile.close()

    formattedData = []
    # Add the column headers to the csv data
    formattedData.append("id, ccf, age, sex, painloc, painexer, relrest, pmcaden, cp, trestbps, htn, chol, smoke, cigs, years, fbs, dm, famhist, restecg, ekgmo, ekgday, ekgyr, dig, prop, nitr, pro, diuretic, proto, thaldur, thaltime, met, thalach, thalrest, tpeakbps, tpeakbpd, dummy, trestbpd, exang, xhypo, oldpeak, slope, rldv5, rldv53, ca, restckm, exerckm, restef, restwm, exeref, exerwm, thal, thalsev, thalpul, earlobe, cmo, cday, cyr, num, lmt, ladprox, laddist, diag, cxmain, ramus, om1, om2, rcaprox, rcadist, lvx1, lvx2, lvx3, lvx4, lvf, cathef, junk, name\n")
    dataRow = []

    # for each line in the file
    # convert all spaces to commas
    # remove the newline character
    # replace the last field with a new line char
    for line in rawDataLines:
        line = line.replace(" ",", ")
        line = line.replace("\n",", ")
        line = line.replace("name, ","name\n")
        dataRow.append(line)
        # if the end of a field is reached, combine the row and add it to the csv array
        if line.endswith("\n"):
            # merge each data row into a single string
            formattedData.append("".join(dataRow))
            dataRow = []

    # create the csvDatasets directory if it doesn't exist
    os.makedirs("./csvDatasets", exist_ok=True)
    # convert formatted data to a csv file
    csvFile = open(csvFileName,"w")
    csvFile.write("".join(formattedData))
    csvFile.close()
    print("CSV file created for {}".format(file))

print("All datasets converted to CSV")
    
