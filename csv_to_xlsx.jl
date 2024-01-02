using CSV
using DataFrames
using XLSX

# CSV dosyasını oku ve DataFrame'e dönüştür
df = CSV.read("selected_data.csv", DataFrame)

# DataFrame'i Excel dosyasına yaz
XLSX.writetable("selected_data.xlsx", collect(DataFrames.eachcol(df)), names(df))
