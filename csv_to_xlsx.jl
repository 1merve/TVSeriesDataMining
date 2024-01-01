using CSV
using DataFrames
using XLSX

# CSV dosyasını oku ve DataFrame'e dönüştür
df = CSV.read("final_dataset.csv", DataFrame)

# DataFrame'i Excel dosyasına yaz
XLSX.writetable("final_dataset.xlsx", collect(DataFrames.eachcol(df)), names(df))

