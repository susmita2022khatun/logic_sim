require "class"
push = require "push"
require "and"

WINDOW_WIDTH = 1600
WINDOW_HEIGTH = 800

VIRTUAL_WINDOW_HEIGHT = 1600
VIRTUAL_WINDOW_WIDTH = 800

CENT_AND_X = 500
CENT_AND_Y = 200
PIN_GAP = 100  -- give some more gap
WIDTH = 200

function love.load()
    love.graphics.setDefaultFilter('nearest' , 'nearest')
    push:setupScreen(VIRTUAL_WINDOW_WIDTH , VIRTUAL_WINDOW_HEIGHT , WINDOW_WIDTH , WINDOW_HEIGTH , 
    {
        fullscreen = false , 
        resizable = false , 
        vsync = true
    })

    gate = and_gate:new(CENT_AND_X , CENT_AND_Y , PIN_GAP , WIDTH)
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    end
end 

function love.mousepressed(x, y, button)
    if button == 1 then 
        local gx, gy = push:toGame(x, y)  -- convert to virtual (game) coordinates
        if gx and gy then
            print("Mouse clicked at:", gx, gy)
            gate:checkClick(gx, gy)
        end
    end
end



function love.draw()
    push:apply('start')
    gate:render()
    push:apply('end')
end
