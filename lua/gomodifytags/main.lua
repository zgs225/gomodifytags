local api, fn = vim.api, vim.fn
local ts_utils = require 'nvim-treesitter.ts_utils'
local config = require("gomodifytags.config")

local M = {}

---Add tags to the struct at current cursor
---@param cmd table
function M.addTags(cmd)
  local args = cmd.fargs
  local tags = {}
  local tag_options = {}

  if not args or #args == 0 then
    args = { "json" }
  end

  for _, arg in ipairs(args) do
    local opts = fn.split(arg, ",", true)
    local tag = ""
    local first_opt = true
    for _, opt in ipairs(opts) do
      if first_opt then
        tag = opt
        table.insert(tags, tag)
        first_opt = false
      else
        table.insert(tag_options, tag .. "=" .. opt)
      end
    end
  end

  local file_type = vim.bo.filetype

  if file_type ~= "go" then
    M.errlog("this function can only be called in a Go file")
    return
  end

  local file = api.nvim_buf_get_name(0)
  local struct_name = M.getStructNameUnderCurosr()

  if struct_name == nil then
    M.errlog("no struct detected")
    return
  end

  local job_stderr = ""

  local job_cmds = { "gomodifytags", "-file", file, "-struct", struct_name, "-format", "json", }

  table.insert(job_cmds, "-add-tags")
  table.insert(job_cmds, fn.join(tags, ","))

  if #tag_options > 0 then
    table.insert(job_cmds, "-add-options")
    table.insert(job_cmds, fn.join(tag_options, ","))
  end

  if config.o.skip_unexported then
    table.insert(job_cmds, "-skip-unexported")
  end

  if config.o.override then
    table.insert(job_cmds, "-override")
  end

  if config.o.sort then
    table.insert(job_cmds, "-sort")
  end

  table.insert(job_cmds, "-transform")
  table.insert(job_cmds, config.o.transform)

  -- M.log(fn.join(job_cmds, " "))

  fn.jobstart(
    job_cmds,
    {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          local json_output = table.concat(data, "\n"):gsub("^%s*(.-)%s*$", "%1")
          local success, decoded = pcall(fn.json_decode, json_output)
          if success and decoded then
            local lines = decoded.lines
            if lines then
              local count = 0
              for _, line in ipairs(lines) do
                fn.setline(decoded.start + count, line)
                count = count + 1
              end
            end
          end
        end
      end,
      on_stderr = function(_, data)
        if data then
          job_stderr = table.concat(data, "\n")
        end
      end,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          M.errlog(job_stderr)
        end
      end
    })
end

---@return string|nil
function M.getStructNameUnderCurosr()
  local node = ts_utils.get_node_at_cursor(0)

  if not node then
    return nil
  end

  while node do
    if node:type() == "type_spec" then
      local struct_node = node:child(1)

      if struct_node and struct_node:type() == "struct_type" then
        local name_node = node:child(0)
        if name_node then
          local struct_name = vim.treesitter.get_node_text(name_node, 0)
          return struct_name
        end
      end
    end
    node = node:parent()
  end

  return nil
end

---@param msg string
function M.errlog(msg)
  api.nvim_err_writeln("gomodifytags: " .. msg)
end

---@param msg string
function M.log(msg)
  print("gomodifytags: " .. msg)
end

return M
