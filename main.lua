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
EP = 2
--DEBUG
local EXPRESSION = "(((A AND (NOT B)) OR (C AND D)) AND ((E OR F) OR (NOT G)))"

local gates = {}

function build_circuit(node, indent, sample, gates, prev_gate_node, stat)
    indent = indent or 0
    local x, y, s, gate_
    local prefix = string.rep("  ", indent)

    if node.type == "VAR" then
        print(prefix .. "VAR(" .. node.value .. ")")
        return

    elseif node.type == "NOT" then
        if stat == "null" then
            gate_ = not_gate:new(CENT_X, CENT_Y, WIDTH)
        else
            x, y, s = connect_gate_load_to(prev_gate_node)
            gate_ = not_gate:new(x, y, WIDTH)
            gate_.connected_to = s
            gate_.connected_from = prev_gate_node

        end

        table.insert(gates, gate_)
        print(prefix .. "NOT")
        build_circuit(node.value, indent + 1, sample, gates, gate_, "i")

    elseif node.type == "AND" or node.type == "OR" then
        if stat == "null" then
            if node.type == "AND" then
                gate_ = and_gate:new(CENT_X, CENT_Y, PIN_GAP, WIDTH)
            elseif node.type == "OR" then
                gate_ = or_gate:new(CENT_X, CENT_Y, PIN_GAP, WIDTH)
            end
        else
            x, y, s = connect_gate_load_to(prev_gate_node)
            if node.type == "AND" then
                gate_ = and_gate:new(x, y, PIN_GAP, WIDTH)
            elseif node.type == "OR" then
                gate_ = or_gate:new(x, y, PIN_GAP, WIDTH)
            end
            gate_.connected_to = s
            gate_.connected_from = prev_gate_node

        end

        table.insert(gates, gate_)
        print(prefix .. node.type)
    
        build_circuit(node.left, indent + 1, sample, gates, gate_, "u")
        build_circuit(node.right, indent + 1, sample, gates, gate_, "d")

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
        build_circuit(result, 0, {}, gates, nil, "null")

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
    for _, gate in ipairs(gates) do
        if gate.connected_to and gate.connected_from then
            connect_gate_update(gate.connected_from, gate)
        end
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


