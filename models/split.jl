using CSV
using DataFrames

# Load the dataset
df = CSV.read("C:\\Users\\PC\\Downloads\\modified_file_new_1_corrected.csv", DataFrame)

# Iterate through the years from 1997 to 2024
for year in 1997:2024
    # Declare df_filtered as a local variable within the loop
    local df_filtered = df[df.Başlangıç_Yılı .<= year, :]

    # Save the filtered dataset to a CSV file
    # The file name includes the year for identification
    CSV.write("filtered_data_up_to_$(year).csv", df_filtered)
end
