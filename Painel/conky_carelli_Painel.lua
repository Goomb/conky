require 'cairo'

-- Converte o ângulo de graus para radianos
-- E corrige o ângulo inicial do arco (-90º)
function angulo( graus )
    radianos = (graus - 90) * (math.pi/180)
    return radianos
end

function rgb( r, g, b )
    red = r/255
    green = g/255
    blue = b/255

    return red, green, blue
end

function cpu_bar(x, y, h, w, valor, red, green, blue)
    --SETTINGS FOR CPU INDICATOR BAR
    bar_bottom_left_x = x
    bar_bottom_left_y = y
    bar_width = w
    bar_height = h

    --set bar background colors
    bar_bg_red,bar_bg_green,bar_bg_blue=rgb(200,200,200)
    bar_bg_alpha=1

    --set indicator colors
    bar_in_red=red
    bar_in_green=green
    bar_in_blue=blue
    bar_in_alpha=1

    --draw background
    cairo_set_source_rgba(cr, bar_bg_red, bar_bg_green, bar_bg_blue, bar_bg_alpha)
    cairo_rectangle(cr, bar_bottom_left_x, bar_bottom_left_y, bar_width, -bar_height)
    cairo_fill (cr)

    --draw indicator
    cairo_set_source_rgba (cr, bar_in_red, bar_in_green, bar_in_blue, bar_in_alpha)
    value=valor
    max_value=100
    scale=bar_height/max_value
    indicator_height=scale*value
    cairo_rectangle (cr, bar_bottom_left_x, bar_bottom_left_y, bar_width, -indicator_height)
    cairo_fill (cr)
end

function indicador_arco(x, y, valor, label, red, green, blue)
    --SETTINGS
    --rings size
    ring_center_x=x
    ring_center_y=y

    ring_radius=32
    ring_width=5

    --colors
    --set background colors
    ring_bg_red, ring_bg_green, ring_bg_blue=rgb(200,200,200)
    ring_bg_alpha=1

    --set indicator colors
    ring_in_red=red
    ring_in_green=green
    ring_in_blue=blue
    ring_in_alpha=1

    --indicator value settings
    value=valor
    max_value=100

    --draw background
    cairo_set_line_width (cr,ring_width)
    cairo_set_source_rgba (cr,ring_bg_red,ring_bg_green,ring_bg_blue,ring_bg_alpha)
    cairo_arc (cr,ring_center_x,ring_center_y,ring_radius,0,2*math.pi)
    cairo_stroke (cr)

    cairo_set_line_width (cr,ring_width)
    start_angle = angulo(0)
    end_angle=angulo( value*(360/max_value) )

    --print (end_angle)
    cairo_set_source_rgba (cr,ring_in_red,ring_in_green,ring_in_blue,ring_in_alpha)
    cairo_arc (cr,ring_center_x,ring_center_y,ring_radius,start_angle,end_angle)
    cairo_stroke (cr)

    -- Label
    -- Centraliza o texto no arco
    local extents = cairo_text_extents_t:create()
    tolua.takeownership(extents)
    cairo_text_extents(cr, label, extents)
    x = ring_center_x - (extents.width / 2 + extents.x_bearing)
    y = ring_center_y - (extents.height / 2 + extents.y_bearing) - 7

    texto(label, x, y, red, green, blue )

    txt = valor .. "%"
    cairo_text_extents(cr, txt, extents)
    x = ring_center_x - (extents.width / 2 + extents.x_bearing)
    y = ring_center_y - (extents.height / 2 + extents.y_bearing) + 7

    texto(txt, x, y, red, green, blue )
end

function texto(txt, x, y, r, g, b)
    -- Configura o tipo e o tamanho da fonte que será utilizada
    font="Ubuntu Mono"
    font_size=14
    font_slant=CAIRO_FONT_SLANT_NORMAL
    font_face=CAIRO_FONT_WEIGHT_BOLD

    -- Inicializa o Cairo com as configurações de fontes
    cairo_select_font_face (cr, font, font_slant, font_face);
    cairo_set_font_size (cr, font_size)

    text=txt
    xpos,ypos=x,y
    red,green,blue = r,g,b
    alpha=1
    cairo_set_source_rgba (cr,red,green,blue,alpha)

    cairo_move_to (cr,xpos,ypos)
    cairo_show_text (cr,text)
    cairo_stroke (cr)
end

function conky_main()
    if conky_window == nil then
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.width,
                                         conky_window.height)
    cr = cairo_create(cs)

    -- Indicador CPU
    x=57
    y=70
    valor = conky_parse("${cpu cpu0}")
    indicador_arco(x, y, valor, "CPU", rgb(255, 117, 49))

    -- Indicador RAM
    x=57
    y=150
    valor = conky_parse("${memperc}")
    indicador_arco(x, y, valor, "RAM", rgb(255, 255, 112))

    -- Indicador SWAP
    x=57
    y=230
    valor = conky_parse("${swapperc}")
    indicador_arco(x, y, valor, "SWAP", rgb(220, 127, 220))

    -- Indicador Disco (Home)
    x=57
    y=310
    valor  = 100-tonumber(conky_parse("${fs_free_perc /home}"))
    indicador_arco(x, y, valor, "/home", rgb(0, 164, 209))

    -- Indicador Disco (Root)
    x=57
    y=390
    valor  = 100-tonumber(conky_parse("${fs_free_perc /}"))
    indicador_arco(x, y, valor, "/", rgb(141, 255, 141))

    -- Indicador Disco (Boot)
    --x=57
    --y=470
    --valor  = 100-tonumber(conky_parse("${fs_free_perc /boot}"))
    --indicador_arco(x, y, valor, "/boot", rgb(220, 127, 220))


    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
