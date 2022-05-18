# read the data file to check it has no data loss/encoding errors
file1 = open("hungarian.data","r")
fileLines = file1.readlines()
print("fileLines read successfully")
# print(fileLines)
file1.close()

formattedData = []
# Initialize the csv columns
formattedData.append("id, ccf, age, sex, painloc, painexer, relrest, pmcaden, cp, trestbps, htn, chol, smoke, cigs, years, fbs, dm, famhist, restecg, ekgmo, ekgday, ekgyr, dig, prop, nitr, pro, diuretic, proto, thaldur, thaltime, met, thalach, thalrest, tpeakbps, tpeakbpd, dummy, trestbpd, exang, xhypo, oldpeak, slope, rldv5, rldv53, ca, restckm, exerckm, restef, restwm, exeref, exerwm, thal, thalsev, thalpul, earlobe, cmo, cday, cyr, num, lmt, ladprox, laddist, diag, cxmain, ramus, om1, om2, rcaprox, rcadist, lvx1, lvx2, lvx3, lvx4, lvf, cathef, junk, name\n")
dataRow = []

# for each line in the file
# convert all spaces to commas
# remove the newline character
# replace the last field with a new line char
for line in fileLines:
    line = line.replace(" ",", ")
    line = line.replace("\n",", ")
    line = line.replace("name, ","name\n")
    dataRow.append(line)
    # if the end of a field is reached, combine the row and add it to the csv array
    if line.endswith("\n"):
        # merge each data row into a single string
        formattedData.append("".join(dataRow))
        dataRow = []

# convert formatted data to a csv file
file2 = open("hungarian.csv","w")
file2.write("".join(formattedData))
file2.close()
