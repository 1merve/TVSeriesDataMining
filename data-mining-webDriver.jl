using WebDriver
using DataFrames
using CSV
using DefaultApplication

function start_webdriver()
    DefaultApplication.open("C:/Users/PC/Downloads/data-mining-new/notebooks/selenium/chromedriver.exe")
    sleep(2)

    capabilities = Capabilities("chrome")
    wd = RemoteWebDriver(capabilities, host = "localhost", port = 9515)

    return Session(wd)
end

url ="https://tr.wikipedia.org/wiki/T%C3%BCrk_dizileri_listesi"
# Scrape series data
function scrape_wikipedia_series(url)
    session = start_webdriver()
    navigate!(session, url)
    sleep(5)

    results = DataFrame(title=String[], link=String[])


    try
        tables = Elements(session, "css selector", "table")
        
            
            for table in tables
                t_body = Element(table, "css selector", "tbody")
                tv_series = Elements(t_body, "css selector", "tr")
                    for tv_serie in tv_series
           
                       
                             # Inside your try block where you are processing each tv_serie
                                try
                                    a_element = Element(tv_serie, "css selector", "td > a")
                                    title = element_text(a_element)
                                    href = element_attr(a_element, "href")

                                        # Prepend the base URL to the href
                                        full_link = "https://tr.wikipedia.org/" * href

                                        # Add the title and the full link to the results DataFrame
                                        push!(results, (title, full_link))
                                catch
                                    
                                    continue
                                 end

                                 
                         end
                   
                end
            
 catch e
        @warn "Bir hata oluştu: $e"
 end

    delete!(session)
    return results
end

# Collect data and save as CSV
series_data = scrape_wikipedia_series(url)
CSV.write("series_data.csv", series_data)