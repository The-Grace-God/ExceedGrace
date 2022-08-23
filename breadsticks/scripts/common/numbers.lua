function load_number_image(path)
    local images = {}
    for i = 0, 9 do
        images[i + 1] = gfx.CreateSkinImage(string.format("%s/%d.png", path, i), 0)
    end
    return images
end

function draw_number(x, y, alpha, num, digits, images, is_dim, scale, kern, dim_first_zero)
    scale = scale or 1
    kern = kern or 1
    dim_first_zero = dim_first_zero == nil and true or dim_first_zero

    local tw, th = gfx.ImageSize(images[1])
    tw = tw * scale
    th = th * scale
    x = x + (tw * (digits - 1)) / 2
    y = y - th / 2
    
    for i = 1, digits do
        local mul = 10 ^ (i - 1)
        local digit = math.floor(num / mul) % 10
        local a = alpha
    
        if is_dim and num < mul and not (not dim_first_zero and i <= 1) then
            a = 0.4
        end
    
        gfx.BeginPath()
        gfx.ImageRect(x, y, tw, th, images[digit + 1], a, 0)
    
        x = x - (tw * kern)
    end
end

return {
    load_number_image = load_number_image,
    draw_number = draw_number
}