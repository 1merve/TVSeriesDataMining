using CSV
using DataFrames

# Metin içindeki ilk yılı çeken fonksiyon
function extract_start_year(years_str)
    if ismissing(years_str) || years_str == ""
        return "Bilinmiyor"
    else
        # Regex ile 1970 ile 2025 arasındaki ilk yılı bul
        matched = match(r"\b(19[7-9]\d|20[0-2]\d)\b", years_str)
        if matched === nothing
            return "Bilinmiyor"
        else
            return matched.match
        end
    end
end


# CSV dosyasını işleyen ve yeni verileri başka bir dosyaya yazan ana fonksiyon
function process_csv(file_path::String, output_path::String)
    # CSV dosyasını oku
    df = CSV.read(file_path, DataFrame)

    # Yayın yılının başlangıç yılı bilgisini ayır
    df[!, :Başlangıç_Yılı] = [extract_start_year(y) for y in df[!, :"Yayıntarihi"]]

    # Eski Yayın Yılı sütununu sil
    select!(df, Not(:"Yayıntarihi"))

    # Yeni verileri CSV dosyasına yaz
    CSV.write(output_path, df)
end

process_csv("completed_dataset.csv", "splited.csv")
