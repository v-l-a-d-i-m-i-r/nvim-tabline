---@class nvim-tabline.line
---@field add fun(value: string)
---@field build fun(): string

---@return nvim-tabline.line
local function Line()
  local line = {}

  return {
    add = function(value)
      table.insert(line, value)
    end,
    build = function()
      -- P(line)
      return table.concat(line)
    end,
  }
end

return Line
