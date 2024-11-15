--[[ this module exposes the interface of lua functions:
define here the lua functions that activate the plugin ]]

local main = require("gomodifytags.main")
local config = require("gomodifytags.config")

local M = {}

---@param opts gomodifytags.opts
function M.setup(opts)
  config.apply(opts)

  vim.api.nvim_create_user_command("GoAddTags", main.addTags,
    {
      desc =
      "GoAddTags Adds tags for the whitespace separated list of keys",
      nargs =
      "*"
    })

  vim.api.nvim_create_user_command("GoRemoveTags", main.removeTags,
    {
      desc =
      "GoRemoveTags Removes tags for the whitespace separated list of keys",
      nargs =
      "*"
    })
end

return M
