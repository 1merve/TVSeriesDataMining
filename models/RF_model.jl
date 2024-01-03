using CSV
using DataFrames
using ScikitLearn: fit!, predict, @sk_import
using Random
using Statistics

@sk_import ensemble: RandomForestClassifier
@sk_import metrics: (confusion_matrix)

# Function to categorize seasons
function categorize_seasons(season_count)
    if season_count == 1
        return "A"  # 1 sezon
    elseif season_count == 2
        return "B"  # 2 sezon
    elseif season_count >= 3 && season_count <= 5
        return "C"  # 3-5 sezon
    elseif season_count > 5 && season_count <= 10
        return "D"  # 5-10 sezon
    else
        return "E"  # 10'dan fazla sezon
    end
end

# Main loop for each year
for year in 1995:2023
    # Her yılın veri seti için dosya yolu ayarla
    file_path = "filtered_data_up_to_year\\filtered_data_up_to_$(year).csv"

    # Belirli bir yıl için veri setini yükle
    global df = CSV.read(file_path, DataFrame)

    # Ön işlemden geçmiş veriyi al ve kodla
    df_encoded = CSV.read("encoded_dataset.csv", DataFrame)
    df_encoded[!, :Category] = map(categorize_seasons, df_encoded[!, :Sezonsayısı])

    # Test Seti için Uniform Random Sampling uygula
    test_set_proportion = 0.3
    n = nrow(df_encoded)
    indices = shuffle(1:n)  # Satır indekslerini karıştır

    # Test örneklerinin sayısını hesapla ve indeksleri böl
    n_test = Int(ceil(n * test_set_proportion))
    test_indices = indices[1:n_test]
    train_indices = indices[n_test+1:end]

    # Özellikleri ve hedef değişkeni ayır
    feature_columns = setdiff(names(df_encoded), [:Sezonsayısı, :Category])
    numeric_columns = [col for col in feature_columns if eltype(df_encoded[!, col]) <: Number]

    X = Matrix{Float64}(df_encoded[!, numeric_columns])
    y = df_encoded[!, :Category]

    X_train = X[train_indices, :]
    y_train = y[train_indices]
    X_test = X[test_indices, :]
    y_test = y[test_indices]

    # RandomForestClassifier örneği oluştur ve eğit
    model = RandomForestClassifier()
    fit!(model, X_train, y_train)

    # Modeli değerlendir
    predictions = predict(model, X_test)

    # Confusion matrix hesapla
    cm = confusion_matrix(y_test, predictions)

   # Confusion matrix elemanlarını al
    TP = [cm[i, i] for i in 1:size(cm, 1)]
    FP = [sum(cm[:, i]) - cm[i, i] for i in 1:size(cm, 1)]  
    FN = [sum(cm[i, :]) - cm[i, i] for i in 1:size(cm, 1)]
    TN = [sum(cm) - sum(cm[i, :]) - sum(cm[:, i]) + cm[i, i] for i in 1:size(cm, 1)]

    # Accuracy, Precision ve Recall hesapla
    accuracy = sum(TP) / sum(cm)
    precision = mean([TP[i] / (TP[i] + FP[i]) for i in 1:length(TP) if TP[i] + FP[i] != 0])
    recall = mean([TP[i] / (TP[i] + FN[i]) for i in 1:length(TP) if TP[i] + FN[i] != 0])
    year+=1
    println("Random Forest Modelinin $year için Confusion Matrisi:")
    println(cm)
    println("Accuracy (Doğruluk): $accuracy")
    println("Precision (Kesinlik): $precision")
    println("Recall (Anma): $recall")
end