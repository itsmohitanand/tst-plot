using CairoMakie
using ColorSchemes
using Colors

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

f = Figure(size=(1400, 1400))
ax1 = Axis(f[1,1])
ax2 = Axis(f[2,1])
ax3 = Axis(f[3,1])
f

function plot_square!(ax, n, color, x_start=0, y_start=0, x_offset=0.1, y_offset=0)

    middle = div(n,2)+1
    decreasing = range(1, 0, length=middle)
    increasing = range(0, 1, length=middle)[2:end]
    alpha_list = vcat(decreasing, increasing)

    color_list = []
    rect = []
    for i=1:n
        x_end, y_end = x_start+1, y_start+1
        push!(rect, Rect2f([Point2f(x_start,y_start), Point2f(x_end,y_end)]))
        y_start = y_end+y_offset
        x_start = x_end+x_offset 

        push!(color_list, RGBA(color, alpha_list[i]))
    end
    poly!(ax, rect,  color = color_list)

end

plot_square!(ax1, 25, p["blue"], 0, 0, 0.1, -1)
f


# n_static = 25
# middle = div(n_static,2)+1
# decreasing = range(1, 0, length=middle)
# increasing = range(0, 1, length=middle)[2:end]
# alpha_list = vcat(decreasing, increasing)

# color_list = []
# for i=1:n_static
#     x_end, y_end = x_start+1, y_start+1
#     push!(rect, Rect2f([Point2f(x_start,y_start), Point2f(x_end,y_end)]))
#     y_start = y_end+0.1 

#     push!(color_list, RGBA(p["blue"], alpha_list[i]))
# end

# rect
# poly!(ax1, rect,  color = color_list)
# f