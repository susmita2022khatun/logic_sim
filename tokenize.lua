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