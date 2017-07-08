local core = require "csplit"

function string.csplit(cststr, pattern)
    assert(type(pattern) == "string","csplit error pattern not string")
    if type(pattern) ~= "string" then
        return nil
    end
    return core.csplit(cststr, pattern)
end

function string.csplit_tb(cststr, pattern)
    assert(type(pattern) == "string","csplit_tb error pattern not string")
    if type(pattern) ~= "string" then
        return nil
    end
    return core.csplit_tb(cststr, pattern)
end

