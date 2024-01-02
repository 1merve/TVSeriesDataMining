using CSV
using DataFrames

# Metin içindeki yılları çeken fonksiyon
function extract_years(years_str)
    if ismissing(years_str) || years_str == ""
        return "Bilinmiyor", "Bilinmiyor"
    else
        # Regex ile 1970 ile 2025 arasındaki yılları bul
        matches = eachmatch(r"\b(19[7-9]\d|20[0-2]\d)\b", years_str)
        years = [m.match for m in matches]
        start_year = length(years) > 0 ? years[1] : "Bilinmiyor"
        end_year = length(years) > 1 ? years[2] : (length(years) == 1 ? years[1] : "Devam Ediyor")
        return start_year, end_year
    end
end

# CSV dosyasını işleyen ve yeni verileri başka bir dosyaya yazan ana fonksiyon
function process_csv(file_path::String, output_path::String)
    # CSV dosyasını oku
    df = CSV.read(file_path, DataFrame)

    # Yayın yılı bilgisini iki sütuna ayır
    df[!, :Başlangıç_Yılı] = [extract_years(y)[1] for y in df[!, :"Yayıntarihi"]]
    df[!, :Bitiş_Yılı] = [extract_years(y)[2] for y in df[!, :"Yayıntarihi"]]

    # Eski Yayın Yılı sütununu sil
    select!(df, Not(:"Yayıntarihi"))

    # Yeni verileri CSV dosyasına yaz
    CSV.write(output_path, df)
end

# Fonksiyonu kullan
input_file_path = "completed_dataset.csv"  # Girdi dosyasının yolu
output_file_path = "splited.csv"  # Çıktı dosyasının yolu
process_csv(input_file_path, output_file_path)
