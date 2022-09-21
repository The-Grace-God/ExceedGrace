  local ScrollScales = {}
  local TextWidths = {}
  local Size = {}
  local TextWidth = {}

function textmaker(text, fontsize, maxWidth, x, y, w, h, lenght, scissorY, id) -- testing is needed
        gfx.FontSize(fontsize)
        local x1,y1,x2,y2 = gfx.TextBounds(x,y, text)

        TextWidths[id] = (x2 - x1)
        TextWidth[id] = maxWidth
        Size[id] = lenght+maxWidth

        if (ScrollScales[id] == nil) then
            ScrollScales[id] = 0;
        end
       gfx.Scissor(x,y + scissorY,w,h) -- debug
        gfx.FillColor(255,255,255)
        if (x2-x1) < maxWidth then
            gfx.Text(text,x,y)
        else
            gfx.Text(text,x,y) ---ScrollScales[id]
            
            gfx.FillColor(255,255,0)
        end
        gfx.ResetScissor()

    end

function tickScroll(deltaTime)


    for i, ScrollScale in ipairs(ScrollScales) do 
            if ScrollScale < TextWidths[i]+TextWidth[i] then
                ScrollScales[i] = ScrollScale + deltaTime + 1 * math.min(1,deltaTime/ 0.002)
            else
                ScrollScales[i] = -TextWidths[i]-Size[i]/1.9
            end
    end

end

function resetIds()
    ScrollScales = {}
    TextWidths = {}
end

return {
    textmaker = textmaker,
    tickScroll = tickScroll,
    resetIds = resetIds
}

-- * = debug things