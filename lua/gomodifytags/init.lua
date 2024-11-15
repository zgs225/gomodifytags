--[[ this module exposes the interface of lua functions:
define here the lua functions that activate the plugin ]]

local main = require("gomodifytags.main")
local config = require("gomodifytags.config")

local M = {}

function M.setup()
  vim.api.nvim_create_user_command("GoAddTags", main.addTags,
    { desc = "GoAddTags Adds tags for the comma separated list of keys.Keys can contain a static value, i,e: json:foo", nargs =
    "?" })
end

return M
