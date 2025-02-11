using CairoMakie
using Colors
using Peaks


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

function plt_box!(ax, x, y, w, h, txt; strokecolor=:grey70, color=:grey20, bg_color = :grey90, strokewidth=2)
    poly!(ax, Rect(x, y, w, h), color=bg_color, strokecolor=strokecolor, strokewidth = strokewidth)
    text!(ax, txt, position = Point2f(x+w/2, y+h/2), align = (:center,:center), fontsize = 14, color=color, word_wrap_width=300)
end

function plot_attn!(ax, x, y, width)
    
    function mock_attn(t,x,y)
        a, b = 1/10, x
        multisin(t) = 3sinpi.(0.1*a*(t .- b)) + 2sinpi.(0.2*a*(t .-b)) + sinpi.(0.6*a*(t .- b))
        attn_fn(t) = (multisin(t) .+ 0.1) *10 .+ y
        return attn_fn(t)
    end
    
    x_arr = [x:1:x+width;]

    y_arr = mock_attn(x_arr, x, y)

    pks = findmaxima(y_arr) |> peakproms!(;strict=false) |> peakwidths!()

    pos = Point2f[]
    color = []
    for i=1:width+1
        push!(pos, Point2f(x_arr[i], y_arr[i]))
        if y_arr[i]>y
            push!(color, p["blue"])
        else
            push!(color, RGBA(p["blue"], 0.2))
        end
    end

    lines!(ax, pos, color = color, linewidth = 2)

    for (a, b) in zip(x_arr[pks.indices], y_arr[pks.indices])

        if b > y
            lines!(ax, [Point2f(a, b), Point2f(a, y)], color=:grey50, linestyle=:dash)
            scatter!(ax, [a], [b], color = p["red"], markersize = 5)    
        end
    end
    lines!(ax, [Point2f(x, y), Point2f(x+width, y)], color=:grey80)
    lines!(ax, [Point2f(x, y-50), Point2f(x+width, y-50)], color=:grey20)
    lines!(ax, [Point2f(x,  y-50), Point2f(x, y+50)], color=:grey20)

    for (i, (left, right)) in enumerate(pks.edges)
        left, right = left+x, right+x
        height = pks.heights[i] - pks.proms[i]/2

        if height > y
            lines!(ax, [Point2f(left, height), Point2f(right, height)], color=p["purple"])
        end
            end

    return ax; 
end

function plot_combined_data!(ax, x, y)
    plt_box!(ax, x, y, 700, 180, "", bg_color = :transparent )

    for j=1:10
        width, height = 9,9
        x_base, y_base = x+160, y+110
        plt_box!(ax, x_base, y_base - (height+1)*j, width, height,  "", bg_color=p["purple"], strokewidth=1)
        plt_box!(ax, x_base+10, y_base - (height+1)*j, width, height,  "", bg_color=p["green"], strokewidth=1)
    end


    for i=1:36
        x_base, y_base = x+190, y+130
        width, height = 9,9
        plt_box!(ax, x_base+(width+1)*i, y_base, width, height,  "", bg_color=p["yellow"], strokewidth=1)
        plt_box!(ax, x_base+(width+1)*i, y_base-10, width, height,  "", bg_color=p["blue"], strokewidth=1)
        plt_box!(ax, x_base+(width+1)*i, y_base-20, width, height,  "", bg_color=p["red"], strokewidth=1)
    end

    for i=0:3
        lines!(ax, [Point2f(x+200+(120*i), y+100), Point2f(x+200+(120*i), y+150)],color = :grey50, linestyle=:dash)
    end

    plt_box!(ax, x+440, y+10, 120, 10,  "", bg_color=:grey40, strokewidth=1)

    return ax 
end

w_size, h_size = 1200, 1000

f = Figure(size = (w_size,h_size))

ax = Axis(f[1,1], xgridvisible = false,
    ygridvisible = false)
hidespines!(ax)
hidedecorations!(ax)
xlims!(-w_size/2, w_size/2)
ylims!(-h_size/2, h_size/2)




## FOREST MODEL
x, y = -500, 450
w, h = 350, 50
y_delta = 80
plt_box!(ax, x, y, w,h,  "Forest inventory data (Parametrisation)")
plt_box!(ax, x, y-y_delta, w,h,  "Physiological forest model (FORMIND)")
plt_box!(ax, x, y-2*y_delta, w,h,  "Forest Structures (aggregated) - Age, LAI, Biomass loss, Species")
f

## WEATHER MODEL

x = 150

plt_box!(ax,x, y, w,h, "Bias adjusted ERA-5 reanalysis data (Calibration)")
plt_box!(ax, x, y-y_delta, w,h, "Weather generator (AWEGEN)")
plt_box!(ax, x, y-2*y_delta, w,h, "Weather data - Solar radiation, Temperature, Precipitation")
f


## DATA
x, y, w, h = -175, 375, 350, 50
plt_box!(ax, x, y-2*y_delta, w,h, "Combined weather and forest data")
x, y = -350, 0
plot_combined_data!(ax, x, y)

f

## MODELS 

y, w = -100, 250 

plt_box!(ax, -525, y, w, h,  "Transformer model")
plt_box!(ax, -125, y, w, h,  "Linear regression")
plt_box!(ax, 300, y, w, h,  "Extra tree regressor")

f

y, w = -200, 250
plt_box!(ax, -525, y, w, h,  "Extract attention weights")
plt_box!(ax, -125, y, w, h, "Generate attenion pool of candidates")
plt_box!(ax, 300, y, w, h,   "Generate random pool of candidates")

f

plt_box!(ax, 87.5, -350, 300, 50,  "Subselect features using sequential forward floating selection")
f

plt_box!(ax, 87.5, -450, 300, 50,  "Interpret the best model with ICE and PDP")

f
## ATTENTION DATA

x = -525
width = 450
y = -350
plot_attn!(ax, x, y, width)
f
