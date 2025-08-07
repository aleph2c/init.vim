-- ~/.config/nvim/lua/sapf_player.lua

local M = {}

-- The simple, working command for live playback.
local SAPF_CMD_TEMPLATE = "((echo '%s'; sleep infinity) | sapf) &"

local function get_code()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' or mode == 'V' then
    local start_pos = vim.api.nvim_buf_get_mark(0, '<')
    local end_pos = vim.api.nvim_buf_get_mark(0, '>')
    local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
    if #lines > 0 then
      lines[#lines] = string.sub(lines[#lines], 1, end_pos[2] + 1)
      lines[1] = string.sub(lines[1], start_pos[2] + 1)
    end
    return table.concat(lines, '\n')
  else
    return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  end
end

function M.play()
  M.stop()
  vim.fn.system('sleep 0.05')

  local code = get_code()
  local sanitized_code = string.gsub(code, "'", "'\\''")

  if sanitized_code and #sanitized_code > 0 then
    local command_to_run = string.format(SAPF_CMD_TEMPLATE, sanitized_code)
    vim.cmd('echo "Playing... (<leader><leader>s to stop)"')
    vim.fn.system(command_to_run)
  else
    vim.cmd('echo "No code to play."')
  end
end

function M.stop()
  -- Use the global pkill command. This will stop all processes named 'sapf'.
  local command = "pkill -2 sapf >/dev/null 2>&1"
  vim.fn.system(command)

  -- Silently clear the command line.
  vim.cmd('echo ""')
end

return M
