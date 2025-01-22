using NPZ
using StatsBase
using Combinatorics
using CairoMakie
using Colors
using LaTeXStrings

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

age_beech_extreme = age_beech_n[labels_beech.>percentile(labels_beech, 90), :]
age_beech_min = Vector{Float64}()
age_beech_max = Vector{Float64}()

for j in 1:end_age_beech
    push!(age_beech_min, quantile(age_beech_extreme[:,j], 0.05))
    push!(age_beech_max, quantile(age_beech_extreme[:,j], 0.95))
end

lai_beech_extreme = lai_beech_n[labels_beech.>percentile(labels_beech, 90), :]
lai_beech_min = Vector{Float64}()
lai_beech_max = Vector{Float64}()
for j in 1:end_lai_beech
    push!(lai_beech_min, quantile(lai_beech_extreme[:,j], 0.05))
    push!(lai_beech_max, quantile(lai_beech_extreme[:,j], 0.95))
end

age_pine_extreme = age_pine_n[labels_pine.>percentile(labels_pine, 90), :]
age_pine_min = Vector{Float64}()
age_pine_max = Vector{Float64}()
for j in 1:end_age_pine
    push!(age_pine_min, quantile(age_pine_extreme[:,j], 0.05))
    push!(age_pine_max, quantile(age_pine_extreme[:,j], 0.95))
end


lai_pine_extreme = lai_pine_n[labels_pine.>percentile(labels_pine, 90), :]
lai_pine_min = Vector{Float64}()
lai_pine_max = Vector{Float64}()
for j in 1:end_lai_pine
    push!(lai_pine_min, quantile(lai_pine_extreme[:,j], 0.05))
    push!(lai_pine_max, quantile(lai_pine_extreme[:,j], 0.95))
end



### Figure starts here

f = Figure(size = (1200,700))

ax_top = f[1,1] = GridLayout()
ax_bottom = f[2:3,1] = GridLayout()

ax_climate = Axis(ax_top[1,1], 
    xgridvisible=false, 
    ygridvisible=false,
    yticks = ([1:11;], xtick_corr_all),
    xticks = ([1:11;], xtick_corr_all),
    xticklabelrotation = pi/3,
    )

ax_age_beech_cor = Axis(ax_top[1,2], 
    xlabel="Age", 
    ylabel="Age (Beech) ", 
    xgridvisible=false, 
    ygridvisible=false,
    xticks = end_age_beech_ticklabels,
    xticklabelrotation = pi/3,
    yticks = end_age_beech_ticklabels,
    )

ax_age_pine_cor = Axis(ax_top[1,3], 
    xlabel="Age", 
    ylabel="Age (Pine)", 
    xgridvisible=false, 
    ygridvisible=false, 
    xticks = end_age_pine_ticklabels,
    xticklabelrotation = pi/3,
    yticks = end_age_pine_ticklabels,
    aspect = AxisAspect(1),)

    ax_lai_beech_cor = Axis(ax_top[1,4], 
    xlabel="LAI", 
    ylabel="LAI (Beech)", 
    xgridvisible=false, 
    ygridvisible=false,
    xticks = end_lai_beech_ticklabels,
    xticklabelrotation = pi/3,
    yticks = end_lai_beech_ticklabels,
    )

ax_lai_pine_cor = Axis(ax_top[1,5], 
    xlabel="LAI", 
    ylabel="LAI (Pine)", 
    xgridvisible=false, 
    ygridvisible=false,
    xticks = end_lai_pine_ticklabels,
    xticklabelrotation = pi/3,
    yticks = end_lai_pine_ticklabels,
    )


f

ax_age_beech = Axis(ax_bottom[1,1:5], 
            xlabel="Age", 
            ylabel="Count Anomaly", 
            xgridvisible=false, 
            ygridvisible=false)


ax_age_pine = Axis(ax_bottom[2,1:5], xlabel="Age", ylabel="Count Anomaly", xgridvisible=false, ygridvisible=false)

ax_lai_beech = Axis(ax_bottom[1,6:10], xlabel="LAI", ylabel="Count Anomaly", xgridvisible=false, ygridvisible=false)
ax_lai_pine = Axis(ax_bottom[2,6:10], xlabel="LAI", ylabel="Count Anomaly", xgridvisible=false, ygridvisible=false)




f

hm_climate = heatmap!(ax_climate, cross_cor_beech, colormap=(:balance, 1), colorrange = (-0.5,0.5))
ax_climate.yreversed = true
Colorbar(ax_top[1, 6], hm_climate, vertical=true)
f

heatmap!(ax_age_beech_cor, cross_cor_age_beech, colormap=(:balance, 1), colorrange = (-0.5,0.5))
heatmap!(ax_age_pine_cor, cross_cor_age_pine, colormap=(:balance, 1), colorrange = (-0.5,0.5))
heatmap!(ax_lai_beech_cor, cross_cor_lai_beech, colormap=(:balance, 1), colorrange = (-0.5,0.5))
heatmap!(ax_lai_pine_cor, cross_cor_lai_pine, colormap=(:balance, 1), colorrange = (-0.5,0.5))
f
ax_age_beech_cor.yreversed = true
ax_age_pine_cor.yreversed = true
ax_lai_beech_cor.yreversed = true
ax_lai_pine_cor.yreversed = true
f

num = 10

hlines!(ax_age_beech, [0], color = :grey20, linestyle = :dash)
lines!(ax_age_beech, beech_bins[1,1:end_age_beech], median(age_beech_extreme, dims=1)[1:end_age_beech], color = p["orange"], linewidth = 2)
band!(ax_age_beech, beech_bins[1,1:end_age_beech], age_beech_min, age_beech_max, color = (p["orange"], 0.25))
for i=1:num
    lines!(ax_age_beech, beech_bins[1,1:end_age_beech], age_beech_extreme[i,:], color = (:grey50, 0.2))
end
f

hlines!(ax_lai_beech, [0], color = :grey20, linestyle = :dash)
lines!(ax_lai_beech, beech_bins[2,1:end_lai_beech], median(lai_beech_extreme, dims=1)[1:end_lai_beech], color = p["green"], linewidth = 2)
band!(ax_lai_beech, beech_bins[2,1:end_lai_beech], lai_beech_min, lai_beech_max, color = (p["green"], 0.25))
for i=1:num
    lines!(ax_lai_beech, beech_bins[2,1:end_lai_beech], lai_beech_extreme[i,1:end_lai_beech], color = (:grey50, 0.2))
end
f

hlines!(ax_age_pine, [0], color = :grey20, linestyle = :dash)
lines!(ax_age_pine, pine_bins[1,1:end_age_pine], median(age_pine_extreme, dims=1)[1:end_age_pine], color = p["orange"], linewidth = 2)
band!(ax_age_pine, pine_bins[1,1:end_age_pine], age_pine_min, age_pine_max, color = (p["orange"], 0.25))
for i=1:num
    lines!(ax_age_pine, pine_bins[1,1:end_age_pine], age_pine_extreme[i,1:end_age_pine], color = (:grey50, 0.2))
end
f

hlines!(ax_lai_pine, [0], color = :grey20, linestyle = :dash)
lines!(ax_lai_pine, pine_bins[2,1:end_lai_pine], median(lai_pine_extreme, dims=1)[1:end_lai_pine], color = p["green"], linewidth = 2)
band!(ax_lai_pine, pine_bins[2,1:end_lai_pine], lai_pine_min, lai_pine_max, color = (p["green"], 0.25))
for i=1:num
    lines!(ax_lai_pine, pine_bins[2,1:end_lai_pine], lai_pine_extreme[i,1:end_lai_pine], color = (:grey50, 0.2))
end

f

label = ["a", "b", "c", "d", "e"]
for i=1:5
    Label(ax_top[1,i, TopLeft()], 
        label[i],
        fontsize=16, 
        font = :bold,
        halign = :right, 
        padding = (10,30,5,0) )
end
f

label = ["f", "g", "h", "i"]

for (i, ind) in enumerate([(1,1:5), (1,6:10), (2,1:5), (2,6:10)])
    Label(ax_bottom[ind[1], ind[2], TopLeft()], 
        label[i],
        fontsize=16, 
        font = :bold,
        halign = :right, 
        padding = (10,30,5,0) )
end

f


ax_climate.aspect = 1
ax_age_beech_cor.aspect = 1
ax_age_pine_cor.aspect = 1
ax_lai_beech_cor.aspect = 1
ax_lai_pine_cor.aspect = 1
f
lim = 2.5
ylims!(ax_age_beech, -lim, lim)
ylims!(ax_age_pine, -lim, lim)
ylims!(ax_lai_beech, -lim, lim)
ylims!(ax_lai_pine, -lim, lim)


hidespines!(ax_climate, :t, :r)
hidespines!(ax_age_beech_cor, :t, :r)
hidespines!(ax_age_pine_cor, :t, :r)
hidespines!(ax_lai_beech_cor, :t, :r)
hidespines!(ax_lai_pine_cor, :t, :r)

hidespines!(ax_age_beech, :t, :r)
hidespines!(ax_age_pine, :t, :r)
hidespines!(ax_lai_beech, :t, :r)
hidespines!(ax_lai_pine, :t, :r)

f
save("images/fig_5_data_complexity.pdf", f)
