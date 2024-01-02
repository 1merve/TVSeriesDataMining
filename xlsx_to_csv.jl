using CSV
using DataFrames
using XLSX

# Excel dosyasını oku
xlsx_file = XLSX.openxlsx("completed_dataset.xlsx")

# Çalışma sayfasını seç (örneğin, "Sheet1")
sheet = xlsx_file["Sheet1"]

# Verileri bir DataFrame'e dönüştür
# Sheet içerisindeki verileri okuyup DataFrame'e çevir
data = XLSX.eachtablerow(sheet) |> DataFrame

# DataFrame'i CSV dosyasına yaz
CSV.write("completed_dataset.csv", data)
