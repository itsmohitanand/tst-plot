using NPZ
using StatsBase
using Combinatorics
using CairoMakie
using Colors
using LaTeXStrings
using MathTeXEngine

beech_bins = npzread("data/beech_bins.npy")
pine_bins = npzread("data/pine_bins.npy")

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
var_list_beech, age_beech, lai_beech, mean_Xs_beech, std_Xs_beech, labels_beech = get_var_list("beech")
var_list_pine, age_pine, lai_pine, mean_Xs_pine, std_Xs_pine, labels_pine = get_var_list("pine")


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


index_beech = argmax(beech_bins .>200)[2]

change = age_beech_ori[2:end, :] - age_beech_ori[1:end-1, :]

index_extreme_loss = sum(change, dims=2) .> 1e4

change_extreme =  change[index_extreme_loss[:,1], 1:end]

change_extreme

lines(beech_bins[1, 1:end-1], mean(change_extreme, dims=1)[1,:]./mean(age_beech_ori, dims=1)[1,:])

beech_bins[1, 1:end-1]


mean(age_beech_ori, dims=1)[1,:]
age_small = sum(age_beech_ori[:, 1:index_beech], dims=2)
change_small = age_small[2:end, :] - age_small[1:end-1, :]
change_small = change_small./sum(age_small[1:end-1, :], dims=2)


age_large = sum(age_beech_ori[:, index_beech:end], dims=2)
change_large = age_large[2:end, :] - age_large[1:end-1, :]
change_large = change_large./sum(age_large[1:end-1, :], dims=2)


f = Figure(resolution = (800, 600))
ax = Axis(f[1,1])
lines!(ax, change_small[1:100,1], color = :red)
lines!(ax, change_large[1:100,1], color = :blue)
f


y
change = age_beech_ori[2:end, :] - age_beech_ori[1:end-1, :]
change = change./sum(age_beech_ori[1:end-1, :], dims=2)

lines(change[2,:])
