using HTTP
using Gumbo
using Cascadia
using DataFrames
using CSV

# URL ve istek başlıkları
url = "https://tr.wikipedia.org/wiki/Kavak_Yelleri_(dizi,_2007)"
headers = ["Accept" => "text/html", "Accept-Charset" => "utf-8"]

# HTTP isteği yapma ve yanıtı almak
response = HTTP.get(url, headers)

# Yanıt içeriğini UTF-8 olarak çevirme
page_content = String(response.body)

# HTML içeriğini parse etme
parsed_page = parsehtml(page_content)
body = parsed_page.root[2]

# Infobox'ı seçme
info_box_selector = eachmatch(Selector(".infobox"), body)

# Eğer infobox bulunursa, işlemleri yap
if length(info_box_selector) > 0
    infobox = info_box_selector[1][1]

    # Tablo satırlarını ayıklama
    rows = eachmatch(Selector("tr"), infobox)

    # Veri depolama için boş bir dizi
    data = []

    for row in rows
        header_cells = eachmatch(Selector("th"), row)
        data_cells = eachmatch(Selector("td"), row)

        header = !isempty(header_cells) ? Gumbo.text(header_cells[1]) : ""
        cell_data = !isempty(data_cells) ? Gumbo.text(data_cells[1]) : ""

        if header != "" && cell_data != ""
            push!(data, (Header=header, Data=cell_data))
        end
    end

    # DataFrame oluşturma
    df = DataFrame(data)

    # CSV dosyasına yazdırma
    csv_file_name = "infobox_data.csv"
    CSV.write(csv_file_name, df)
end
