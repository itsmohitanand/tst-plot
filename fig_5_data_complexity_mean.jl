using NPZ
using StatsBase
using Combinatorics
using CairoMakie
using Colors
using LaTeXStrings
using MathTeXEngine

beech_bins = npzread("data/beech_bins.npy")
pine_bins = npzread("data/pine_bins.npy")

p = Dict(
    "red"=> parse(Colorant, "#FF1F5B"),
    "green"=> parse(Colorant, "#00CD6C"),
    "blue"=> parse(Colorant, "#009ADE"),
    "purple"=> parse(Colorant, "#AF58BA"),
    "yellow"=> parse(Colorant, "#FFC61E"),
    "orange" => parse(Colorant, "#F28522"),
    "grey"=> parse(Colorant, "#A0B1BA"),
    "brown" => parse(Colorant, "#A6761D")
)

function get_var_list(pft)
    age = npzread("data/ml_data/$(pft)_age.npy")
    lai = npzread("data/ml_data/$(pft)_lai.npy")
    precip = npzread("data/ml_data/$(pft)_precip.npy")
    rad = npzread("data/ml_data/$(pft)_rad.npy")
    temp = npzread("data/ml_data/$(pft)_temp.npy")
    labels = npzread("data/ml_data/$(pft)_labels.npy")
    std_Xs = npzread("data/ml_data/$(pft)_std_Xs.npy")
    mean_Xs = npzread("data/ml_data/$(pft)_mean_Xs.npy")

    age_1, age_2, age_3 = age[:,1:33], age[:, 34:66], age[:,67:end]
    lai_1, lai_2, lai_3 = lai[:,1:33], lai[:, 34:66], lai[:,67:end]
    precip_1, precip_2, precip_3 = precip[:,1:73], precip[:, 73:2*73], precip[:,2*73:end]
    rad_1, rad_2, rad_3 = rad[:,1:73], rad[:, 73:2*73], rad[:,2*73:end]
    temp_1, temp_2, temp_3 = temp[:,1:73], temp[:, 73:2*73], temp[:,2*73:end]


    age_1, age_2, age_3 = mean(age_1, dims=2), mean(age_2, dims=2), mean(age_3, dims=2)
    lai_1, lai_2, lai_3 = mean(lai_1, dims=2), mean(lai_2, dims=2), mean(lai_3, dims=2)
    precip_1, precip_2, precip_3 = mean(precip_1, dims=2), mean(precip_2, dims=2), mean(precip_3, dims=2)
    rad_1, rad_2, rad_3 = mean(rad_1, dims=2), mean(rad_2, dims=2), mean(rad_3, dims=2)
    temp_1, temp_2, temp_3 = mean(temp_1, dims=2), mean(temp_2, dims=2), mean(temp_3, dims=2)


    var_list = [rad_1, rad_2, rad_3, precip_1, precip_2, precip_3,  temp_1, temp_2, temp_3, age, lai]

    return var_list, age, lai, mean_Xs, std_Xs, labels
end


function get_cross_cor(var_list)
    # Calculate cross correlation matrix for each pair of variables in var_list
    cross_cor = zeros(length(var_list), length(var_list))

    for i in eachindex(var_list)
        for j in eachindex(var_list)
            if i<=j
                cross_cor[i,j] = crosscor(var_list[i], var_list[j], [0], demean=false)[1]
            else
                cross_cor[i,j] = NaN
            end
        end
    end

    return cross_cor
end


function get_cross_cor_high_dim(var, ind = missing)
    cross_cor = zeros(101, 101)

    for i in 1:101
        for j in 1:101
            if i<=j
                cross_cor[i,j] = crosscor(var[:,i], var[:,j], [0], demean=false)[1]
            else
                cross_cor[i,j] = NaN
            end
        end
    end

    if ismissing(ind)
        ind = argmax(all(isnan, cross_cor, dims=2))[1]
        return cross_cor[1:ind, 1:ind]
    else
        return cross_cor
    end
end



# Get variable list for pine and beech

var_list_beech, age_beech, lai_beech, mean_Xs_beech, std_Xs_beech, labels_beech = get_var_list("beech")
var_list_pine, age_pine, lai_pine, mean_Xs_pine, std_Xs_pine, labels_pine = get_var_list("pine")


age_beech


cross_cor_beech = get_cross_cor(var_list_beech)
cross_cor_pine = get_cross_cor(var_list_pine)

age_beech_n = age_beech #.*std_Xs_beech[1] .+ mean_Xs_beech[1]
lai_beech_n = lai_beech #.*std_Xs_beech[2] .+ mean_Xs_beech[2]

age_pine_n = age_pine #.*std_Xs_pine[1] .+ mean_Xs_pine[1]
lai_pine_n = lai_pine #.*std_Xs_pine[2] .+ mean_Xs_pine[2]

cross_cor_age_beech = get_cross_cor_high_dim(age_beech_n, 101)
cross_cor_age_pine = get_cross_cor_high_dim(age_pine_n)

cross_cor_lai_beech = get_cross_cor_high_dim(lai_beech_n)
cross_cor_lai_pine = get_cross_cor_high_dim(lai_pine_n)

end_age_beech = size(cross_cor_age_beech)[1]
end_age_pine = size(cross_cor_age_pine)[1]

end_lai_beech = size(cross_cor_lai_beech)[1]
end_lai_pine = size(cross_cor_lai_pine)[1]

# Create 1 d array with 4 points between 1 and end_age_beech
end_age_beech_ticks = Int.(round.((collect(range(1, end_age_beech, length=4)))))
end_age_beech_ticklabels = (end_age_beech_ticks, string.(Int.(round.(beech_bins[1, Int.(end_age_beech_ticks)], digits=0))))

end_lai_beech_ticks = Int.(round.((collect(range(1, end_lai_beech, length=4)))))
end_lai_beech_ticklabels = (end_lai_beech_ticks,  string.(round.(beech_bins[2, Int.(end_lai_beech_ticks)], digits=1)))

end_age_pine_ticks = Int.(round.((collect(range(1, end_age_pine, length=4)))))
end_age_pine_ticklabels = (end_age_pine_ticks,  string.(Int.(round.(pine_bins[1, Int.(end_age_pine_ticks)], digits=0))))

end_lai_pine_ticks = Int.(round.((collect(range(1, end_lai_pine, length=4)))))
end_lai_pine_ticklabels = (end_lai_pine_ticks,  string.(round.(pine_bins[2, Int.(end_lai_pine_ticks)], digits=1)))   


xtick_corr_all = latexstring.(["Rad_{t-3}", "Rad_{t-2}", "Rad_{t-1}", "Precip_{t-3}", "Precip_{t-2}", "Precip_{t-1}", "Temp_{t-3}", "Temp_{t-2}", "Temp_{t-1}", "Age", "LAI"])

beech_ind_extreme = labels_beech.>quantile(labels_beech, 0.90)
pine_ind_extreme = labels_pine.>quantile(labels_pine, 0.90)

age_beech_extreme = age_beech_n[beech_ind_extreme, :]
age_beech_min = mean(age_beech_extreme, dims=1) - std(age_beech_extreme, dims=1)
age_beech_max = mean(age_beech_extreme, dims=1) + std(age_beech_extreme, dims=1)

lai_beech_extreme = lai_beech_n[beech_ind_extreme, :]
lai_beech_min = mean(lai_beech_extreme, dims=1) - std(lai_beech_extreme, dims=1)
lai_beech_max = mean(lai_beech_extreme, dims=1) + std(lai_beech_extreme, dims=1)

age_pine_extreme = age_pine_n[pine_ind_extreme, :]
age_pine_min = mean(age_pine_extreme, dims=1) - std(age_pine_extreme, dims=1)
age_pine_max = mean(age_pine_extreme, dims=1) + std(age_pine_extreme, dims=1)

lai_pine_extreme = lai_pine_n[pine_ind_extreme, :]
lai_pine_min = mean(lai_pine_extreme, dims=1) - std(lai_pine_extreme, dims=1)
lai_pine_max = mean(lai_pine_extreme, dims=1) + std(lai_pine_extreme, dims=1)

function quantile_mat(mat, q)
    out = Vector{Float64}()
    for i in eachindex(mat[1,:])
        if quantile(mat[:,i], q) < 1
            push!(out, 1)
        else
            push!(out, quantile(mat[:,i], q))
        end
    end
    return out
end

mean_age_beech = reshape(mean_Xs_beech[:,1], 1, 101)
std_age_beech = reshape(std_Xs_beech[:,1], 1, 101)

mean_lai_beech = reshape(mean_Xs_beech[:,2], 1, 101)
std_lai_beech = reshape(std_Xs_beech[:,2], 1, 101)

mean_age_pine = reshape(mean_Xs_pine[:,1], 1, 101)
std_age_pine = reshape(std_Xs_pine[:,1], 1, 101)

mean_lai_pine = reshape(mean_Xs_pine[:,2], 1, 101)
std_lai_pine = reshape(std_Xs_pine[:,2], 1, 101)


age_beech_ori = age_beech .*std_age_beech .+ mean_age_beech

median_age_beech = quantile_mat(age_beech_ori, 0.5)
q95_age_beech = quantile_mat(age_beech_ori, 0.95)
q05_age_beech = quantile_mat(age_beech_ori, 0.05)

lai_beech_ori = lai_beech .*std_lai_beech .+ mean_lai_beech
median_lai_beech = quantile_mat(lai_beech_ori, 0.5)
q95_lai_beech = quantile_mat(lai_beech_ori, 0.95)
q05_lai_beech = quantile_mat(lai_beech_ori, 0.05)

age_pine_ori = age_pine .*std_age_pine .+ mean_age_pine
median_age_pine = quantile_mat(age_pine_ori, 0.5)
q95_age_pine = quantile_mat(age_pine_ori, 0.95)
q05_age_pine = quantile_mat(age_pine_ori, 0.05)

lai_pine_ori = lai_pine .*std_lai_pine .+ mean_lai_pine
median_lai_pine = quantile_mat(lai_pine_ori, 0.5)
q95_lai_pine = quantile_mat(lai_pine_ori, 0.95)
q05_lai_pine = quantile_mat(lai_pine_ori, 0.05)


### Figure starts here

textheme = Theme(fonts=(; regular=texfont(:text),
                        bold=texfont(:bold),
                        italic=texfont(:italic),
                        bold_italic=texfont(:bolditalic)),
                fontsize=18,)

set_theme!(textheme)

##################
##### FIGURE #####
##################

f = Figure(size = (1200,1000))

ax_dist = f[1,1] = GridLayout()

ax_corr = f[2,1] = GridLayout()

ax_composite = f[3:4,1] = GridLayout()

# ax_climate = Axis(ax_composite[1,1], 
#     xgridvisible=false, 
#     ygridvisible=false,
#     yticks = ([1:11;], xtick_corr_all),
#     xticks = ([1:11;], xtick_corr_all),
#     xticklabelrotation = pi/3,
#     )
f


ax_age_beech_dist = Axis(ax_dist[1,1], 
    xlabel="Age (Beech)", 
    ylabel="Density", 
    xgridvisible=false, 
    ygridvisible=false,
    yscale = log10,
     
    )

ax_lai_beech_dist = Axis(ax_dist[1,2],
    xlabel="LAI (Beech)", 
    ylabel="Density", 
    xgridvisible=false, 
    ygridvisible=false,
    yscale = log10,

    )

ax_age_pine_dist = Axis(ax_dist[1,3], 
    xlabel="Age (Pine)", 
    ylabel="Density", 
    xgridvisible=false, 
    ygridvisible=false,
    yscale = log10,

    )

ax_lai_pine_dist = Axis(ax_dist[1,4],
    xlabel="LAI (Pine)", 
    ylabel="Density", 
    xgridvisible=false, 
    ygridvisible=false,
    yscale = log10,

    )

ax_age_beech_cor = Axis(ax_corr[1,1], 
    xlabel="Age (Beech)", 
    ylabel="Age", 
    xgridvisible=false, 
    ygridvisible=false,
    xticks = end_age_beech_ticklabels,
    xticklabelrotation = pi/3,
    yticks = end_age_beech_ticklabels,
    )

ax_lai_beech_cor = Axis(ax_corr[1,2], 
    xlabel="LAI (Beech)", 
    ylabel="LAI", 
    xgridvisible=false, 
    ygridvisible=false,
    xticks = end_lai_beech_ticklabels,
    xticklabelrotation = pi/3,
    yticks = end_lai_beech_ticklabels,
    )
ax_age_pine_cor = Axis(ax_corr[1,3], 
    xlabel="Age (Pine)", 
    ylabel="Age", 
    xgridvisible=false, 
    ygridvisible=false, 
    xticks = end_age_pine_ticklabels,
    xticklabelrotation = pi/3,
    yticks = end_age_pine_ticklabels,)



ax_lai_pine_cor = Axis(ax_corr[1,4], 
    xlabel="LAI (Pine)", 
    ylabel="LAI", 
    xgridvisible=false, 
    ygridvisible=false,
    xticks = end_lai_pine_ticklabels,
    xticklabelrotation = pi/3,
    yticks = end_lai_pine_ticklabels,
    )


f

ax_age_beech = Axis(ax_composite[1,1:5], 
            xlabel="Age", 
            ylabel="Count Anomaly", 
            xgridvisible=false, 
            ygridvisible=false,
            )

ax_lai_beech = Axis(ax_composite[2,1:5], 
            xlabel="LAI", 
            ylabel="Count Anomaly", 
            xgridvisible=false, 
            ygridvisible=false)

ax_age_pine = Axis(ax_composite[1,6:10], 
    xlabel="Age", 
    ylabel="Count Anomaly", 
    xgridvisible=false, 
    ygridvisible=false)


ax_lai_pine = Axis(ax_composite[2,6:10], 
    xlabel="LAI", 
    ylabel="Count Anomaly", 
    xgridvisible=false, 
    ygridvisible=false)

f


# f

q05_age_beech

lines!(ax_age_beech_dist,beech_bins[1,1:end_age_beech], median_age_beech[1:end_age_beech], color = p["orange"], linewidth = 2)
band!(ax_age_beech_dist,  beech_bins[1,1:end_age_beech], q05_age_beech[1:end_age_beech], q95_age_beech[1:end_age_beech], color = (p["orange"], 0.25))

lines!(ax_lai_beech_dist, beech_bins[2,1:end_lai_beech], median_lai_beech[1:end_lai_beech], color = p["green"], linewidth = 2)
band!(ax_lai_beech_dist, beech_bins[2,1:end_lai_beech], q05_lai_beech[1:end_lai_beech], q95_lai_beech[1:end_lai_beech], color = (p["green"], 0.25))

lines!(ax_age_pine_dist, pine_bins[1,1:end_age_pine], median_age_pine[1:end_age_pine], color = p["orange"], linewidth = 2)
band!(ax_age_pine_dist, pine_bins[1,1:end_age_pine], q05_age_pine[1:end_age_pine], q95_age_pine[1:end_age_pine], color = (p["orange"], 0.25))

lines!(ax_lai_pine_dist, pine_bins[2,1:end_lai_pine], median_lai_pine[1:end_lai_pine], color = p["green"], linewidth = 2)
band!(ax_lai_pine_dist, pine_bins[2,1:end_lai_pine], q05_lai_pine[1:end_lai_pine], q95_lai_pine[1:end_lai_pine], color = (p["green"], 0.25))

f

colorrange = (-0.75, 0.75)


heatmap!(ax_age_beech_cor, cross_cor_age_beech, colormap=(:balance, 1), colorrange = colorrange)
heatmap!(ax_age_pine_cor, cross_cor_age_pine, colormap=(:balance, 1), colorrange = colorrange)
heatmap!(ax_lai_beech_cor, cross_cor_lai_beech, colormap=(:balance, 1), colorrange = colorrange)
hm = heatmap!(ax_lai_pine_cor, cross_cor_lai_pine, colormap=(:balance, 1), colorrange = colorrange)
Colorbar(ax_corr[1,5], hm, vertical=true, label="Correlation")
f
f
ax_age_beech_cor.yreversed = true
ax_age_pine_cor.yreversed = true
ax_lai_beech_cor.yreversed = true
ax_lai_pine_cor.yreversed = true
f

num = 10

hlines!(ax_age_beech, [0], color = :grey20, linestyle = :dash)
lines!(ax_age_beech, beech_bins[1,1:end_age_beech], mean(age_beech_extreme, dims=1)[1:end_age_beech], color = p["orange"], linewidth = 2)
band!(ax_age_beech, beech_bins[1,1:end_age_beech], age_beech_min[1,:], age_beech_max[1,:], color = (p["orange"], 0.25))
for i=1:num
    lines!(ax_age_beech, beech_bins[1,1:end_age_beech], age_beech_extreme[i,:], color = (:grey50, 0.2))
end
f

hlines!(ax_lai_beech, [0], color = :grey20, linestyle = :dash)
lines!(ax_lai_beech, beech_bins[2,1:end_lai_beech], mean(lai_beech_extreme, dims=1)[1:end_lai_beech], color = p["green"], linewidth = 2)
band!(ax_lai_beech, beech_bins[2,1:end_lai_beech], lai_beech_min[1,1:end_lai_beech], lai_beech_max[1,1:end_lai_beech], color = (p["green"], 0.25))
for i=1:num
    lines!(ax_lai_beech, beech_bins[2,1:end_lai_beech], lai_beech_extreme[i,1:end_lai_beech], color = (:grey50, 0.2))
end
f

hlines!(ax_age_pine, [0], color = :grey20, linestyle = :dash)
lines!(ax_age_pine, pine_bins[1,1:end_age_pine], mean(age_pine_extreme, dims=1)[1:end_age_pine], color = p["orange"], linewidth = 2)
band!(ax_age_pine, pine_bins[1,1:end_age_pine], age_pine_min[1,1:end_age_pine], age_pine_max[1,1:end_age_pine], color = (p["orange"], 0.25))
for i=1:num
    lines!(ax_age_pine, pine_bins[1,1:end_age_pine], age_pine_extreme[i,1:end_age_pine], color = (:grey50, 0.2))
end
f

hlines!(ax_lai_pine, [0], color = :grey20, linestyle = :dash)
lines!(ax_lai_pine, pine_bins[2,1:end_lai_pine], mean(lai_pine_extreme, dims=1)[1:end_lai_pine], color = p["green"], linewidth = 2)
band!(ax_lai_pine, pine_bins[2,1:end_lai_pine], lai_pine_min[1,1:end_lai_pine], lai_pine_max[1,1:end_lai_pine], color = (p["green"], 0.25))
for i=1:num
    lines!(ax_lai_pine, pine_bins[2,1:end_lai_pine], lai_pine_extreme[i,1:end_lai_pine], color = (:grey50, 0.2))
end

f

label = ["a", "b", "c", "d"]
for i=1:4
    Label(ax_dist[1,i, TopLeft()], 
        label[i],
        fontsize=16, 
        font = :bold,
        halign = :right, 
        padding = (10,30,5,0) )
end
f


label = ["e", "f", "g", "h"]
for i=1:4
    Label(ax_corr[1,i, TopLeft()], 
        label[i],
        fontsize=16, 
        font = :bold,
        halign = :right, 
        padding = (10,30,5,0) )
end
f


label = ["i", "k", "j", "l"]

for (i, ind) in enumerate([(1,1:5), (1,6:10), (2,1:5), (2,6:10)])
    Label(ax_composite[ind[1], ind[2], TopLeft()], 
        label[i],
        fontsize=16, 
        font = :bold,
        halign = :right, 
        padding = (10,30,5,0) )
end

f


# ax_age_beech_cor.aspect = 1
# ax_age_pine_cor.aspect = 1
# ax_lai_beech_cor.aspect = 1
# ax_lai_pine_cor.aspect = 1

# ax_age_beech_dist.aspect = 1
# ax_lai_beech_dist.aspect = 1
# ax_age_pine_dist.aspect = 1
# ax_lai_pine_dist.aspect = 1

f
lim = 2.5
ylims!(ax_age_beech, -lim, lim)
ylims!(ax_age_pine, -lim, lim)
ylims!(ax_lai_beech, -lim, lim)
ylims!(ax_lai_pine, -lim, lim)

hidespines!(ax_age_beech_cor, :t, :r)
hidespines!(ax_age_pine_cor, :t, :r)
hidespines!(ax_lai_beech_cor, :t, :r)
hidespines!(ax_lai_pine_cor, :t, :r)

hidespines!(ax_age_beech, :t, :r)
hidespines!(ax_age_pine, :t, :r)
hidespines!(ax_lai_beech, :t, :r)
hidespines!(ax_lai_pine, :t, :r)

f
save("images/fig_5_data_complexity_mean.pdf", f)




# f = Figure(size = (600,600))
# climate_ax = Axis(f[1,1], 
#     xgridvisible=false, 
#     ygridvisible=false,
#     yticks = ([1:11;], xtick_corr_all),
#     xticks = ([1:11;], xtick_corr_all),
#     xticklabelrotation = pi/3,
#     )

# hm_climate = heatmap!(climate_ax, cross_cor_beech, colormap=(:balance, 1), colorrange = colorrange)
# climate_ax.yreversed = true
# Colorbar(f[1,2], hm_climate, vertical=true)
# hidespines!(climate_ax, :t, :r)
# climate_ax.aspect = 1
# f

# save("images/fig_a1_climate.pdf", f)
