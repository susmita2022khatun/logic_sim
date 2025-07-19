require "class"
push = require "push"
require "and"
require "or"
require "not"
require "connect"

WINDOW_WIDTH = 1600
WINDOW_HEIGTH = 800

VIRTUAL_WINDOW_WIDTH = 1600
VIRTUAL_WINDOW_HEIGHT = 800

CENT_X = 500
CENT_Y = 400
PIN_GAP = 100  -- give some more gap
WIDTH = 200


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WINDOW_WIDTH, VIRTUAL_WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGTH, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    andgate = and_gate:new(CENT_X, CENT_Y, PIN_GAP, WIDTH)

    local x, y ,s = connect_gate_load_to(andgate)
    orgate = or_gate:new(x, y, PIN_GAP, WIDTH)
    orgate.connected_to = s

    x , y , s = connect_gate_load_to(andgate)
    notgate = not_gate:new(x, y,  WIDTH)
    notgate.connected_to = s
end


function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    end
end 


function love.update(dt)
    connect_gate_update(andgate , orgate)
    connect_gate_update(andgate , notgate)
end


function love.mousepressed(x, y, button)
    if button == 1 then 
        local gx, gy = push:toGame(x, y)  -- convert to virtual (game) coordinates
        if gx and gy then
            print("Mouse clicked at:", gx, gy)
            orgate:checkClick(gx, gy)
            andgate:checkClick(gx , gy)
            notgate: checkClick(gx , gy)
        end
    end
end



function love.draw()
    push:apply('start')
    orgate:render()
    andgate:render()
    notgate: render()
    push:apply('end')
end
