using DataFrames
using CSV
using NPZ
using StatsBase

pft = "beech"
seed = 5

if pft == "beech"
    var_map_dict = Dict(1=>5, 2=>4, 3 =>2,4=>1,5=>3)
elseif pft == "pine"
    var_map_dict = Dict(1=>3, 2=>2, 3 =>1,4=>5,5=>4)
end

filename = "data/best_model/$(pft)_attention_$(seed)_5.csv"
df = DataFrame(CSV.File(filename, delim= "\t"))


bins = npzread("data/$(pft)_bins.npy")

attn = npzread("/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(seed)_sum_attn_x_features.npy")

function str_to_num_attn(row)
    
    row = replace(row, "[" => "")
    row = replace(row, "]" => "")
    row = parse.(Float64, split(row, ", "))

    return row
end
df

for (i, row) in enumerate(eachrow(df))
    # index = var_map_dict[i]
    index = i
    a = mean(attn[:,index])
    print("Left Index: $(row.left_index), Right Index: $(row.right_index), Var: $(row.var), Attn: $(a*100/2)\n")
end

attn
attn