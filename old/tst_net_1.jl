using Luxor
using ColorSchemes
using Revise
using LuxNet

palette = ColorSchemes.mk_12.colors

alpha = 1.0
color_weather = reshape(col_arr(36, add_alpha(palette[12], alpha), add_alpha(palette[6], alpha), add_alpha(palette[10], alpha)), (36, 3))
color_weather

@pdf begin
    x_base = 0
    y_base = 250
    
    ## First layer
    var = Array{Tensor2D}(undef, 3)
    factor = 0.5
    for i=1:3    
        var[i] = Tensor2D(
            position = Point(x_base-550 + 200*(i-1), y_base),
            w_scale = 0.25,
            h_scale = 0.25,
            n_element_h = 1,
            n_element_v = 36,
        )
    end

    drawnet(var)
    
    var = Array{Tensor2D}(undef, 2)
    
    for i=1:2    
        var[i] = Tensor2D(
            position = Point(x_base + 150 + 350*(i-1), y_base),
            w_scale = 0.25,
            h_scale = 0.25,
            n_element_h = 1,
            n_element_v = 101,
        )
    end

    drawnet(var)

    ## Permute dimension
    y_base = y_base - 200

    var = Array{Tensor2D}(undef, 3)
    factor = 0.5
    for i=1:3    
        var[i] = Tensor2D(
            position = Point(x_base-550 + 200*(i-1), y_base),
            w_scale = 0.25,
            h_scale = 0.25,
            n_element_h = 36,
            n_element_v = 1,
        )
    end

    drawnet(var)
    
    var = Array{Tensor2D}(undef, 2)
    
    for i=1:2    
        var[i] = Tensor2D(
            position = Point(x_base + 150 + 350*(i-1), y_base),
            w_scale = 0.25,
            h_scale = 0.25,
            n_element_h = 101,
            n_element_v = 1,
        )
    end

    drawnet(var)

    # Feature expansion
    y_base = y_base - 150


    var = Array{Tensor2D}(undef, 3)
    
    for i=1:3    
        var[i] = Tensor2D(
            position = Point(x_base-550 + 200*(i-1), y_base),
            h_scale = 0.25,
            w_scale = 0.25,
            n_element_h = 36,
            n_element_v = 64,
           )
    end

    drawnet(var)

    var = Array{Tensor2D}(undef, 2)
    
    for i=1:2
        var[i] = Tensor2D(
            position = Point(x_base+150 + 350*(i-1), y_base),
            h_scale = 0.25,
            w_scale = 0.25,
            n_element_h = 101,
            n_element_v = 64,
           )
    end

    drawnet(var)

    # Permute dim
    y_base = y_base - 150

    var = Array{Tensor3D}(undef, 3)
    
    for i=1:3    
        var[i] = Tensor3D(
            position = Point(x_base-550 + 200*(i-1), y_base),
            h_scale = 0.25,
            w_scale = 0.25,
            n_element_h = 36,
            n_element_v = 1,
            n_stack = 64,
           )
    end

    drawnet(var)

    var = Array{Tensor3D}(undef, 2)
    
    for i=1:2
        var[i] = Tensor3D(
            position = Point(x_base+150 + 350*(i-1), y_base),
            h_scale = 0.25,
            w_scale = 0.25,
            n_element_h = 101,
            n_element_v = 1,
            n_stack = 64,
           )
    end

    drawnet(var)


    # Concatenate 

    y_base = y_base - 150
    var = Tensor3D(
        position = Point(x_base, y_base),
        h_scale = 0.25,
        w_scale = 0.25,
        n_element_h = 310,
        n_element_v = 1,
        n_stack = 64,
        )

    drawnet(var)

end 1400 1000 "image_1.pdf"



@pdf begin

    x_base = 0
    y_base = 800
    
    var = Tensor3D(
        position = Point(x_base, y_base),
        h_scale = 0.25,
        w_scale = 0.25,
        n_element_h = 310,
        n_element_v = 1,
        n_stack = 64,
        )

    drawnet(var)

    # Add PE

    y_base = y_base - 150
    
    var = Tensor3D(
        position = Point(x_base, y_base),
        h_scale = 0.25,
        w_scale = 0.25,
        n_element_h = 310,
        n_element_v = 1,
        n_stack = 64,
        )

    drawnet(var)

end 1400 1000 "image_2.pdf"

@pdf begin

    x_base = 0
    y_base = 1300
    
    var = Tensor3D(
        position = Point(x_base, y_base),
        h_scale = 0.25,
        w_scale = 0.25,
        n_element_h = 310,
        n_element_v = 1,
        n_stack = 64,
        )

    drawnet(var)

    #Linear
    y_base-=250
    var = Tensor3D(
        position = Point(x_base, y_base),
        h_scale = 0.25,
        w_scale = 0.25,
        n_element_h = 310,
        n_element_v = 1,
        n_stack = 64*3,
        )

    drawnet(var)

    y_base-=150

    # Chunk
    var = Array{Tensor3D}(undef,3)
    for i=1:3
        var[i] = Tensor3D(
            position = Point(x_base, y_base -i*100),
            h_scale = 0.25,
            w_scale = 0.25,
            n_element_h = 310,
            n_element_v = 1,
            n_stack = 64,
            )
    end
    drawnet(var)

    # Reshape to get head
    y_base-=800

    var = Array{Tensor3D}(undef,3)
    for i=1:3
        var[i] = Tensor3D(
            position = Point(x_base -200 +(i-1)*200, y_base),
            h_scale = 0.25,
            w_scale = 0.25,
            n_element_h = 4,
            n_element_v = 310,
            n_stack = 16,
            )
    end
    drawnet(var)

    # Attention Weight
     #Linear
     y_base-=1000
     var = Tensor3D(
         position = Point(x_base, y_base),
         h_scale = 0.25,
         w_scale = 0.25,
         n_element_h = 4,
         n_element_v = 310,
         n_stack = 310,
         )
 
     drawnet(var)
    
end 1400 3000 "image_3.pdf"