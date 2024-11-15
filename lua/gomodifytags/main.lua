local api, fn = vim.api, vim.fn

local config = require("gomodifytags.config")
local ts_utils = require 'nvim-treesitter.ts_utils'

local M = {}

---Add tags to the struct at current cursor
---@param cmd table
function M.addTags(cmd)
  local tags = cmd.args

  if tags == "" then
    tags = "json"
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

  fn.jobstart(
    { "gomodifytags", "-file", file, "-struct", struct_name, "-add-tags", tags, "-format", "json", },
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
