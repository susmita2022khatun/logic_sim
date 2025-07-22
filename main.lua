-- main.lua
require "class"
push = require "push"
require "and"
require "or"
require "not"
require "connect"
require "tokenize"
require "parser"

WINDOW_WIDTH = 1600
WINDOW_HEIGTH = 800
VIRTUAL_WINDOW_WIDTH = 1600
VIRTUAL_WINDOW_HEIGHT = 800

CENT_X = 1400
CENT_Y = 400
PIN_GAP = 50
WIDTH = 100
--DEBUG
local EXPRESSION = "(A AND B) OR (C AND D)"
local gates = {}

function build_circuit(node, indent, sample, gates, stat)
    local x, y, s, gate_
    indent = indent or 0
    local prefix = string.rep("  ", indent)

    prec_gate = gates[#gates]

    if node.type == "VAR" then
        print(prefix .. "VAR(" .. node.value .. ")")

    elseif node.type == "NOT" then
        if stat == "null" then
            gate_ = not_gate:new(CENT_X, CENT_Y, WIDTH)
        else
            x, y, s = connect_gate_load_to(prec_gate)
            gate_ = not_gate:new(x, y, WIDTH)
            gate_.connected_to = s
        end

        table.insert(gates, gate_)
        print(prefix .. "NOT")
        build_circuit(node.value, indent + 1, sample, gates, "i")

    elseif node.type == "AND" or node.type == "OR" then
        if stat == "null" then
            gate_ = node.type == "AND" and and_gate:new(CENT_X, CENT_Y, PIN_GAP, WIDTH)
                                 or or_gate:new(CENT_X, CENT_Y, PIN_GAP, WIDTH)
        else
            x, y, s = connect_gate_load_to(prec_gate)
            gate_ = node.type == "AND" and and_gate:new(x, y, PIN_GAP, WIDTH)
                                 or or_gate:new(x, y, PIN_GAP, WIDTH)
            gate_.connected_to = s
        end

        table.insert(gates, gate_)
        print(prefix .. node.type)
        build_circuit(node.left, indent + 1, sample, gates, "u")
        build_circuit(node.right, indent + 1, sample, gates, "d")

    else
        print(prefix .. "UNKNOWN NODE")
    end
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WINDOW_WIDTH, VIRTUAL_WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGTH, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    print("Input expression:", EXPRESSION)
    local tokens = tokenize(EXPRESSION)
    print("\nTokens:")
    for i, t in ipairs(tokens) do
        if type(t) == "table" then
            print(i, "VAR", t.value)
        else
            print(i, t)
        end
    end

    local parser = Parser:new(tokens)
    local success, result = pcall(function()
        return parser:parse_expression()
    end)

    if success then
        print("\nParsed AST:")
        build_circuit(result, 0, {}, gates, "null")
    else
        print("Parsing error:", result)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    for i = 1, #gates - 1 do
        connect_gate_update(gates[i], gates[i+1])
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local gx, gy = push:toGame(x, y)
        if gx and gy then
            print("Mouse clicked at:", gx, gy)
            for _, g in ipairs(gates) do
                g:checkClick(gx, gy)
            end
        end
    end
end

function love.draw()
    push:apply('start')
    for _, g in ipairs(gates) do
        g:render()
    end
    push:apply('end')
end


