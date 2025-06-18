local color = {
  white   = {gui = '#ABB2BF', cterm = 145},
  black   = {gui = '#282C34', cterm = 235},
  green   = {gui = '#98C379', cterm = 114},
  blue    = {gui = '#61AFEF', cterm = 39 },
  cyan    = {gui = '#56B6C2', cterm = 38 },
  red     = {gui = '#E06C75', cterm = 204},
  magenta = {gui = '#C678DD', cterm = 170},
  yellow  = {gui = '#E5C07B', cterm = 180},

  orange      = {gui = '#E06C75', cterm = 131},
  gray        = {gui = '#5C6370', cterm = 59 },
  light_gray  = {gui = '#2C323C', cterm = 236},
  dark_gray   = {gui = '#4B5263', cterm = 238},
  bright_gray = {gui = '#3E4452', cterm = 237},
  eerie_black = {gui = '#1E2229', cterm = 235},
  darkness    = {gui = '#3B4048', cterm = 238},
}

local theme = {
  globals = {
    type = 'dark',
    foreground = color.white,
    background = color.black,
  },
  syntax = {
    comment  = color.gray,
    string   = color.green,
    constant = color.yellow,
    storage  = color.blue,
    special  = color.white,
    error    = color.red,
    error_bg = nil
  },
  ui = {
    cursorline    = color.light_gray,
    selection     = color.bright_gray,
    colorcolumn   = color.light_gray,
    dark_text     = color.dark_gray,
    line_nr       = color.dark_gray,
    line_bg       = color.light_gray,
    folds         = color.gray,
    menu_item     = color.bright_gray,
    menu_selected = color.blue,
    menu_fg       = color.black,
    search        = color.yellow,
    matchparen    = color.blue,
    info          = color.cyan,
    warning       = color.yellow,
    error         = color.red
  },
  terminal = {
    white   = color.white.gui,
    black   = color.black.gui,
    red     = color.red.gui,
    green   = color.green.gui,
    blue    = color.blue.gui,
    magenta = color.magenta.gui,
    yellow  = color.yellow.gui,
    cyan    = color.cyan.gui,

    bright_black = color.bright_gray.gui,
  },
}

---
-- Colorscheme boilerplate code
---
local cs = {}
cs.normal_group = 'UserNormal'
cs.none_group = 'UserNone'
cs.NONE = {gui = 'NONE', cterm = 'NONE'}

local function link(group, name)
  vim.api.nvim_set_hl(0, group, {link = name})
end

local function hi(group, colors)
  vim.api.nvim_set_hl(0, group, {
    fg = colors.fg.gui,
    bg = colors.bg.gui,
    ctermfg = colors.fg.cterm,
    ctermbg = colors.bg.cterm,
  })
end

local function hs(group, colors, style)
  local opts = {
    fg = colors.fg.gui,
    bg = colors.bg.gui,
    ctermfg = colors.fg.cterm,
    ctermbg = colors.bg.cterm,
  }

  for _, item in ipairs(style) do
    opts[item] = true
  end

  vim.api.nvim_set_hl(0, group, opts)
end

function cs.apply(theme)
  cs.FG = theme.globals.foreground
  cs.BG = theme.globals.background
  cs.init(theme.name, theme.globals)
  cs.ui(theme.ui)
  cs.base_syntax(theme.syntax)
  cs.apply_links()
  cs.terminal(theme.terminal)
end

function cs.init(name, args)
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  vim.opt.background = args.type
  vim.g.colors_name = name

  local none = cs.NONE

  hi(cs.normal_group, {fg = cs.FG, bg = none})
  hi(cs.none_group,   {fg = none, bg = none})
end

function cs.ui(theme)
  local underline = {'underline'}
  local FG = cs.FG
  local BG = cs.BG
  local none = cs.NONE

  hi('CursorLine',   {fg = none,            bg = theme.cursorline   })
  hi('CursorLineNr', {fg = none,            bg = BG                 })
  hi('ColorColumn',  {fg = none,            bg = theme.colorcolumn  })
  hi('LineNr',       {fg = theme.line_nr,   bg = none               })
  hi('NonText',      {fg = theme.line_nr,   bg = BG                 })
  hi('EndOfBuffer',  {fg = theme.dark_text, bg = BG                 })
  hi('VertSplit',    {fg = theme.line_bg,   bg = BG                 })
  hi('WinSeparator', {fg = theme.line_bg,   bg = BG                 })
  hi('Folded',       {fg = theme.folds,     bg = BG                 })
  hi('FoldColumn',   {fg = theme.folds,     bg = BG                 })
  hi('SignColumn',   {fg = none,            bg = BG                 })
  hi('PMenu',        {fg = none,            bg = theme.menu_item    })
  hi('PMenuSel',     {fg = theme.menu_fg,   bg = theme.menu_selected})
  hi('TabLine',      {fg = none,            bg = theme.line_bg      })
  hi('TabLineFill',  {fg = none,            bg = theme.line_bg      })
  hi('TabLineSel',   {fg = none,            bg = BG                 })
  hi('StatusLine',   {fg = none,            bg = theme.line_bg      })
  hi('StatusLineNC', {fg = theme.dark_text, bg = theme.line_bg      })
  hi('WildMenu',     {fg = BG,              bg = theme.search       })
  hi('Visual',       {fg = none,            bg = theme.selection    })
  hi('Search',       {fg = BG,              bg = theme.search       })
  hi('IncSearch',    {fg = BG,              bg = theme.search       })

  hs('MatchParen', {fg = theme.matchparen, bg = none}, underline)

  hi('ErrorMsg',   {fg = theme.error,   bg = none})
  hi('WarningMsg', {fg = theme.warning, bg = none})

  hi('DiagnosticError', {fg = theme.error,   bg = none})
  hi('DiagnosticWarn',  {fg = theme.warning, bg = none})
  hi('DiagnosticInfo',  {fg = theme.info,    bg = none})
  hi('DiagnosticHint',  {fg = FG,            bg = none})

  hs('DiagnosticUnderlineError', {fg = theme.error,   bg = none}, underline)
  hs('DiagnosticUnderlineWarn',  {fg = theme.warning, bg = none}, underline)
  hs('DiagnosticUnderlineInfo',  {fg = theme.info,    bg = none}, underline)
  hs('DiagnosticUnderlineHint',  {fg = FG,            bg = none}, underline)


  hi('NotifyWARNIcon',    {fg = theme.warning, bg = none})
  hi('NotifyWARNBorder',  {fg = theme.warning, bg = none})
  hi('NotifyWARNTitle',   {fg = theme.warning, bg = none})
  hi('NotifyERRORIcon',   {fg = theme.error,   bg = none})
  hi('NotifyERRORBorder', {fg = theme.error,   bg = none})
  hi('NotifyERRORTitle',  {fg = theme.error,   bg = none})
end

function cs.base_syntax(theme)
  local FG = cs.FG
  local BG = cs.BG
  local none = cs.NONE
  local ebg = theme.error_bg or none

  hi('Normal',      {fg = FG,             bg = BG  })
  hi('Comment',     {fg = theme.comment,  bg = none})
  hi('String',      {fg = theme.string,   bg = none})
  hi('Character',   {fg = theme.constant, bg = none})
  hi('Number',      {fg = theme.constant, bg = none})
  hi('Boolean',     {fg = theme.constant, bg = none})
  hi('Float',       {fg = theme.constant, bg = none})
  hi('Function',    {fg = theme.storage,  bg = none})
  hi('Special',     {fg = theme.special,  bg = none})
  hi('SpecialChar', {fg = theme.special,  bg = none})
  hi('SpecialKey',  {fg = theme.special,  bg = none})
  hi('Error',       {fg = theme.error,    bg = ebg })

  hi('Constant',       {fg = none, bg = none})
  hi('Statement',      {fg = none, bg = none})
  hi('Conditional',    {fg = none, bg = none})
  hi('Exception',      {fg = none, bg = none})
  hi('Identifier',     {fg = none, bg = none})
  hi('Type',           {fg = none, bg = none})
  hi('Repeat',         {fg = none, bg = none})
  hi('Label',          {fg = none, bg = none})
  hi('Operator',       {fg = none, bg = none})
  hi('Keyword',        {fg = none, bg = none})
  hi('Delimiter',      {fg = none, bg = none})
  hi('Tag',            {fg = none, bg = none})
  hi('SpecialComment', {fg = none, bg = none})
  hi('Debug',          {fg = none, bg = none})
  hi('PreProc',        {fg = none, bg = none})
  hi('Include',        {fg = none, bg = none})
  hi('Define',         {fg = none, bg = none})
  hi('Macro',          {fg = none, bg = none})
  hi('PreCondit',      {fg = none, bg = none})
  hi('StorageClass',   {fg = none, bg = none})
  hi('Structure',      {fg = none, bg = none})
  hi('Typedef',        {fg = none, bg = none})
  hi('Title',          {fg = none, bg = none})
  hi('Todo',           {fg = none, bg = none})
end

function cs.apply_links()
  local none = cs.none_group
  local normal = cs.normal_group

  -- UI: Misc
  link('Conceal', 'Visual')


  -- UI: Diff
  link('DiffAdd',    'DiagnosticWarn')
  link('DiffChange', 'DiagnosticInfo')
  link('DiffDelete', 'DiagnosticError')
  link('DiffText',   'Visual')


  -- UI: search
  link('CurSearch', 'IncSearch')


  -- UI: window
  link('NormalFloat', 'Normal')
  link('FloatBorder', 'Normal')


  -- UI: messages
  link('Question', 'String')


  -- UI: Diagnostic
  link('DiagnosticSignError', 'DiagnosticError')
  link('DiagnosticSignWarn',  'DiagnosticWarn')
  link('DiagnosticSignInfo',  'DiagnosticInfo')
  link('DiagnosticSignHint',  'DiagnosticHint')
  link('DiagnosticFloatingError', 'DiagnosticError')
  link('DiagnosticFloatingWarn',  'DiagnosticWarn')
  link('DiagnosticFloatingInfo',  'DiagnosticInfo')
  link('DiagnosticFloatingHint',  'DiagnosticHint')
  link('DiagnosticVirtualTextError', 'DiagnosticError')
  link('DiagnosticVirtualTextWarn',  'DiagnosticWarn')
  link('DiagnosticVirtualTextInfo',  'DiagnosticInfo')
  link('DiagnosticVirtualTextHint',  'DiagnosticHint')


  -- UI: Netrw
  link('Directory',     'Function')
  link('netrwDir',      'Function')
  link('netrwHelpCmd',  'Special')
  link('netrwMarkFile', 'Search')


  -- Language: help page
  -- Syntax: built-in
  link('helpExample', none)

  -- Language: lua
  -- Syntax: built-in
  link('luaFunction', 'Function')
  link('luaConstant', 'Boolean')

  -- Language: HTML
  -- Syntax: built-in
  link('htmlTag',            'Special')
  link('htmlEndTag',         'Special')
  link('htmlTagName',        'Function')
  link('htmlTagN',           'Function')
  link('htmlSpecialTagName', 'Function')
  link('htmlArg',            none)
  link('htmlLink',           none)


  -- Language: CSS
  -- Syntax: built-in
  link('cssTagName',           'Function')
  link('cssColor',             'Number')
  link('cssVendor',            none)
  link('cssBraces',            none)
  link('cssSelectorOp',        none)
  link('cssSelectorOp2',       none)
  link('cssIdentifier',        none)
  link('cssClassName',         none)
  link('cssClassNameDot',      none)
  link('cssVendor',            none)
  link('cssImportant',         none)
  link('cssAttributeSelector', none)


  -- Language: PHP
  -- Syntax: built-in
  link('phpNullValue', 'Boolean')
  link('phpSpecialFunction',   'Function')
  link('phpParent',    none)
  link('phpClasses',   none)


  -- Language: Javascript
  -- Syntax: built-in
  link('javaScriptNumber',   'Number')
  link('javaScriptNull',     'Number')
  link('javaScriptBraces',    none)
  link('javaScriptFunction',  none)
  link('javaScript',        normal)


  -- Language: Typescript
  -- Syntax: built-in
  link('typescriptImport', none)
  link('typescriptExport', none)
  link('typescriptBraces', none)
  link('typescriptDecorator', none)
  link('typescriptParens', none)
  link('typescriptCastKeyword', none)


  -- Python
  link('pythonDecorator',     'Special')
  link('pythonDecoratorName', none)
  link('pythonBuiltin',       none)

  -- Treesitter
  link('@variable', normal)
  link('@function.call', 'Function')
  link('@function.builtin', 'Function')
  link('@punctuation.bracket', none)
  link('@constant.builtin', 'Number')
  link('@constructor', none)
  link('@type.css', 'Function')
  link('@constructor.php', 'Function')
  link('@method.vue', none)
  link('@tag.delimiter', 'Special')
  link('@tag.attribute', none)
  link('@tag', 'Function')
  link('@text.uri.html', 'String')
  link('@text.literal', none)
  link('@text.literal.vimdoc', normal)
  link('@text.literal.vimdoc', normal)

  link('@variable.builtin.php', normal)

  link('@tag.delimiter.twig', normal)
  link('@punctuation.bracket.twig', normal)

  link('@string.special.url.html', 'String')

  link('@markup.link.markdown_inline', normal)
  link('@markup.link.label.markdown_inline', normal)
  link('@markup.link.url.markdown_inline', normal)
  link('@markup.raw.block.markdown', normal)
  link('@punctuation.special.markdown', normal)
  link('@markup.raw.block.vimdoc', normal)
end

function cs.terminal(theme)
  vim.g.terminal_color_foreground = cs.FG.gui
  vim.g.terminal_color_background = cs.BG.gui

  -- black
  vim.g.terminal_color_0  = theme.black
  vim.g.terminal_color_8  = theme.bright_black or theme.black

  -- red
  vim.g.terminal_color_1  = theme.red
  vim.g.terminal_color_9  = theme.bright_red or theme.red

  -- green
  vim.g.terminal_color_2  = theme.green
  vim.g.terminal_color_10 = theme.bright_green or theme.green

  -- yellow
  vim.g.terminal_color_3  = theme.yellow
  vim.g.terminal_color_11 = theme.bright_yellow or theme.yellow

  -- blue
  vim.g.terminal_color_4  = theme.blue
  vim.g.terminal_color_12 = theme.bright_blue or theme.blue

  -- magenta
  vim.g.terminal_color_5  = theme.magenta
  vim.g.terminal_color_13 = theme.bright_magenta or theme.magenta

  -- cyan
  vim.g.terminal_color_6  = theme.cyan
  vim.g.terminal_color_14 = theme.bright_cyan or theme.cyan

  -- white
  vim.g.terminal_color_7  = theme.white
  vim.g.terminal_color_15 = theme.bright_white or theme.white
end

cs.apply(theme)

