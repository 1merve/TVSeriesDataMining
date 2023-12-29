# JULIA'YA PAKETLERİN YÜKLENMESİ
using Pkg
Pkg.add("HTTP")
Pkg.add("Gumbo")
Pkg.add("CSV")
Pkg.add("Cascadia")
Pkg.add("DataFrames")

using HTTP
using Gumbo
using CSV
using Cascadia

function alt_kategorileri_cek(ana_url)
    cevap = HTTP.get(ana_url)
    sayfa = parsehtml(String(cevap.body))
    secici = Selector(".mw-category-group a")
    linkler = [ele.attributes["href"] for ele in eachmatch(secici, sayfa.root)]
    return linkler
end

function dizi_linklerini_cek(kategori_url)
    tam_url = "https://tr.wikipedia.org" * kategori_url
    cevap = HTTP.get(tam_url)
    sayfa = parsehtml(String(cevap.body))
    secici = Selector(".mw-category a")
    linkler = [ele.attributes["href"] for ele in eachmatch(secici, sayfa.root)]
    return linkler
end

ana_url = "https://tr.wikipedia.org/wiki/Kategori:Sona_erdi%C4%9Fi_y%C4%B1la_g%C3%B6re_T%C3%BCrk_televizyon_dizileri"
alt_kategoriler = alt_kategorileri_cek(ana_url)

global dizi_linkleri = []  # Global olarak tanımla
for kategori in alt_kategoriler
    global dizi_linkleri = dizi_linklerini_cek(kategori)  # Global değişkene atama
    append!(tum_dizi_linkleri, dizi_linkleri)
end

df = DataFrame(Dizi_Linkleri = tum_dizi_linkleri)
CSV.write("diziLinkler.csv", df)