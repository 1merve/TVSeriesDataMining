using CSV
using DataFrames
using Random


# Veri setini ön işleme ve kodlama fonksiyonu
function preprocess_and_encode(df)
    categorical_columns = [:Yönetmen, :Tür, :Kanal, :Başrol, :Title, :Yapımşirketi] 
    df_encoded = copy(df)
    for col in categorical_columns
        unique_values = unique(df[!, col])
        for value in unique_values
            df_encoded[!, Symbol(value)] = df[!, col] .== value
        end
    end
    return select(df_encoded, Not(categorical_columns))
end

# CSV dosyasını oku
file_path = "modified_file_new_1_corrected.csv"  # CSV dosyasının yolu
df = CSV.read(file_path, DataFrame)

# 'Bitiş_Yılı' sütununu sil
#select!(df, Not(:Bitiş_Yılı))

# Veri setini ön işle ve kodla
df_encoded = preprocess_and_encode(df)

# Encode edilmiş verileri yeni bir CSV dosyasına yaz
output_file_path = "encoded_dataset.csv"  # Çıktı dosyasının adını ve yolunu belirtin
CSV.write(output_file_path, df_encoded)

println("Encode edilmiş veriler '$output_file_path' dosyasına yazıldı.")



