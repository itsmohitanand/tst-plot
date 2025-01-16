using NPZ
using DataFrames
using StatsBase

pft = "beech"
seed = "5"
exp = "attention"

path_beech = "/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(exp)_$(seed)_$(n_features).csv"

pft = "pine"
seed = "2"
exp = "attention"

path_pine = "/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(exp)_$(seed)_$(n_features).csv"

df_beech = DataFrame(CSV.File(path_beech))
df_pine = DataFrame(CSV.File(path_pine))

df_beech
df_pine

xlist_b = [L"T^3_{beech}", L"T^2_{beech}",L"LAI^{1}_{beech}", L"T^1_{beech}", L"P^{1}_{beech}", ]

xlist_p = [L"T^2_{pine}", L"T^1_{pine}", L"P^{1}_{pine}", L"LAI^{1}_{pine}", L"T^3_{pine}",]

beech_y = npzread("data/xtree_model_pred/beech/attention/0/y_test_seed_$(seed).npy")[:,1]
pine_y = npzread("data/xtree_model_pred/pine/attention/0/y_test_seed_$(seed).npy")[:,1] 


fn_b = ecdf(beech_y)
fn_p = ecdf(pine_y)

p_list = [L"q_{5}", L"q_{50}", L"q_{95}"]

fontsize_theme = Theme(fontsize = 18)
set_theme!(fontsize_theme)
f = Figure(size=(1000, 1000))

for i=0:4
    for j=i+1:4
        data = npzread("data/best_model/beech_attention_5_5_pdp_$(i)_$(j)_individual.npy")
        ax = Axis(f[i, j],
            xticks=([1,13,25],  p_list),
            yticks=([1,13,25],  p_list),
            xlabel= xlist_b[i+1],
            ylabel = xlist_b[j+1], )
        heatmap!(fn_b.(median(data, dims=1)[1, :, :]), colormap=:balance)
    end
end
f
save("images/pdp_beech.pdf", f)

f = Figure(size=(1000, 1000))
for i=0:4
    for j=i+1:4
        data = npzread("data/best_model/pine_attention_2_5_pdp_$(i)_$(j)_individual.npy")
        ax = Axis(f[i, j],
            xticks=([1,13,25],  p_list),
            yticks=([1,13,25],  p_list),
            xlabel= xlist_p[i+1],
            ylabel = xlist_p[j+1], 
            )
        heatmap!(fn_p.(median(data, dims=1)[1, :, :]), colormap=:balance)
    end
end
save("images/pdp_pine.pdf", f)

f