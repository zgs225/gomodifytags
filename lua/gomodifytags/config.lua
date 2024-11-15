--- @class gomodifytags.opts
--- whether override current tags when add tags
--- @field override? boolean
--- whether skip unexported fields
--- @field skip_unexported? boolean
--- whether sorts the tags in increasing order according to the key name
--- @field sort? boolean
--- adds a transform rule when adding tags
--- @field transform? '"snakecase"'|'"camelcase"'|'"lispcase"'|'"pascalcase"'|'"titlecase"'|'"keep"'

local M = {}

--- @type gomodifytags.opts
M.o = {}

--- @type gomodifytags.opts
M.defaults = {
  override = false,
  skip_unexported = false,
  sort = false,
  transform = "snakecase",
}

function M.apply(opts)
  M.o = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
end

return M
