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

    title_selector = eachmatch(Selector(".infobox-above"), body)
    title = length(title_selector) > 0 ? Gumbo.text(title_selector[1]) : "Başlık Bulunamadı"

    info_box_selector = eachmatch(Selector(".infobox"), body)
    infobox_data = Dict{String, String}()

    if length(info_box_selector) > 0
        infobox = info_box_selector[1][1]
        rows = eachmatch(Selector("tr"), infobox)

        for row in rows
            header_cells = eachmatch(Selector("th"), row)
            data_cells = eachmatch(Selector("td"), row)

            header = !isempty(header_cells) ? strip(Gumbo.text(header_cells[1])) : ""
            cell_data = ""

            if !isempty(data_cells)
                if header == "Tür" || header == "Yönetmen" || header == "Başrol" || header == "Kanal"
                    cell_content = map(Gumbo.text, data_cells[1].children)
                    cell_data = join(cell_content, " - ")
                end
            end

            if header != "" && cell_data != ""
                infobox_data[header] = cell_data
            end
        end
    end
    return title, infobox_data
end


links_df = CSV.read("filtrelenmisdiziLinkler.csv", DataFrame)
links = links_df[:, :Dizi_Linkleri]

all_headers = Set{String}()
all_data = Dict{String, Any}()

for partial_link in links
    full_link = complete_url(partial_link)
    title, data = fetch_infobox(full_link)
    all_data[title] = data
    union!(all_headers, keys(data))
end

headers = [:Title; [Symbol(header) for header in all_headers]]
final_df = DataFrame([String[] for _ in headers], headers)

for (title, data) in all_data
    row = [title; [get(data, header, "") for header in all_headers]]
    push!(final_df, row)
end

CSV.write("ayrilmis_veriler.csv", final_df)
