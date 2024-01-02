using DataFrames
using CSV

# final_dataset.csv dosyasını DataFrame olarak yükle
final_df = CSV.read("final_dataset.csv", DataFrame)

# İlgili sütunları seç
selected_columns = ["Yapımşirketi", "Sezonsayısı", "Yayıntarihi", "Tür", "Kanal", "Başrol"]

# Yeni DataFrame oluştur, 'Title' sütununu da ekle
new_df = select(final_df, [:Title; [Symbol(col) for col in selected_columns]])

# Yeni DataFrame'i yeni bir CSV dosyasına kaydet
CSV.write("selected_data.csv", new_df)
