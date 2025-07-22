-- Boolean Expression to AST Parser

-- Tokenizer
function tokenize(expr)
    local tokens = {}
    local i = 1
    while i <= #expr do
        local c = expr:sub(i,i)
        if c:match("%s") then
            i = i + 1
        elseif expr:sub(i,i+2) == "AND" then
            table.insert(tokens, "AND")
            i = i + 3
        elseif expr:sub(i,i+1) == "OR" then
            table.insert(tokens, "OR")
            i = i + 2
        elseif expr:sub(i,i+2) == "NOT" then
            table.insert(tokens, "NOT")
            i = i + 3
        elseif c == "(" or c == ")" then
            table.insert(tokens, c)
            i = i + 1
        elseif c:match("[%a]") then
            table.insert(tokens, { type = "VAR", value = c })
            i = i + 1
        else
            error("Invalid character: " .. c)
        end
    end
    return tokens
end

-- Parser
Parser = {}
Parser.__index = Parser

function Parser:new(tokens)
    return setmetatable({ tokens = tokens, pos = 1 }, self)
end

function Parser:current()
    return self.tokens[self.pos]
end

function Parser:advance()
    self.pos = self.pos + 1
end

function Parser:match(expected)
    if self:current() == expected then
        self:advance()
        return true
    end
    return false
end

function Parser:parse_expression()
    local node = self:parse_term()
    while self:current() == "OR" do
        self:advance()
        node = { type = "OR", left = node, right = self:parse_term() }
    end
    return node
end

function Parser:parse_term()
    local node = self:parse_factor()
    while self:current() == "AND" do
        self:advance()
        node = { type = "AND", left = node, right = self:parse_factor() }
    end
    return node
end

function Parser:parse_factor()
    local token = self:current()

    if token == nil then
        error("Unexpected end of input while parsing factor.")
    end

    if token == "NOT" then
        self:advance()
        return { type = "NOT", value = self:parse_factor() }

    elseif token == "(" then
        self:advance()
        local node = self:parse_expression()
        if not self:match(")") then
            error("Expected ')' but found: " .. tostring(self:current()))
        end
        return node

    elseif type(token) == "table" and token.type == "VAR" then
        self:advance()
        return { type = "VAR", value = token.value }

    else
        error("Unexpected token in factor: " .. tostring(token))
    end
end

-- sample = {}
-- AST Printer (for debugging)
function print_ast(node, indent , sample)
    indent = indent or 0
    local prefix = string.rep("  ", indent)

    if node.type == "VAR" then
        -- table.insert(sample, {indent , node.type})
        print(prefix .. "VAR(" .. node.value .. ")")
    elseif node.type == "NOT" then
        table.insert(sample, {indent , node.type})
        print(prefix .. "NOT")
        print_ast(node.value, indent + 1 , sample)
    elseif node.type == "AND" or node.type == "OR" then
        table.insert(sample, {indent , node.type})
        print(prefix .. node.type)
        print_ast(node.left, indent + 1 , sample)
        print_ast(node.right, indent + 1 , sample)
    else
        print(prefix .. "UNKNOWN NODE")
    end
end

-- MAIN
local input_expr = "(A AND (NOT B)) OR (C AND D)" -- Change this as needed
print("Input expression:", input_expr)

-- Tokenize
local tokens = tokenize(input_expr)

-- Debug print tokens
print("\nTokens:")
for i, t in ipairs(tokens) do
    if type(t) == "table" then
        print(i, "VAR", t.value)
    else
        print(i, t)
    end
end

-- Parse
local parser = Parser:new(tokens)
local success, result = pcall(function()
    return parser:parse_expression()
end)
s = {}
-- Output AST or error
if success then
    print("\n=== AST ===")
    print_ast(result , 0 , s)
else
    print("\nParse Error:", result)
end

for _, i in ipairs(s) do
    print(i[1]..","..i[2])
end
