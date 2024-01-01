using HTTP
using Gumbo
using Cascadia
using DataFrames
using CSV

function complete_url(partial_url)
    base_url = "https://tr.wikipedia.org"
    return base_url * partial_url
end

function fetch_infobox(url)
    response = HTTP.get(url)
    page_content = String(response.body)
    parsed_page = parsehtml(page_content)
    body = parsed_page.root[2]

    # Dizi ismini bulmak için en üstteki başlığı çekme
    title_selector = eachmatch(Selector(".infobox-above.summary"), body)
    title = length(title_selector) > 0 ? Gumbo.text(title_selector[1]) : "Başlık Bulunamadı"

    info_box_selector = eachmatch(Selector(".infobox"), body)
    data = []

    if length(info_box_selector) > 0
        infobox = info_box_selector[1][1]
        rows = eachmatch(Selector("tr"), infobox)

        for row in rows
            header_cells = eachmatch(Selector("th"), row)
            data_cells = eachmatch(Selector("td"), row)

            header = !isempty(header_cells) ? Gumbo.text(header_cells[1]) : ""
            cell_data = !isempty(data_cells) ? Gumbo.text(data_cells[1]) : ""

            if header != "" && cell_data != ""
                push!(data, (Title=title, Header=header, Data=cell_data))
            end
        end
    end
    return DataFrame(data)
end

links_df = CSV.read("filtrelenmisdiziLinkler.csv", DataFrame)
links = links_df[:, :Dizi_Linkleri]  # Burada ':link' yerine doğru sütun adını kullanın

global all_data = DataFrame(Title=String[], Header=String[], Data=String[]) # Bu satırı 'global' ile işaretleyin
for partial_link in links
    full_link = complete_url(partial_link)
    df = fetch_infobox(full_link)
    global all_data = vcat(all_data, df)  # Döngü içindeki atamalarda 'global' kullanın
end

CSV.write("infobox_data.csv", all_data)
