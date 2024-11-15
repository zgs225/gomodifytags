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
      "GoAddTags Adds custom tags to struct fields in Go files.",
      nargs =
      "*"
    })

  vim.api.nvim_create_user_command("GoRemoveTags", main.removeTags,
    {
      desc =
      "GoRemoveTags Removes specific tags from struct fields.",
      nargs =
      "*"
    })

  vim.api.nvim_create_user_command("GoInstallModifyTagsBin", main.installGoModifyTagsBin,
    {
      desc =
      "GoInstallModifyTagsBin Installs the gomodifytags binary, a tool required for modifying struct tags in Go.",
    })
end

return M
