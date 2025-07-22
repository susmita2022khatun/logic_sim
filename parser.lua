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
