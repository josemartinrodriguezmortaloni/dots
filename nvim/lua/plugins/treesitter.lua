local function is_parser_supported(lang)
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  return ok and parsers[lang] ~= nil
end

local function has_local_parser(lang)
  return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) > 0
end

local function ensure_parser_installed(lang)
  if has_local_parser(lang) then return end
  local ok, ts = pcall(require, "nvim-treesitter")
  if ok then
    vim.notify("Instalando parser de Treesitter para: " .. lang, vim.log.levels.INFO)
    pcall(ts.install, lang)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TSAutoInstall", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
    if not lang or not is_parser_supported(lang) then return end
    ensure_parser_installed(lang)
    if has_local_parser(lang) then vim.treesitter.start(ev.buf) end
  end,
})
