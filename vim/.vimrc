
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Vimrc: configuration for vim, gvim, neovim and neovim-qt.
"        set 'Global settings' before using this vimrc.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

"===============================================================================
" My Notes
"===============================================================================
" {{{
" Help {{{
    " help/h        : 查看Vim帮助
    " <S-k>         : 快速查看光标所在cword或选择内容的vim帮助
    " h *@en        : 指定查看英文(en，cn即为中文)帮助
    " h index       : 帮助列表
    " h range       : Command范围
    " h pattern     : 匹配模式
    " h magic       : Magic匹配模式
    " h Visual      : Visual模式
    " h map-listing : 映射命令
    " h registers   : 寄存器列表
" }}}

" Map {{{
    " - Normal模式下使用<leader>代替<C-?>,<S-?>,<A-?>，
    " - Insert模式下map带ctrl,alt的快捷键
    " - 尽量不改变vim原有键位的功能定义
    " - 尽量一只手不同时按两个键，且连续按键相隔尽量近
    " - 尽量不映射偏远的按键（F1~F12，数字键等），且集中于'j,k,i,o'键位附近
    " - 调换Esc和CapsLock键
"  }}}

" Software {{{
    " Python      : 需要在vim编译时添加Python支持
    " LLVM(Clang) : YouCompleteMe补全
    " fzf         : Fzf模糊查找
    " ripgrep     : Rg文本查找
    " ctags       : tags生成
    " cflow       : c语言函数调用流程分析
    " astyle      : 代码格式化工具
    " graphviz    : 画图工具
    " fireFox     : Markdown,ReStructruedText等标记文本预览
" }}}
" }}}

"===============================================================================
" Platform
"===============================================================================
" {{{
" vim or nvim, with or without gui
" {{{
function! IsVim()
    return !(has('nvim'))
endfunction
function! IsNVim()
    return (has('nvim'))
endfunction
function! IsGVim()
    return has('gui_running')
endfunction
function! IsNVimQt()
    " 只在VimEnter之后起作用
    return exists('g:GuiLoaded')
endfunction
" }}}

" linux or win
" {{{
function! IsLinux()
    return (has('unix') && !has('macunix') && !has('win32unix'))
endfunction
function! IsWin()
    return (has('win32') || has('win64'))
endfunction
function! IsGw()
    " GNU for windows
    return (has('win32unix'))
endfunction
function! IsMac()
    return (has('mac'))
endfunction
" }}}

" term
" {{{
function! IsTermType(tt)
    if &term ==? a:tt
        return 1
    else
        return 0
    endif
endfunction
" }}}
" }}}

"===============================================================================
" Global settings
"===============================================================================
" {{{
set encoding=utf-8                      " 内部使用utf-8编码
if IsVim()
    set nocompatible                    " 不兼容vi
endif
let mapleader="\<Space>"
nnoremap ; :
nnoremap : ;
vnoremap ; :

let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
if (IsLinux() || IsMac())
    " 链接root-vimrc到user's vimrc
    let $DotVimPath=s:home . '/.vim'
elseif IsWin()
    let $DotVimPath=s:home . '\vimfiles'
    " windows下将HOME设置VIM的安装路径
    let $HOME=$VIM
elseif IsGw()
    let $DotVimPath='/c/MyApps/Vim/vimfiles'
endif
set rtp+=$DotVimPath

" s:gset {{{
let s:gset_file = $DotVimPath . '/.gset'
let s:gset = {
    \ 'use_powerfont' : 1,
    \ 'use_fzf' : 1,
    \ 'use_lightline': 1,
    \ 'use_startify' : 1,
    \ 'use_ycm' : 1,
    \ }
" FUNCTION: s:loadGset() {{{
function! s:loadGset()
    if filereadable(s:gset_file)
        call extend(s:gset, json_decode(join(readfile(s:gset_file))), 'force')
    else
        call s:saveGset()
    endif
endfunction
" }}}
" FUNCTION: s:saveGset() {{{
function! s:saveGset()
    call writefile([json_encode(s:gset)], s:gset_file)
    echo 's:gset save successful!'
endfunction
" }}}
" FUNCTION: s:initGset() {{{
function! s:initGset()
    for [key, val] in items(s:gset)
        let s:gset[key] = input('let s:gset.'. key . ' = ', val)
    endfor
    redraw
    call s:saveGset()
endfunction
" }}}
command! -nargs=0 GSLoad :call s:loadGset()
command! -nargs=0 GSSave :call s:saveGset()
command! -nargs=0 GSInit :call s:initGset()
call s:loadGset()
" }}}

" s:path {{{
let s:path = {
    \ 'env'     : 'x86',
    \ 'make'    : '',
    \ 'qmake'   : '',
    \ 'vcvars'  : '',
    \ 'browser' : '',
    \ }
" FUNCTION: s:path.init() dict {{{
function! s:path.init() dict
    if IsWin()
        let self.vcvars32  = 'D:/VS2017/VC/Auxiliary/Build/vcvars32.bat'
        let self.vcvars64  = 'D:/VS2017/VC/Auxiliary/Build/vcvars64.bat'
        let self.qmake_x86 = 'D:/Qt/5.10.1/msvc2017_64/bin/qmake.exe'
        let self.qmake_x64 = 'D:/Qt/5.10.1/msvc2017_64/bin/qmake.exe'
        let self.make      = 'nmake.exe'
        let self.qmake     = self.qmake_x64
        let self.vcvars    = self.vcvars64
    elseif IsLinux()
        let self.make      = 'make'
        let self.qmake     = 'qmake'
    endif
    if (IsWin() || IsGw())
        let self.browser_chrome = 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe'
        let self.browser_firefox = 'D:/Mozilla Firefox/firefox.exe'
    elseif IsLinux()
        let self.browser_chrome = '/usr/bin/chrome'
        let self.browser_firefox = '/usr/bin/firefox'
    endif
    let self.browser = self.browser_firefox
endfunction
" }}}
" FUNCTION: s:path.toggleEnv() dict {{{
function! s:path.toggleEnv() dict
    " 切换成x86或x64编译环境
    if IsWin()
        if 'x86' ==# self.env
            let self.env = 'x64'
            let self.qmake  = self.qmake_x64
            let self.vcvars = self.vcvars64
        else
            let self.env = 'x86'
            let self.qmake  = self.qmake_x86
            let self.vcvars = self.vcvars32
        endif
    endif
endfunction
" }}}
" FUNCTION: s:path.toggleBrowser() dict {{{
function! s:path.toggleBrowser() dict
    if self.browser ==# self.browser_firefox
        let self.browser = self.browser_chrome
    else
        let self.browser = self.browser_firefox
    endif
endfunction
" }}}
" FUNCTION: TogglePath(flg) {{{
function! TogglePath(flg)
    if a:flg ==# 'env'
        call s:path.toggleEnv()
        echo 's:path env: ' . s:path.env
    elseif a:flg ==# 'browser'
        call s:path.toggleBrowser()
        echo 's:path browser: ' . s:path.browser
    endif
endfunction
" }}}
call s:path.init()
" }}}

" KeyCode {{{
set timeout                             " 打开映射超时检测
set ttimeout                            " 打开键码超时检测
set timeoutlen=1000                     " 映射超时时间为1000ms
set ttimeoutlen=70                      " 键码超时时间为70ms

if IsVim()
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <Esc>x 编码
    " 以下三种方法都可以使按下 Alt+x 后，执行 CmdTest 命令，但超时检测有区别
    "<1> set <M-x>=x  " 设置键码，这里的是一个字符，即<Esc>的编码，不是^和[放在一起
                        " 在终端的Insert模式，按Ctrl+v再按Alt+x可输入
    "    nnoremap <M-x> :CmdTest<CR>    " 按键码超时时间检测
    "<2> nnoremap <Esc>x :CmdTest<CR>   " 按映射超时时间检测
    "<3> nnoremap x  :CmdTest<CR>     " 按映射超时时间检测
    set <M-d>=d
    set <M-f>=f
    set <M-h>=h
    set <M-j>=j
    set <M-k>=k
    set <M-l>=l
    set <M-u>=u
    set <M-i>=i
    set <M-o>=o
    set <M-p>=p
    set <M-n>=n
    set <M-m>=m
endif

" }}}
" }}}

"===============================================================================
" Plug Settings
"===============================================================================
" {{{
call plug#begin($DotVimPath.'/bundle')  " 可选设置，可以指定插件安装位置

" 基本编辑
" {{{
" easy-motion {{{ 快速跳转
    Plug 'easymotion/vim-easymotion'
    let g:EasyMotion_do_mapping = 0     " 禁止默认map
    let g:EasyMotion_smartcase = 1      " 不区分大小写
    nmap s <Plug>(easymotion-overwin-f)
    nmap <leader>ms <Plug>(easymotion-overwin-f2)
                                        " 跨分屏快速跳转到字母
    nmap <leader>j <Plug>(easymotion-j)
    nmap <leader>k <Plug>(easymotion-k)
    nmap <leader>mw <Plug>(easymotion-w)
    nmap <leader>mb <Plug>(easymotion-b)
    nmap <leader>me <Plug>(easymotion-e)
    nmap <leader>mg <Plug>(easymotion-ge)
    nmap <leader>mW <Plug>(easymotion-W)
    nmap <leader>mB <Plug>(easymotion-B)
    nmap <leader>mE <Plug>(easymotion-E)
    nmap <leader>mG <Plug>(easymotion-gE)
    "
" }}}

" multiple-cursors {{{ 多光标编辑
    Plug 'terryma/vim-multiple-cursors'
    let g:multi_cursor_use_default_mapping=0
                                        " 取消默认按键
    let g:multi_cursor_start_key='<C-n>'
                                        " 进入Multiple-cursors Model
                                        " 可以自己选定区域（包括矩形选区），或自动选择当前光标<cword>
    let g:multi_cursor_next_key='<C-n>'
    let g:multi_cursor_prev_key='<C-p>'
    let g:multi_cursor_skip_key='<C-x>'
    let g:multi_cursor_quit_key='<Esc>'
" }}}

" textmanip {{{ 块编辑
    Plug 't9md/vim-textmanip'
    let g:textmanip_enable_mappings = 0
    function! SetTextmanipMode(mode)
        let g:textmanip_current_mode = a:mode
        echo 'textmanip mode: ' . g:textmanip_current_mode
    endfunction

    " 切换Insert/Replace Mode
    xnoremap <M-i> :<C-U>call SetTextmanipMode('insert')<CR>gv
    xnoremap <M-o> :<C-U>call SetTextmanipMode('replace')<CR>gv
    " C-i 与 <Tab>等价
    xnoremap <C-i> :<C-U>call SetTextmanipMode('insert')<CR>gv
    xnoremap <C-o> :<C-U>call SetTextmanipMode('replace')<CR>gv
    " 更据Mode使用Move-Insert或Move-Replace
    xmap <C-j> <Plug>(textmanip-move-down)
    xmap <C-k> <Plug>(textmanip-move-up)
    xmap <C-h> <Plug>(textmanip-move-left)
    xmap <C-l> <Plug>(textmanip-move-right)
    " 更据Mode使用Duplicate-Insert或Duplicate-Replace
    xmap <M-j> <Plug>(textmanip-duplicate-down)
    xmap <M-k> <Plug>(textmanip-duplicate-up)
    xmap <M-h> <Plug>(textmanip-duplicate-left)
    xmap <M-l> <Plug>(textmanip-duplicate-right)
"}}}

" vim-over {{{ 替换预览
    Plug 'osyo-manga/vim-over'
    nnoremap <leader>sp :OverCommandLine<CR>
    vnoremap <leader>sp :OverCommandLine<CR>
" }}}

" incsearch {{{ 查找预览
    Plug 'haya14busa/incsearch.vim'
    Plug 'haya14busa/incsearch-fuzzy.vim'
    let g:incsearch#auto_nohlsearch = 1 " 停止搜索时，自动关闭高亮

    " 设置查找时页面滚动映射
    augroup PluginIncsearch
        autocmd!
        autocmd VimEnter * call s:incsearchKeymap()
    augroup END
    function! s:incsearchKeymap()
        if exists('g:loaded_incsearch')
            IncSearchNoreMap <C-j> <Over>(incsearch-next)
            IncSearchNoreMap <C-k> <Over>(incsearch-prev)
            IncSearchNoreMap <M-j> <Over>(incsearch-scroll-f)
            IncSearchNoreMap <M-k> <Over>(incsearch-scroll-b)
        endif
    endfunction
    function! PreviewPattern(prompt)
        " 预览pattern
        let l:old_pat = histget('/', -1)
        try
            call incsearch#call({
                                    \ 'command': '/',
                                    \ 'is_stay': 1,
                                    \ 'prompt': a:prompt
                                \})
        " E117: 函数不存在
        catch /^Vim\%((\a\+)\)\=:E117/
            return ''
        endtry
        let l:pat = histget('/', -1)
        return (l:pat ==# l:old_pat) ? '' : l:pat
    endfunction

    nmap /  <Plug>(incsearch-forward)
    nmap ?  <Plug>(incsearch-backward)
    nmap g/ <Plug>(incsearch-stay)
    nmap z/ <Plug>(incsearch-fuzzy-/)
    nmap z? <Plug>(incsearch-fuzzy-?)
    nmap zg/ <Plug>(incsearch-fuzzy-stay)
    nmap n  <Plug>(incsearch-nohl-n)
    nmap N  <Plug>(incsearch-nohl-N)
    " *,#使用\< \>，而g*,g# 不使用\< \>
    nmap *  <Plug>(incsearch-nohl-*)
    nmap #  <Plug>(incsearch-nohl-#)
    nmap g* <Plug>(incsearch-nohl-g*)
    nmap g# <Plug>(incsearch-nohl-g#)
    nmap <leader>8  <Plug>(incsearch-nohl-*)
    nmap <leader>3  <Plug>(incsearch-nohl-#)
    nmap <leader>g8 <Plug>(incsearch-nohl-g*)
    nmap <leader>g3 <Plug>(incsearch-nohl-g#)
" }}}

" Fzf {{{ 模糊查找
if s:gset.use_fzf
    " linux下直接pacman -S fzf
    " win下载fzf.exe放入bundle/fzf/bin/下
    if IsWin()
        Plug 'junegunn/fzf'
    endif
    Plug 'junegunn/fzf.vim'
    let g:fzf_command_prefix = 'Fzf'
    nnoremap <leader><leader>f :call feedkeys(':FzfFiles ', 'n')<CR>
endif
" }}}

" LeaderF {{{ 模糊查找
if IsLinux()
    Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
    augroup PluginLeaderF
        autocmd!
        autocmd VimEnter * autocmd! LeaderF_Mru
    augroup END
elseif IsWin()
    Plug 'Yggdroot/LeaderF', { 'do': './install.bat' }
else
    Plug 'Yggdroot/LeaderF'
endif
    let g:Lf_CacheDirectory = $DotVimPath
if s:gset.use_powerfont
    let g:Lf_StlSeparator = {'left': '', 'right': ''}
else
    let g:Lf_StlSeparator = {'left': '', 'right': ''}
endif
    let g:Lf_ShortcutF = ''
    let g:Lf_ShortcutB = ''
    let g:Lf_ReverseOrder = 1
    nnoremap <leader><leader>l :call feedkeys(':LeaderfFile ', 'n')<CR>
    nnoremap <leader>lf :LeaderfFile<CR>
    nnoremap <leader>lu :LeaderfFunction<CR>
    nnoremap <leader>lU :LeaderfFunctionAll<CR>
    nnoremap <leader>ll :LeaderfLine<CR>
    nnoremap <leader>lL :LeaderfLineAll<CR>
    nnoremap <leader>lb :LeaderfBuffer<CR>
    nnoremap <leader>lB :LeaderfBufferAll<CR>
    nnoremap <leader>lr :LeaderfRgInteractive<CR>
" }}}

" grep {{{ 大范围查找
if IsVim()
    Plug 'yehuohan/grep'                " 不支持neovim
endif
    Plug 'mhinz/vim-grepper', {'on': ['Grepper', '<plug>(GrepperOperator)']}
    let g:grepper = {
        \ 'rg': {
            \ 'grepprg':    'rg -H --no-heading --vimgrep' . (has('win32') ? ' $*' : ''),
            \ 'grepformat': '%f:%l:%c:%m',
            \ 'escape':     '\^$.*+?()[]{}|'}
        \}
" }}}

" far {{{ 查找与替换
    Plug 'brooth/far.vim'
    let g:far#file_mask_favorites = ['%', '*.txt']
    nnoremap <leader>sr :Farp<CR>
                                        " Search and Replace, 使用Fardo和Farundo来更改替换结果
    nnoremap <leader>fd :Fardo<CR>
    nnoremap <leader>fu :Farundo<CR>
" }}}

" tabular {{{ 字符对齐
    Plug 'godlygeek/tabular'
    " /,/r2l0   -   第1个field使用第1个对齐符（右对齐），再插入2个空格
    "               第2个field使用第2个对齐符（左对齐），再插入0个空格
    "               第3个field又重新从第1个对齐符开始（对齐符可以有多个，循环使用）
    "               这样就相当于：需对齐的field使用第1个对齐符，分割符(,)field使用第2个对齐符
    " /,\zs     -   将分割符(,)作为对齐内容field里的字符
    nnoremap <leader><leader>a :call feedkeys(':Tabularize /', 'n')<CR>
    vnoremap <leader><leader>a :Tabularize /
" }}}

" easy-align {{{ 字符对齐
    Plug 'junegunn/vim-easy-align'
    " 默认对齐内含段落（Text Object: vip）
    nmap <leader>ga <Plug>(EasyAlign)ip
    xmap <leader>ga <Plug>(EasyAlign)
    " 命令格式
    ":EasyAlign[!] [N-th]DELIMITER_KEY[OPTIONS]
    ":EasyAlign[!] [N-th]/REGEXP/[OPTIONS]
    nnoremap <leader><leader>g :call feedkeys(EasyAlignParagraph(), 'n')<CR>
    vnoremap <leader><leader>g :EasyAlign
    function! EasyAlignParagraph()
        let l:start = search('^[ \t]*$', 'bn')
        let l:cur = line('.')
        let l:end = search('^[ \t]*$', 'n')
        let l:start = (l:start == 0 || l:start >= l:cur) ? 1 : (l:start + 1)
        let l:end = (l:end == 0 || l:end <= l:cur) ? line('$') : (l:end - 1)
        return ':' . string(l:start) . ',' . string(l:end) . 'EasyAlign '
    endfunction
" }}}

" smooth-scroll {{{ 平滑滚动
    Plug 'terryma/vim-smooth-scroll'
    nnoremap <M-n> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    nnoremap <M-m> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    nnoremap <M-j> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    nnoremap <M-k> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
" }}}

" expand-region {{{ 快速块选择
    Plug 'terryma/vim-expand-region'
    nmap <C-p> <Plug>(expand_region_expand)
    vmap <C-p> <Plug>(expand_region_expand)
    nmap <C-u> <Plug>(expand_region_shrink)
    vmap <C-u> <Plug>(expand_region_shrink)
" }}}

" vim-textobj-user {{{ 文本对象
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'
    let g:textobj_indent_no_default_key_mappings=1
    omap aI <Plug>(textobj-indent-a)
    omap iI <Plug>(textobj-indent-i)
    omap ai <Plug>(textobj-indent-same-a)
    omap ii <Plug>(textobj-indent-same-i)
    vmap aI <Plug>(textobj-indent-a)
    vmap iI <Plug>(textobj-indent-i)
    vmap ai <Plug>(textobj-indent-same-a)
    vmap ii <Plug>(textobj-indent-same-i)
    Plug 'kana/vim-textobj-function'
    Plug 'glts/vim-textobj-comment'
    Plug 'adriaanzon/vim-textobj-matchit'
    Plug 'lucapette/vim-textobj-underscore'
    omap au <Plug>(textobj-underscore-a)
    omap iu <Plug>(textobj-underscore-i)
    vmap au <Plug>(textobj-underscore-a)
    vmap iu <Plug>(textobj-underscore-i)
" }}}

" vim-repeat {{{ 重复命令
    Plug 'tpope/vim-repeat'
    function! SetRepeatExecution(string)
        let s:execution = a:string
        try
            call repeat#set("\<Plug>RepeatExecute", v:count)
        " E117: 函数不存在
        catch /^Vim\%((\a\+)\)\=:E117/
        endtry
    endfunction
    function! RepeatExecute()
        if exists('s:execution') && !empty(s:execution)
            execute s:execution
        endif
    endfunction
    nnoremap <Plug>RepeatExecute :call RepeatExecute()<CR>
    nnoremap <leader>. :call RepeatExecute()<CR>
" }}}
" }}}

" 界面管理
" {{{
" theme {{{ Vim主题(ColorScheme, StatusLine, TabLine)
    Plug 'morhetz/gruvbox'
    set rtp+=$DotVimPath/bundle/gruvbox/
    let g:gruvbox_contrast_dark='soft'  " 背景选项：dark, medium, soft
    Plug 'junegunn/seoul256.vim'
    set rtp+=$DotVimPath/bundle/seoul256.vim/
    let g:seoul256_background=236       " 233(暗) ~ 239(亮)
    let g:seoul256_light_background=256 " 252(暗) ~ 256(亮)
    Plug 'altercation/vim-colors-solarized'
    set rtp+=$DotVimPath/bundle/vim-colors-solarized/
if s:gset.use_lightline
    Plug 'itchyny/lightline.vim'
    "                    
    " ► ✘ ⌘ ▫ ▪ ★ ☆ • ≡ ፨ ♥
    let g:lightline = {
        \ 'enable' : {'statusline': 1, 'tabline': 0},
        \ 'colorscheme' : 'gruvbox',
        \ 'active': {
                \ 'left' : [['mode'],
                \           ['all_filesign'],
                \           ['msg_left']],
                \ 'right': [['all_lineinfo', 'chk_indent', 'chk_trailing'],
                \           ['all_format'],
                \           ['msg_right']],
                \ },
        \ 'inactive': {
                \ 'left' : [['absolutepath']],
                \ 'right': [['lite_info']],
                \ },
        \ 'tabline' : {
                \ 'left' : [['tabs']],
                \ 'right': [['close']],
                \ },
        \ 'component': {
                \ 'all_filesign': '%{winnr()},%-n%{&ro?" ":""}%M',
                \ 'all_format'  : '%{&ft!=#""?&ft." • ":""}%{&fenc!=#""?&fenc:&enc}[%{&ff}]',
                \ 'all_lineinfo': '0X%02B ≡%3p%%   %04l/%L  %-2v',
                \ 'lite_info'   : '%p%%≡%L',
                \ },
        \ 'component_function': {
                \ 'mode'        : 'LightlineMode',
                \ 'msg_left'    : 'LightlineMsgLeft',
                \ 'msg_right'   : 'LightlineMsgRight',
                \ 'chk_indent'  : 'LightlineCheckMixedIndent',
                \ 'chk_trailing': 'LightlineCheckTrailing',
                \ },
        \ }
    if s:gset.use_powerfont
        let g:lightline.separator            = {'left': '', 'right': ''}
        let g:lightline.subseparator         = {'left': '', 'right': ''}
        let g:lightline.tabline_separator    = {'left': '', 'right': ''}
        let g:lightline.tabline_subseparator = {'left': '', 'right': ''}
    endif
    try
        set background=dark
        colorscheme gruvbox
    " E185: 找不到主题
    catch /^Vim\%((\a\+)\)\=:E185/
        silent! colorscheme desert
        let g:lightline.colorscheme = 'solarized'
    endtry
    let s:lightline_check_flg = 1       " 是否检测Tab和Trailing
    nnoremap <leader>tl :call lightline#toggle()<CR>

    " Augroup: PluginLightline {{{
    augroup PluginLightline
        autocmd!
        autocmd ColorScheme * call s:lightlineColorScheme()
        autocmd BufReadPre * call s:lightlineCheck(getfsize(expand('<afile>')))
    augroup END
    function! s:lightlineColorScheme()
        if !exists('g:loaded_lightline')
            return
        endif
        try
            let g:lightline.colorscheme = g:colors_name
            call lightline#init()
            call lightline#colorscheme()
            call lightline#update()
        " E117: 函数不存在
        catch /^Vim\%((\a\+)\)\=:E117/
        endtry
    endfunction
    function! s:lightlineCheck(size)
        let s:lightline_check_flg = (a:size > 1024*1024*2 || a:size == -2) ? 0 : 1
    endfunction
    " }}}
    " FUNCTION: LightlineMode() {{{
    function! LightlineMode()
        let fname = expand('%:t')
        return fname == '__Tagbar__' ? 'Tagbar' :
            \ fname =~ 'NERD_tree' ? 'NERDTree' :
            \ &ft ==# 'qf' ? (QuickfixGet()[0] ==# 'q' ? 'Quickfix' : 'Location') :
            \ &ft ==# 'help' ? 'Help' :
            \ &ft ==# 'Popc' ? popc#ui#GetStatusLineSegments('l')[0] :
            \ &ft ==# 'startify' ? 'Startify' :
            \ winwidth(0) > 60 ? lightline#mode() : ''
    endfunction
    " }}}
    " FUNCTION: LightlineMsgLeft() {{{
    function! LightlineMsgLeft()
        if &ft ==# 'qf'
            return 'CWD = ' . getcwd()
        else
            let l:fw = FindWorkingGet()
            let l:fp = fnamemodify(expand('%'), ':p')
            return empty(l:fw) ? l:fp : substitute(l:fp, escape(l:fw[0], '\'), '...', '')
        endif
    endfunction
    " }}}
    " FUNCTION: LightlineMsgRight() {{{
    function! LightlineMsgRight()
        let l:fw = FindWorkingGet()
        return empty(l:fw) ? '' : (l:fw[0] . '[' . l:fw[1] .']')
    endfunction
    " }}}
    " FUNCTION: LightlineCheckMixedIndent() {{{
    function! LightlineCheckMixedIndent()
        if !s:lightline_check_flg
            return ''
        endif
        let l:ret = search('\t', 'nw')
        return (l:ret == 0) ? '' : 'I:'.string(l:ret)
    endfunction
    " }}}
    " FUNCTION: LightlineCheckTrailing() {{{
    function! LightlineCheckTrailing()
        if !s:lightline_check_flg
            return ''
        endif
        let ret = search('\s\+$', 'nw')
        return (l:ret == 0) ? '' : 'T:'.string(l:ret)
    endfunction
    " }}}
endif
" }}}

" rainbow {{{ 彩色括号
    Plug 'luochen1990/rainbow'
    let g:rainbow_active = 1
    nnoremap <leader>tr :RainbowToggle<CR>
" }}}

" indent-line {{{ 显示缩进标识
    Plug 'Yggdroot/indentLine'
    "let g:indentLine_char = '|'        " 设置标识符样式
    let g:indentLinet_color_term=200    " 设置标识符颜色
    nnoremap <leader>ti :IndentLinesToggle<CR>
" }}}

" Pop Selection {{{ 弹出选项
    Plug 'yehuohan/popset'
    let g:Popset_SelectionData = [
        \{
            \ 'opt' : ['filetype', 'ft'],
            \ 'dsr' : 'When this option is set, the FileType autocommand event is triggered.',
            \ 'lst' : ['cpp', 'c', 'python', 'vim', 'go', 'markdown', 'help', 'text',
                     \ 'sh', 'matlab', 'conf', 'make', 'javascript', 'json', 'html'],
            \ 'dic' : {
                    \ 'cpp'        : 'Cpp file',
                    \ 'c'          : 'C file',
                    \ 'python'     : 'Python script file',
                    \ 'vim'        : 'Vim script file',
                    \ 'go'         : 'Go Language',
                    \ 'markdown'   : 'MarkDown file',
                    \ 'help'       : 'Vim help doc',
                    \ 'sh'         : 'Linux shell script',
                    \ 'conf'       : 'Config file',
                    \ 'make'       : 'Makefile of .mak file',
                    \ 'javascript' : 'JavaScript file',
                    \ 'json'       : 'Json file',
                    \ 'html'       : 'Html file',
                    \},
            \ 'cmd' : 'popset#data#SetEqual',
        \},
        \{
            \ 'opt' : ['colorscheme', 'colo'],
            \ 'lst' : ['gruvbox', 'seoul256', 'seoul256-light', 'solarized'],
            \ 'cmd' : '',
        \},]
    " set option with PSet
    nnoremap <leader><leader>s :call feedkeys(':PSet ', 'n')<CR>
    nnoremap <leader>sa :PSet popset<CR>
" }}}

" popc {{{ buffer管理
    Plug 'yehuohan/popc'
    set hidden
    let g:Popc_jsonPath = $DotVimPath
    let g:Popc_useTabline = 1
    let g:Popc_useStatusline = 1
    let g:Popc_usePowerFont = s:gset.use_powerfont
    let g:Popc_separator = {'left' : '', 'right': ''}
    let g:Popc_subSeparator = {'left' : '', 'right': ''}
    nnoremap <C-Space> :Popc<CR>
    inoremap <C-Space> <Esc>:Popc<CR>
    nnoremap <leader><leader>h :PopcBuffer<CR>
    nnoremap <M-i> :PopcBufferSwitchLeft<CR>
    nnoremap <M-o> :PopcBufferSwitchRight<CR>
    nnoremap <leader><leader>b :PopcBookmark<CR>
    nnoremap <leader><leader>w :PopcWorkspace<CR>
    nnoremap <leader>wf :call PopcWksSearch()<CR>
    function! PopcWksSearch()
        let l:wks_root = popc#layer#wks#GetCurrentWks()[1]
        if !empty(l:wks_root)
            execute ':LeaderfFile ' . l:wks_root
        endif
    endfunction
" }}}

" nerd-tree {{{ 目录树导航
    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTree']}
    let g:NERDTreeShowHidden=1
    let g:NERDTreeMapPreview = 'go'     " 预览打开
    let g:NERDTreeMapChangeRoot = 'cd'  " 更改根目录
    let g:NERDTreeMapChdir = 'CW'       " 更改CWD
    let g:NERDTreeMapCWD = 'CD'         " 更改根目录为CWD
    let g:NERDTreeMapJumpNextSibling = '<C-n>'
                                        " 下一个Sibling
    let g:NERDTreeMapJumpPrevSibling = '<C-p>'
                                        " 前一个Sibling
    nnoremap <leader>te :NERDTreeToggle<CR>
    nnoremap <leader>tE :execute ':NERDTree ' . expand('%:p:h')<CR>
    augroup PluginNerdtree
        autocmd!
        autocmd BufEnter * if exists('b:NERDTree') | let &l:statusline='%{b:NERDTree.root.path.str()}' | endif
    augroup END
" }}}

" vim-startify {{{ vim会话界面
if s:gset.use_startify
    Plug 'mhinz/vim-startify'
    if IsLinux()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'},
                                    \ '~/.zshrc',
                                    \ '~/.config/i3/config',
                                    \ '~/.config/nvim/init.vim'
                                    \]
    elseif IsWin()
        let g:startify_bookmarks = [ {'c': '$DotVimPath/../_vimrc'},
                                    \ '$DotVimPath/../vimfiles/.ycm_extra_conf.py',
                                    \ '$APPDATA/../Local/nvim/init.vim'
                                    \]
    elseif IsMac()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'}, '~/.zshrc']
    endif
    let g:startify_lists = [
            \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
            \ {'type': 'files',     'header': ['   Recent Files']},
            \ ]
    nnoremap <leader>su :Startify<CR>   " start ui of vim-startify
endif
" }}}

" bookmarks {{{ 书签管理
    Plug 'kshenoy/vim-signature'
    let g:SignatureMap = {
        \ 'Leader'             :  "m",
        \ 'PlaceNextMark'      :  "m,",
        \ 'ToggleMarkAtLine'   :  "m.",
        \ 'PurgeMarksAtLine'   :  "m-",
        \ 'DeleteMark'         :  "dm",
        \ 'PurgeMarks'         :  "m<Space>",
        \ 'PurgeMarkers'       :  "m<BS>",
        \ 'GotoNextLineAlpha'  :  "']",
        \ 'GotoPrevLineAlpha'  :  "'[",
        \ 'GotoNextSpotAlpha'  :  "`]",
        \ 'GotoPrevSpotAlpha'  :  "`[",
        \ 'GotoNextLineByPos'  :  "]'",
        \ 'GotoPrevLineByPos'  :  "['",
        \ 'GotoNextSpotByPos'  :  "]`",
        \ 'GotoPrevSpotByPos'  :  "[`",
        \ 'GotoNextMarker'     :  "]-",
        \ 'GotoPrevMarker'     :  "[-",
        \ 'GotoNextMarkerAny'  :  "]=",
        \ 'GotoPrevMarkerAny'  :  "[=",
        \ 'ListBufferMarks'    :  "m/",
        \ 'ListBufferMarkers'  :  "m?"
    \ }
    nnoremap <leader>tm :SignatureToggleSigns<CR>
    nnoremap <leader>ma :SignatureListBufferMarks<CR>
    nnoremap <leader>mc :<C-U>call signature#mark#Purge('all')<CR>
    nnoremap <leader>mx :<C-U>call signature#marker#Purge()<CR>
    nnoremap <M-d> :<C-U>call signature#mark#Goto('prev', 'line', 'pos')<CR>
    nnoremap <M-f> :<C-U>call signature#mark#Goto('next', 'line', 'pos')<CR>
" }}}

" undo {{{ 撤消历史
    Plug 'mbbill/undotree'
    nnoremap <leader>tu :UndotreeToggle<CR>
" }}}
" }}}

" 代码编写
" {{{
" YouCompleteMe {{{ 自动补全
if s:gset.use_ycm
    " FUNCTION: YcmBuild(info) {{{
    " Completion Params: install.py安装参数
    "   --clang-completer : C-famlily，基于Clang补全，需要安装Clang
    "   --go-completer    : Go，基于Gocode/Godef补全，需要安装Go
    "   --js-completer    : Javascript，基于Tern补全，需要安装node和npm
    "   --java-completer  : Java补全，需要安装JDK8
    " Linux: 使用install.py安装
    "   先安装python-dev, python3-dev, cmake, llvm, clang
    "   "python install.py --clang-completer --go-completer --js-completer --java-completer --system-libclang"
    "   ycm使用python命令指向的版本(如2.7或3.6)
    " Windows: 使用install.py安装
    "   先安装python, Cmake, VS, 7-zip
    "   "python install.py --clang-completer --go-completer --js-completer --java-completer --msvc 15 --build-dir <ycm_build>"
    "   自己指定vs版本，自己指定build路径，编译完成后，可以删除<ycm_build>
    "   如果已经安装了clang，可以使用--system-libclang参数，就不必再下载clang了
    function! YcmBuild(info)
        " info is a dictionary with 3 fields
        " - name:   name of the plugin
        " - status: 'installed', 'updated', or 'unchanged'
        " - force:  set on PlugInstall! or PlugUpdate!
        if a:info.status == 'installed' || a:info.force
            if IsLinux()
                !python install.py --clang-completer --go-completer --java-completer --system-libclang
            elseif IsWin()
                !python install.py --clang-completer --go-completer --java-completer --js-completer --msvc 15 --build-dir ycm_build
            endif
        endif
    endfunction
    " }}}
    Plug 'ycm-core/YouCompleteMe', { 'do': function('YcmBuild') }
    let g:ycm_global_ycm_extra_conf=$DotVimPath.'/.ycm_extra_conf.py'
                                                                " C-family补全路径
    let g:ycm_enable_diagnostic_signs = 1                       " 开启语法检测
    let g:ycm_max_diagnostics_to_display = 30
    let g:ycm_warning_symbol = '►'                              " Warning符号
    let g:ycm_error_symbol = '✘'                                " Error符号
    let g:ycm_auto_start_csharp_server = 0                      " 禁止C#补全
    let g:ycm_cache_omnifunc = 0                                " 禁止缓存匹配项，每次都重新生成匹配项
    let g:ycm_complete_in_strings = 1                           " 开启对字符串补全
    let g:ycm_complete_in_comments = 1                          " 开启对注释补全
    let g:ycm_collect_identifiers_from_comments_and_strings = 0 " 收集注释和字符串补全
    let g:ycm_collect_identifiers_from_tags_files = 1           " 收集标签补全
    let g:ycm_seed_identifiers_with_syntax = 1                  " 收集语法关键字补全
    let g:ycm_use_ultisnips_completer = 1                       " 收集UltiSnips补全
    let g:ycm_autoclose_preview_window_after_insertion = 1      " 自动关闭预览窗口
    let g:ycm_filetype_blacklist = {
        \ 'tagbar': 1,
        \ 'notes': 1,
        \ 'netrw': 1,
        \ 'unite': 1,
        \ 'text': 1,
        \ 'vimwiki': 1,
        \ 'pandoc': 1,
        \ 'infolog': 1,
        \ 'mail': 1
        \ }                                                     " 禁用YCM的列表
    let g:ycm_language_server = []                              " LSP支持
    let g:ycm_key_list_select_completion = ['<C-j>', '<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-k>', '<C-p>', '<Up>']
    let g:ycm_key_list_stop_completion = ['<C-y>']              " 关闭补全menu
    let g:ycm_key_invoke_completion = '<C-l>'                   " 显示补全内容，YCM使用completefunc（C-X C-U）
    let g:ycm_key_detailed_diagnostics = ''                     " 直接map :YcmShowDetailedDiagnostic命令即可
    nnoremap <leader>gt :YcmCompleter GoTo<CR>
    nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
    nnoremap <leader>gD :YcmCompleter GoToDeclaration<CR>
    nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
    nnoremap <leader>gp :YcmCompleter GetParent<CR>
    nnoremap <leader>gk :YcmCompleter GetDoc<CR>
    nnoremap <leader>gy :YcmCompleter GetType<CR>
    nnoremap <leader>gf :YcmCompleter FixIt<CR>
    nnoremap <leader>gc :YcmCompleter ClearCompilationFlagCache<CR>
    nnoremap <leader>gs :YcmCompleter RestartServer<CR>
    nnoremap <leader>yr :YcmRestartServer<CR>
    nnoremap <leader>yd :YcmShowDetailedDiagnostic<CR>
    nnoremap <leader>yD :YcmDiags<CR>
    nnoremap <leader>yc :call YcmCreateConf('.ycm_extra_conf.py')<CR>
    nnoremap <leader>yj :call YcmCreateConf('.tern-project')<CR>
    function! YcmCreateConf(filename)
        " 在当前目录下创建配置文件
        if !filereadable(a:filename)
            let l:file = readfile($DotVimPath . '/' . a:filename)
            call writefile(l:file, a:filename)
        endif
        execute 'edit ' . a:filename
    endfunction
endif
" }}}

" LanguageClient-neovim {{{ 代码补全（使用LSP）
    Plug 'autozimu/LanguageClient-neovim', {
        \ 'branch': 'next',
        \ 'do': IsWin() ? 'powershell -executionpolicy bypass -File install.ps1' : 'bash install.sh',
        \ 'for': 'dart'
        \ }
    " YCM使用completefunc(C-X C-U)
    " LCN使用omnifunc(C-X C-O)
    " YCM不技持的语言，通过LCN(omnifunc)集成到YCM上
    let g:LanguageClient_serverCommands = {
        \ 'dart' : ['dart',
                  \ IsWin() ? 'C:/MyApps/dart-sdk/bin/snapshots/analysis_server.dart.snapshot' : '/opt/dart-sdk/bin/snapshots/analysis_server.dart.snapshot',
                  \ '--lsp'],
        \ }
    let g:LanguageClient_diagnosticsDisplay = {}                " 禁用语法检测
    let g:LanguageClient_diagnosticsSignsMax = 0
    let g:LanguageClient_diagnosticsEnable = 0
    let g:LanguageClient_hasSnippetSupport = 0                  " 禁用snippet支持
" }}}

" ultisnips {{{ 代码片段
    Plug 'yehuohan/ultisnips'           " snippet引擎（vmap的映射，与vim-textmanip的<C-i>有冲突）
    Plug 'honza/vim-snippets'           " snippet合集
    " 使用:UltiSnipsEdit编辑g:UltiSnipsSnippetsDir中的snippet文件
    let g:UltiSnipsSnippetsDir = $DotVimPath . '/mySnippets'
    let g:UltiSnipsSnippetDirectories=['UltiSnips', 'mySnippets']
                                        " 自定义mySnippets合集
    let g:UltiSnipsExpandTrigger='<Tab>'
    let g:UltiSnipsListSnippets='<C-Tab>'
    let g:UltiSnipsJumpForwardTrigger='<C-j>'
    let g:UltiSnipsJumpBackwardTrigger='<C-k>'
" }}}

" ale {{{ 语法检测
    Plug 'dense-analysis/ale'
    " 语法引擎:
    "   VimScript : vint
    let g:ale_completion_enabled = 0    " 使能ale补全(只支持TypeScript)
    let g:ale_linters = {'java' : []}   " 禁用Java检测（与YCM冲突）
    let g:ale_sign_error = '✘'
    let g:ale_sign_warning = '►'
    let g:ale_set_loclist = 1
    let g:ale_set_quickfix = 0
    let g:ale_echo_delay = 10           " 显示语文错误的延时时间
    let g:ale_lint_delay = 300          " 文本更改后的延时检测时间
    let g:ale_enabled = 0               " 默认关闭ALE检测
    nnoremap <leader>ta :execute ':ALEToggle'<Bar>echo 'AleToggle:' . g:ale_enabled<CR>
" }}}

" neoformat {{{ 代码格式化
    Plug 'sbdchd/neoformat'
    let g:neoformat_basic_format_align = 1
    let g:neoformat_basic_format_retab = 1
    let g:neoformat_basic_format_trim = 1
    let g:neoformat_c_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--style=allman'],
        \ 'stdin' : 1,
        \ }
    let g:neoformat_cpp_astyle = g:neoformat_c_astyle
    let g:neoformat_java_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--mode=java --style=google'],
        \ 'stdin' : 1,
        \ }
    let g:neoformat_python_autopep8 = {
        \ 'exe': 'autopep8',
        \ 'args': ['-s 4', '-E'],
        \ 'replace': 1,
        \ 'stdin': 1,
        \ 'env': ['DEBUG=1'],
        \ 'valid_exit_codes': [0, 23],
        \ 'no_append': 1,
        \ }
    let g:neoformat_enabled_c = ['astyle']
    let g:neoformat_enabled_cpp = ['astyle']
    let g:neoformat_enabled_java = ['astyle']
    let g:neoformat_enabled_python = ['autopep8']
    nnoremap <leader>fc :Neoformat<CR>
    vnoremap <leader>fc :Neoformat<CR>
" }}}

" surround {{{ 添加包围符
    Plug 'tpope/vim-surround'
    let g:surround_no_mappings = 1      " 取消默认映射
    " 修改和删除Surround
    nmap <leader>sd <Plug>Dsurround
    nmap <leader>sc <Plug>Csurround
    nmap <leader>sC <Plug>CSurround
    " 给Text Object添加Surround
    nmap ys <Plug>Ysurround
    nmap yS <Plug>YSurround
    nmap <leader>sw ysiw
    nmap <leader>si ysw
    nmap <leader>sW ySiw
    nmap <leader>sI ySw
    " 给行添加Surround
    nmap <leader>sl <Plug>Yssurround
    nmap <leader>sL <Plug>YSsurround
    xmap <leader>sw <Plug>VSurround
    xmap <leader>sW <Plug>VgSurround
" }}}

" auto-pairs {{{ 自动括号
    Plug 'jiangmiao/auto-pairs'
    let g:AutoPairsShortcutToggle=''
    let g:AutoPairsShortcutFastWrap=''
    let g:AutoPairsShortcutJump=''
    let g:AutoPairsShortcutFastBackInsert=''
    nnoremap <leader>tp :call AutoPairsToggle()<CR>
"}}}

" tagbar {{{ 代码结构查看
    Plug 'majutsushi/tagbar'
    if IsLinux()
        let g:tagbar_ctags_bin='/usr/bin/ctags'
    elseif IsWin()
        let g:tagbar_ctags_bin=$VIM.'\vim81\ctags.exe'
    endif                               " 设置ctags路径，需要安装ctags
    let g:tagbar_width=30
    let g:tagbar_map_showproto=''       " 取消tagbar对<Space>的占用
    nnoremap <leader>tt :TagbarToggle<CR>
                                        " 可以 ctags -R 命令自行生成tags
" }}}

" nerd-commenter {{{ 批量注释
    Plug 'scrooloose/nerdcommenter'
    let g:NERDCreateDefaultMappings = 0
    let g:NERDSpaceDelims = 0           " 在Comment后添加Space
    nmap <leader>cc <Plug>NERDCommenterComment
    nmap <leader>cm <Plug>NERDCommenterMinimal
    nmap <leader>cs <Plug>NERDCommenterSexy
    nmap <leader>cb <Plug>NERDCommenterAlignBoth
    nmap <leader>cl <Plug>NERDCommenterAlignLeft
    nmap <leader>ci <Plug>NERDCommenterInvert
    nmap <leader>cy <Plug>NERDCommenterYank
    nmap <leader>ce <Plug>NERDCommenterToEOL
    nmap <leader>ca <Plug>NERDCommenterAppend
    nmap <leader>ct <Plug>NERDCommenterAltDelims
    nmap <leader>cu <Plug>NERDCommenterUncomment
" }}}

" file switch {{{ c/c++文件切换
    Plug 'derekwyatt/vim-fswitch', {'for': ['cpp', 'c']}
    nnoremap <Leader>of :FSHere<CR>
    nnoremap <Leader>os :FSSplitRight<CR>
    let g:fsnonewfiles='on'
" }}}

" AsyncRun {{{ 导步运行程序
    Plug 'skywind3000/asyncrun.vim'
    if IsWin()
        let g:asyncrun_encs = 'cp936'   " 即'gbk'编码
    endif
    nnoremap <leader><leader>r :call feedkeys(':AsyncRun ', 'n')<CR>
    nnoremap <leader>rr :call feedkeys(':AsyncRun ', 'n')<CR>
    nnoremap <leader>rs :AsyncStop<CR>
    augroup PluginAsyncrun
        autocmd!
        autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
    augroup END
" }}}

" vim-quickhl {{{ 单词高亮
    Plug 't9md/vim-quickhl'
    nmap <leader>hw <Plug>(quickhl-manual-this)
    xmap <leader>hw <Plug>(quickhl-manual-this)
    nmap <leader>hs <Plug>(quickhl-manual-this-whole-word)
    xmap <leader>hs <Plug>(quickhl-manual-this-whole-word)
    nmap <leader>hm <Plug>(quickhl-cword-toggle)
    nnoremap <leader>hc :call quickhl#manual#clear_this('n')<CR>
    vnoremap <leader>hc :call quickhl#manual#clear_this('v')<CR>
    nmap <leader>hr <Plug>(quickhl-manual-reset)

    nnoremap <leader>th :QuickhlManualLockWindowToggle<CR>
" }}}

" FastFold {{{ 更新折叠
    Plug 'Konfekt/FastFold'
    nmap <leader>zu <Plug>(FastFoldUpdate)
    let g:fastfold_savehook = 0         " 只允许手动更新folds
    "let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
    "let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
                                        " 允许指定的命令更新folds
" }}}

" cpp-enhanced-highlight {{{ c++语法高亮
    Plug 'octol/vim-cpp-enhanced-highlight', {'for': 'cpp'}
" }}}

" dart-vim-plugin {{{ Julia支持
    Plug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}
" }}}

" dart-vim-plugin {{{ dart语法高亮
    Plug 'dart-lang/dart-vim-plugin', {'for': 'dart'}
" }}}
" }}}

" 软件辅助
" {{{
" vimcdoc {{{ 中文帮助文档
    Plug 'yianwillis/vimcdoc'
" }}}

" MarkDown {{{
    Plug 'gabrielelana/vim-markdown', {'for': 'markdown'}
    let g:markdown_include_jekyll_support = 0
    let g:markdown_enable_mappings = 0
    let g:markdown_enable_spell_checking = 0
    let g:markdown_enable_folding = 1   " 感觉MarkDown折叠引起卡顿时，关闭此项
    let g:markdown_enable_conceal = 1   " 在Vim中显示MarkDown预览

    Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': { -> mkdp#util#install()}}
    let g:mkdp_auto_start = 0
    let g:mkdp_auto_close = 1
    let g:mkdp_refresh_slow = 0         " 即时预览MarkDown
    let g:mkdp_command_for_global = 0   " 只有markdown文件可以预览
    let g:mkdp_browser = s:path.browser
    nnoremap <leader>vm :call ViewMarkdown()<CR>
    function! ViewMarkdown() abort
        let g:mkdp_browser = s:path.browser
        if !get(b:, 'MarkdownPreviewToggleBool')
            echo 'Open markdown preview'
        else
            echo 'Close markdown preview'
        endif
        call mkdp#util#toggle_preview()
    endfunction
" }}}

" reStructruedText {{{
if !(IsWin() && IsNVim())
    " 需要安装 https://github.com/Rykka/instant-rst.py
    Plug 'Rykka/riv.vim', {'for': 'rst'}
    Plug 'Rykka/InstantRst', {'for': 'rst'}
    let g:instant_rst_browser = s:path.browser
if IsWin()
    " 需要安装 https://github.com/mgedmin/restview
    nnoremap <leader>vr :execute ':AsyncRun restview ' . expand('%:p:t')<Bar>cclose<CR>
else
    nnoremap <leader>vr :call ViewRst()<CR>
endif
    function! ViewRst() abort
        if g:_instant_rst_daemon_started
            StopInstantRst
            echo 'StopInstantRst'
        else
            InstantRst
        endif
    endfunction
endif
" }}}

" open-browser.vim {{{ 在线搜索
    Plug 'tyru/open-browser.vim'
    let g:openbrowser_default_search='baidu'
    nmap <leader>bs <Plug>(openbrowser-smart-search)
    vmap <leader>bs <Plug>(openbrowser-smart-search)
    " search funtion - google, baidu, github
    function! OpenBrowserSearchInGoogle(engine, mode)
        if a:mode ==# 'n'
            call openbrowser#search(expand('<cword>'), a:engine)
        elseif a:mode ==# 'v'
            call openbrowser#search(GetSelected(), a:engine)
        endif
    endfunction
    nnoremap <leader>big :call feedkeys(':OpenBrowserSearch -google ', 'n')<CR>
    nnoremap <leader>bg  :call OpenBrowserSearchInGoogle('google', 'n')<CR>
    vnoremap <leader>bg  :call OpenBrowserSearchInGoogle('google', 'v')<CR>
    nnoremap <leader>bib :call feedkeys(':OpenBrowserSearch -baidu ', 'n')<CR>
    nnoremap <leader>bb  :call OpenBrowserSearchInGoogle('baidu', 'n')<CR>
    vnoremap <leader>bb  :call OpenBrowserSearchInGoogle('baidu', 'v')<CR>
    nnoremap <leader>bih :call feedkeys(':OpenBrowserSearch -github ', 'n')<CR>
    nnoremap <leader>bh  :call OpenBrowserSearchInGoogle('github', 'n')<CR>
    vnoremap <leader>bh  :call OpenBrowserSearchInGoogle('github', 'v')<CR>
"}}}
" }}}

call plug#end()                         " required
" }}}

"===============================================================================
" User functions
"===============================================================================
" {{{
" Execute function {{{
" FUNCTION: GetSelected() {{{ 获取选区内容
function! GetSelected()
    let l:reg_var = getreg('0', 1)
    let l:reg_mode = getregtype('0')
    normal! gv"0y
    let l:word = getreg('0')
    call setreg('0', l:reg_var, l:reg_mode)
    return l:word
endfunction
" }}}

" FUNCTION: GetMultiFilesCompletion(arglead, cmdline, cursorpos) {{{ 多文件自动补全
function! GetMultiFilesCompletion(arglead, cmdline, cursorpos)
    let l:complete = []
    let l:arglead_list = ['']
    let l:arglead_first = ''
    let l:arglead_glob = ''
    let l:files_list = []

    " process glob path-string
    if !empty(a:arglead)
        let l:arglead_list = split(a:arglead, ' ')
        let l:arglead_first = join(l:arglead_list[0:-2], ' ')
        let l:arglead_glob = l:arglead_list[-1]
    endif

    " glob non-hidden and hidden files(but no . and ..) with ignorecase
    set wildignorecase
    set wildignore+=.,..
    let l:files_list = split(glob(l:arglead_glob . "*") . "\n" . glob(l:arglead_glob . "\.[^.]*"), "\n")
    set wildignore-=.,..

    if len(l:arglead_list) == 1
        let l:complete = l:files_list
    else
        for item in l:files_list
            call add(l:complete, l:arglead_first . ' ' . item)
        endfor
    endif
    return l:complete
endfunction
" }}}

" FUNCTION: GetFileList(pat, sdir) {{{ 获取文件列表
" @param pat: 文件匹配模式，如*.pro
" @param sdir: 查找起始目录，默认从当前目录向上查找到根目录
" @return 返回找到的文件列表
function! GetFileList(pat, sdir)
    let l:dir      = empty(a:sdir) ? expand('%:p:h') : a:sdir
    let l:dir_last = ''
    let l:pfile    = ''

    while l:dir !=# l:dir_last
        let l:pfile = glob(l:dir . '/' . a:pat)
        if !empty(l:pfile)
            break
        endif

        let l:dir_last = l:dir
        let l:dir = fnamemodify(l:dir, ':p:h:h')
    endwhile

    return split(l:pfile, "\n")
endfunction
" }}}

" FUNCTION: GetFileContent(fp, pat) {{{ 获取文件中特定的内容
" @param fp: 目录文件
" @param pat: 匹配模式，必须使用 \(\) 来提取字符串
" @param flg: 匹配所有还是第一个
" @return 返回匹配的内容列表
function! GetFileContent(fp, pat, flg)
    let l:content = []
    for l:line in readfile(a:fp)
        let l:result = matchlist(l:line, a:pat)
        if !empty(l:result)
            if a:flg ==# 'all'
                if !empty(l:result[1])
                    call add(l:content, l:result[1])
                endif
            elseif a:flg ==# 'first'
                return empty(l:result[1]) ? [] : [result[1]]
            endif
        endif
    endfor
    return l:content
endfunction
" }}}

" FUNCTION: GetArgs(str) {{{ 解析字符串参数到列表中
" @param str: 参数字符串，如 '"Test", 10, g:a'
" @return 返回参数列表，如 ["Test", 10, g:a]
function! GetArgs(str)
    let l:args = []
    function! s:parseArgs(...) closure
        let l:args = a:000
    endfunction
    execute 'call s:parseArgs(' . a:str . ')'
    return l:args
endfunction
" }}}

" FUNCTION: GetCmdResult(flg, cmd, args) {{{ 获取命令或函数执行结果
function! GetCmdResult(flg, cmd, args)
    if a:flg ==# 'call'
        return call(a:cmd, a:args)
    elseif a:flg ==# 'exec'
        return execute(a:cmd)
    endif
endfunction
" }}}

" FUNCTION: GetInput(prompt, [text, completion, workdir]) {{{ 输入字符串
" @param workdir: 设置工作目录，用于文件和目录补全
function! GetInput(prompt, ...)
    if a:0 == 0
        return input(a:prompt)
    elseif a:0 == 1
        return input(a:prompt, a:1)
    elseif a:0 == 2
        return input(a:prompt, a:1, a:2)
    elseif a:0 == 3
        execute 'lcd ' . a:3
        return input(a:prompt, a:1, a:2)
    endif
endfunction
" }}}

" FUNCTION: ExecFuncInput(iargs, fn, [fargs...]) range {{{
" @param iargs: 用于GetInput的参数列表
" @param fn: 要运行的函数，第一个参数必须为GetInput的输入
" @param fargs: fn的附加参数
function! ExecFuncInput(iargs, fn, ...) range
    let l:inpt = call('GetInput', a:iargs)
    if empty(l:inpt)
        return
    endif
    let l:fargs = [l:inpt]
    if a:0 > 0
        call extend(l:fargs, a:000)
    endif
    let l:range = (a:firstline == a:lastline) ? '' : (string(a:firstline) . ',' . string(a:lastline))
    let Fn = function(a:fn, l:fargs)
    execute l:range . 'call Fn()'
endfunction
" }}}

" FUNCTION: FuncSort() range {{{ 预览sort匹配
function! FuncSort() range
    let l:pat = PreviewPattern('sort pattern: /')
    if empty(l:pat)
        return
    endif
    let l:range = (a:firstline == a:lastline) ? '' : (string(a:firstline) . ',' . string(a:lastline))
    call feedkeys(':' . l:range . 'sort /' . l:pat . '/', 'n')
endfunction
" }}}

" FUNCTION: FuncEditTempFile(suffix, ntab) {{{ 编辑临时文件
" @param suffix: 临时文件附加后缀
" @param ntab: 在新tab中打开
function! FuncEditTempFile(suffix, ntab)
    let l:tempfile = fnamemodify(tempname(), ':r')
    if empty(a:suffix)
        let l:tempfile .= '.tmp'
    else
        let l:tempfile .= '.' . a:suffix
    endif
    if a:ntab
        execute 'tabedit ' . l:tempfile
    else
        execute 'edit ' . l:tempfile
    endif
endfunction
"}}}

" FUNCTION: FuncDiffFile(filename, mode) {{{ 文件对比
function! FuncDiffFile(filename, mode)
    if a:mode ==# 's'
        execute 'diffsplit ' . a:filename
    elseif a:mode ==# 'v'
        execute 'vertical diffsplit ' . a:filename
    endif
endfunction
" }}}

" FUNCTION: FuncDivideSpace(string, pos) range {{{ 添加分隔符
function! FuncDivideSpace(string, pos) range
    let l:chars = split(a:string)

    for k in range(a:firstline, a:lastline)
        let l:line = getline(k)
        let l:fie = ' '
        for ch in l:chars
            let l:pch = '\m\s*\M' . escape(ch, '\') . '\m\s*\C'
            if a:pos == 'h'
                let l:sch = l:fie . escape(ch, '&\')
            elseif a:pos == 'c'
                let l:sch = l:fie . escape(ch, '&\') . l:fie
            elseif a:pos == 'l'
                let l:sch = escape(ch, '&\') . l:fie
            elseif a:pos == 'd'
                let l:sch = escape(ch, '&\')
            endif
            let l:line = substitute(l:line, l:pch, l:sch, 'g')
        endfor
        call setline(k, l:line)
    endfor
    call SetRepeatExecution('call FuncDivideSpace("' . a:string . '", "' . a:pos . '")')
endfunction
let FuncDivideSpaceH = function('ExecFuncInput', [['Divide H Space(split with space): '], 'FuncDivideSpace', 'h'])
let FuncDivideSpaceC = function('ExecFuncInput', [['Divide C Space(split with space): '], 'FuncDivideSpace', 'c'])
let FuncDivideSpaceL = function('ExecFuncInput', [['Divide L Space(split with space): '], 'FuncDivideSpace', 'l'])
let FuncDivideSpaceD = function('ExecFuncInput', [['Delete D Space(split with space): '], 'FuncDivideSpace', 'd'])
" }}}

" FUNCTION: FuncAppendCmd(str) {{{ 将命令结果作为文本插入
function! FuncAppendCmd(str, flg)
    if a:flg ==# 'call'
        let l:as = match(a:str, '(')
        let l:ae = -1   " match(a:str, ')') - 1
        let l:str = a:str[0 : l:as - 1]
        let l:args = GetArgs(a:str[l:as + 1 : l:ae - 1])
    elseif a:flg ==# 'exec'
        let l:str = ':' . a:str
        let l:args = []
    endif
    let l:result = GetCmdResult(a:flg, l:str, l:args)
    call append(line('.'), split(l:result, "\n"))
endfunction
let FuncAppendExecResult = function('ExecFuncInput', [['Input cmd = ', '', 'command'] , 'FuncAppendCmd', 'exec'])
let FuncAppendCallResult = function('ExecFuncInput', [['Input cmd = ', '', 'function'], 'FuncAppendCmd', 'call'])
" }}}
" }}}

" Project run {{{
" FUNCTION: CompileFile(argstr) {{{
" s:cpl {{{
let s:cpl = {
    \ 'wdir' : '',
    \ 'args' : '',
    \ 'srcf' : '',
    \ 'outf' : '',
    \ 'flg'  : {
        \ 'c'    : ['gcc -static %s -o %s %s && "./%s"'            , 'args'  , 'outf'  , 'srcf' , 'outf'] ,
        \ 'cpp'  : ['g++ -std=c++11 -static %s -o %s %s && "./%s"' , 'args'  , 'outf'  , 'srcf' , 'outf'] ,
        \ 'java' : ['javac %s && java %s %s'                       , 'srcf'  , 'outf'  , 'args'] ,
        \ 'py'   : ['python %s %s'                                 , 'srcf'  , 'args'] ,
        \ 'jl'   : ['julia %s %s'                                  , 'srcf'  , 'args'] ,
        \ 'lua'  : ['lua %s %s'                                    , 'srcf'  , 'args'] ,
        \ 'go'   : ['go run %s %s'                                 , 'srcf'  , 'args'] ,
        \ 'js'   : ['node %s %s'                                   , 'srcf'  , 'args'],
        \ 'dart' : ['dart %s %s'                                   , 'srcf'  , 'args'] ,
        \ 'json' : ['python -m json.tool %s'                       , 'srcf'] ,
        \ 'm'    : ['matlab -nosplash -nodesktop -r %s'            , 'outf'] ,
        \ 'dot'  : ['dotty %s && dot -Tpng %s -o %s.png'           , 'srcf'  , 'srcf'  , 'outf'],
        \ 'sh'   : ['./%s %s'                                      , 'srcf'  , 'args'] ,
        \ 'bat'  : ['%s %s'                                        , 'srcf'  , 'args'] ,
        \ 'html' : ['"' . s:path.browser . '" %s'                  , 'srcf'] ,
        \ 'make' : ['cd "%s" && make %s && "./%s"'                 , 'wdir'  , 'args'  , 'outf'] ,
        \ 'qt'   : ['cd "%s" && ' . (IsWin() ?
                    \ (s:path.qmake . ' -r "%s" && ' . s:path.vcvars . ' && nmake -f Makefile.Debug') :
                    \ ('qmake "%s" && make'))
                    \ . ' %s && "./%s"',
                    \ 'wdir', 'srcf', 'args', 'outf'],
        \ 'vs'   : ['cd "%s" && ' . s:path.vcvars . ' && devenv "%s" /%s && "./%s"',
                    \ 'wdir', 'srcf', 'args', 'outf']
        \},
    \ 'pat' : {
        \ 'make' : '\mTARGET\s*=\s*\(\<[a-zA-Z_][a-zA-Z0-9_]*\)',
        \},
    \ 'sel_cpp' : {
        \ 'opt' : ['cppargs'],
        \ 'lst' : ['charset'],
        \ 'dic' : {
                \ 'charset' : '-finput-charset=utf-8 -fexec-charset=gbk',
                \},
        \ 'cmd' : 'ExecSelCpp'
        \}
    \}
" FUNCTION:s:cpl.printf(flg, args, srcf, outf) dict {{{
" 生成编译运行命令字符串。
" @param flg: 编译类型，需要包含于s:cpl.flg中
" @param wdir: 命令运行目录
" @param args: 参数
" @param srcf: 源文件
" @param outf: 目标文件
" @return 返回编译或运行命令
function s:cpl.printf(flg, wdir, args, srcf, outf) dict
    if !has_key(self.flg, a:flg)
        \ || ('sh' ==? a:flg && !(IsLinux() || IsGw() || IsMac()))
        \ || ('bat' ==? a:flg && !IsWin())
        return ''
    endif
    let self.wdir = a:wdir
    let self.args = a:args
    let self.srcf = a:srcf
    let self.outf = a:outf
    let l:pstr = copy(self.flg[a:flg])
    call map(l:pstr, {key, val -> (key == 0) ? val : get(self, val, '')})
    " create execution string
    if exists(':AsyncRun') == 2
        let l:exec = ':AsyncRun '
        if !empty(a:wdir)
            let l:exec .= '-cwd="' . a:wdir . '" '
            execute 'lcd ' . a:wdir
        endif
    else
        let l:exec = '!'
    endif
    return l:exec . call('printf', l:pstr)
endfunction
" }}}
" }}}

function! ExecSelCpp(sopt, arg)
    call CompileFile(s:cpl.sel_cpp.dic[a:arg])
endfunction

function! CompileFile(argstr)
    let l:ext     = expand('%:e')       " 扩展名
    let l:srcfile = expand('%:t')       " 文件名，不带路径，带扩展名
    let l:outfile = expand('%:t:r')     " 文件名，不带路径，不带扩展名
    let l:workdir = expand('%:p:h')     " 当前文件目录

    if !has_key(s:cpl.flg, l:ext)
        let l:ext = &filetype
    endif
    let l:exec = s:cpl.printf(l:ext, l:workdir, a:argstr, l:srcfile, l:outfile)
    if empty(l:exec)
        echo 's:cpl doesn''t support ' . l:ext
        return
    endif
    execute l:exec
    call SetRepeatExecution(l:exec)
endfunction
" }}}

" FUNCTION: CompileProject(str, fn, args) {{{
" 当找到多个Project文件时，会弹出选项以供选择。
" @param str: 工程文件名，可用通配符，如*.pro
" @param fn:
"   编译工程文件的函数，可能用于popset插件
"   fn需要3个参数：
"   - sopt: 自定义参数信息
"   - sel: Project文件路径
"   - args: Project的附加参数列表
" @param args: 编译工程文件函数的附加参数，需要采用popset插件
function! CompileProject(str, fn, args)
    let l:prj = GetFileList(a:str, '')
    if len(l:prj) == 1
        let Fn = function(a:fn)
        call Fn('', l:prj[0], a:args)
    elseif len(l:prj) > 1
        call PopSelection({
            \ 'opt' : ['Please select the project file'],
            \ 'lst' : l:prj,
            \ 'cmd' : a:fn,
            \}, 0, a:args)
    else
        echo 'None of ' . a:str . ' was found!'
    endif
endfunction
" }}}

" FUNCTION: CompileProjectQt(sopt, sel, args) {{{
function! CompileProjectQt(sopt, sel, args)
    let l:srcfile = fnamemodify(a:sel, ':p:t')
    let l:outfile = GetFileContent(a:sel, s:cpl.pat.make, 'first')
    let l:outfile = empty(l:outfile) ? '' : l:outfile[0]
    let l:workdir = fnamemodify(a:sel, ':p:h')

    " execute shell code
    execute s:cpl.printf('qt', l:workdir, join(a:args), l:srcfile, l:outfile)
endfunction
" }}}

" FUNCTION: CompileProjectMake(sopt, sel, args) {{{
function! CompileProjectMake(sopt, sel, args)
    let l:outfile = GetFileContent(a:sel, s:cpl.pat.make, 'first')
    let l:outfile = empty(l:outfile) ? '' : l:outfile[0]
    let l:workdir = fnamemodify(a:sel, ':p:h')

    " execute shell code
    execute s:cpl.printf('make', l:workdir, join(a:args), '', l:outfile)
endfunction
"}}}

" FUNCTION: CompileProjectQtVs(sopt, sel, args) {{{
function! CompileProjectVs(sopt, sel, args)
    let l:srcfile = fnamemodify(a:sel, ':p:t')
    let l:outfile = fnamemodify(a:sel, ':p:t:r')
    let l:workdir = fnamemodify(a:sel, ':p:h')

    " execute shell code
    execute s:cpl.printf('vs', l:workdir, join(a:args), l:srcfile, l:outfile)
endfunction
" }}}

" FUNCTION: CompileProjectHtml(sopt, sel, args) {{{
function! CompileProjectHtml(sopt, sel, args)
    execute s:cpl.printf('html', '', '', a:sel, '')
endfunction
" }}}

" Run compiler
let RC_Args       = function('popset#set#PopSelection', [s:cpl.sel_cpp, 0])
let RC_Qt         = function('CompileProject', ['*.pro', 'CompileProjectQt', []])
let RC_QtClean    = function('CompileProject', ['*.pro', 'CompileProjectQt', ['distclean']])
let RC_Vs         = function('CompileProject', ['*.sln', 'CompileProjectVs', ['Build']])
let RC_VsClean    = function('CompileProject', ['*.sln', 'CompileProjectVs', ['Clean']])
let RC_Make       = function('CompileProject', ['[mM]akefile', 'CompileProjectMake', []])
let RC_MakeClean  = function('CompileProject', ['[mM]akefile', 'CompileProjectMake', ['clean']])
let RC_Html       = function('CompileProject', ['[iI]ndex.html', 'CompileProjectHtml', []])
" }}}

" Search {{{
" FUNCTION: FindWorking(keys, mode) {{{ 超速查找
" {{{
augroup UserFunctionSearch
    autocmd!
    autocmd VimEnter * call FindWorkingRoot()
    autocmd VimEnter * let s:fw_rg = exists('loaded_grep') ? 1 : 0
    autocmd User Grepper call FindWorkingHighlight(s:fw.pattern)
augroup END

" s:fw {{{
let s:fw = {
    \ 'command'  : '',
    \ 'pattern'  : '',
    \ 'location' : '',
    \ 'options'  : '',
    \ 'root'     : '',
    \ 'filters'  : '',
    \ 'strings'  : [],
    \ 'markers'  : ['.root', '.git', '.svn'],
    \}
function! s:fw.exec() dict
    let l:exec = self.command . ' ' . self.pattern . ' ' . self.location . ' ' . self.options
    execute l:exec
    if s:fw_rg
        call FindWorkingHighlight(self.pattern)
    endif
    call SetRepeatExecution(l:exec)
endfunction
let s:fw_nvmaps = [
                \  'fi',  'fbi',  'fti',  'foi',  'fpi',  'fri',  'fI',  'fbI',  'ftI',  'foI',  'fpI',  'frI',
                \  'fw',  'fbw',  'ftw',  'fow',  'fpw',  'frw',  'fW',  'fbW',  'ftW',  'foW',  'fpW',  'frW',
                \  'fs',  'fbs',  'fts',  'fos',  'fps',  'frs',  'fS',  'fbS',  'ftS',  'foS',  'fpS',  'frS',
                \  'f=',  'fb=',  'ft=',  'fo=',  'fp=',  'fr=',  'f=',  'fb=',  'ft=',  'fo=',  'fp=',  'fr=',
                \  'Fi',  'Fbi',  'Fti',  'Foi',  'Fpi',  'Fri',  'FI',  'FbI',  'FtI',  'FoI',  'FpI',  'FrI',
                \  'Fw',  'Fbw',  'Ftw',  'Fow',  'Fpw',  'Frw',  'FW',  'FbW',  'FtW',  'FoW',  'FpW',  'FrW',
                \  'Fs',  'Fbs',  'Fts',  'Fos',  'Fps',  'Frs',  'FS',  'FbS',  'FtS',  'FoS',  'FpS',  'FrS',
                \  'F=',  'Fb=',  'Ft=',  'Fo=',  'Fp=',  'Fr=',  'F=',  'Fb=',  'Ft=',  'Fo=',  'Fp=',  'Fr=',
                \ 'fli', 'flbi', 'flti', 'floi', 'flpi', 'flri', 'flI', 'flbI', 'fltI', 'floI', 'flpI', 'flrI',
                \ 'flw', 'flbw', 'fltw', 'flow', 'flpw', 'flrw', 'flW', 'flbW', 'fltW', 'floW', 'flpW', 'flrW',
                \ 'fls', 'flbs', 'flts', 'flos', 'flps', 'flrs', 'flS', 'flbS', 'fltS', 'floS', 'flpS', 'flrS',
                \ 'fl=', 'flb=', 'flt=', 'flo=', 'flp=', 'flr=', 'fl=', 'flb=', 'flt=', 'flo=', 'flp=', 'flr=',
                \ 'Fli', 'Flbi', 'Flti', 'Floi', 'Flpi', 'Flri', 'FlI', 'FlbI', 'FltI', 'FloI', 'FlpI', 'FlrI',
                \ 'Flw', 'Flbw', 'Fltw', 'Flow', 'Flpw', 'Flrw', 'FlW', 'FlbW', 'FltW', 'FloW', 'FlpW', 'FlrW',
                \ 'Fls', 'Flbs', 'Flts', 'Flos', 'Flps', 'Flrs', 'FlS', 'FlbS', 'FltS', 'FloS', 'FlpS', 'FlrS',
                \ 'Fl=', 'Flb=', 'Flt=', 'Flo=', 'Flp=', 'Flr=', 'Fl=', 'Flb=', 'Flt=', 'Flo=', 'Flp=', 'Flr=',
                \ 'fai', 'fabi', 'fati', 'faoi', 'fapi', 'fari', 'faI', 'fabI', 'fatI', 'faoI', 'fapI', 'farI',
                \ 'faw', 'fabw', 'fatw', 'faow', 'fapw', 'farw', 'faW', 'fabW', 'fatW', 'faoW', 'fapW', 'farW',
                \ 'fas', 'fabs', 'fats', 'faos', 'faps', 'fars', 'faS', 'fabS', 'fatS', 'faoS', 'fapS', 'farS',
                \ 'fa=', 'fab=', 'fat=', 'fao=', 'fap=', 'far=', 'fa=', 'fab=', 'fat=', 'fao=', 'fap=', 'far=',
                \ 'Fai', 'Fabi', 'Fati', 'Faoi', 'Fapi', 'Fari', 'FaI', 'FabI', 'FatI', 'FaoI', 'FapI', 'FarI',
                \ 'Faw', 'Fabw', 'Fatw', 'Faow', 'Fapw', 'Farw', 'FaW', 'FabW', 'FatW', 'FaoW', 'FapW', 'FarW',
                \ 'Fas', 'Fabs', 'Fats', 'Faos', 'Faps', 'Fars', 'FaS', 'FabS', 'FatS', 'FaoS', 'FapS', 'FarS',
                \ 'Fa=', 'Fab=', 'Fat=', 'Fao=', 'Fap=', 'Far=', 'Fa=', 'Fab=', 'Fat=', 'Fao=', 'Fap=', 'Far=',
                \ 'fvi', 'fvpi', 'fvI',  'fvpI',
                \ 'fvw', 'fvpw', 'fvW',  'fvpW',
                \ 'fvs', 'fvps', 'fvS',  'fvpS',
                \ 'fv=', 'fvp=', 'fv=',  'fvp=',
                \ ]
" }}}
" }}}
function! FindWorking(keys, mode)
    " doc
    " {{{
    " Required: based on 'mhinz/vim-grepper' or 'yegappan/grep', 'Yggdroot/LeaderF' and 'yehuohan/popc'
    " MapKeys: [fF][lav][btopr][IiWwSs=]
    "          [%1][%2 ][%3   ][4%     ]
    " Find: %1
    "   f : find working
    "   F : find working with inputing args
    " Command: %2
    "   '': find with rg by default
    "   l : find with rg in working root-filter and pass result to Leaderf
    "   a : find with rg append
    "   v : find with vimgrep
    " Location: %3
    "   b : find in current buffer(%)
    "   t : find in buffers of tab via popc
    "   o : find in buffers of all tabs via popc
    "   p : find with inputing path
    "   r : find with inputing working root and filter
    "  '' : find with working root-filter
    " Pattern: %4
    "   = : find text from clipboard
    "   Normal Mode: mode='n'
    "   i : find input
    "   w : find word
    "   s : find word with boundaries
    "   Visual Mode: mode='v'
    "   i : find input    with selected
    "   w : find visual   with selected
    "   s : find selected with boundaries
    "   LowerCase: [iws] find in ignorecase
    "   UpperCase: [IWS] find in case match
    " }}}
    " parse function
    " FUNCTION: s:parsePattern() closure {{{
    function! s:parsePattern() closure
        let l:pat = ''
        if a:mode ==# 'n'
            if a:keys =~? 'i'
                let l:pat = GetInput(' What to find: ')
            elseif a:keys =~? '[ws]'
                let l:pat = expand('<cword>')
            endif
        elseif a:mode ==# 'v'
            let l:selected = GetSelected()
            if a:keys =~? 'i'
                let l:pat = GetInput(' What to find: ', l:selected)
            elseif a:keys =~? '[ws]'
                let l:pat = l:selected
            endif
        endif
        if a:keys =~ '='
            let l:pat = getreg('+')
        endif
        let l:pat = escape(l:pat, ' -#%')       " escape 'Space,-,#,%'
        if !empty(l:pat) && a:keys =~# 'l'
            let l:pat = '-e "' . l:pat .'"'     " used for 'Leaderf rg'
        endif
        return l:pat
    endfunction
    " }}}
    " FUNCTION: s:parseLocation() closure {{{
    function! s:parseLocation() closure
        let l:loc = ''
        if a:keys =~# 'b'
            let l:loc = expand('%')
        elseif a:keys =~# 't'
            let l:loc = join(popc#layer#buf#GetFiles('sigtab'), ' ')
        elseif a:keys =~# 'o'
            let l:loc = join(popc#layer#buf#GetFiles('alltab'), ' ')
        elseif a:keys =~# 'p'
            let l:loc = GetInput(' Where to find: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
        elseif a:keys =~# 'r'
            let l:loc = FindWorkingSet() ? s:fw.root : ''
        else
            if empty(s:fw.root)
                call FindWorkingRoot()
            endif
            if empty(s:fw.root)
                call FindWorkingSet()
            endif
            let l:loc = s:fw.root
        endif
        return l:loc
    endfunction
    " }}}
    " FUNCTION: s:parseOptions() closure {{{
    function! s:parseOptions() closure
        let l:opt = ''
        if a:keys =~? 's'     | let l:opt .= '-w ' | endif
        if a:keys =~# '[iws]' | let l:opt .= '-i ' | elseif a:keys =~# '[IWS]' | let l:opt .= '-s ' | endif
        if !empty(s:fw.filters) && a:keys !~# '[btop]'
            let l:opt .= '-g "*.{' . s:fw.filters . '}" '
        endif
        if a:keys =~# 'F'
            let l:opt .= GetInput(' Args(-F, --hidden ...) to append: ')
        endif
        return l:opt
    endfunction
    " }}}
    " FUNCTION: s:parseCommand() closure {{{
    function! s:parseCommand() closure
        if a:keys =~# 'l'
            let l:cmd = ':Leaderf rg --nowrap'
        elseif a:keys =~# 'a'
            let l:cmd = s:fw_rg ? ':RgAdd' : 'Grepper -noprompt -tool rg -append -query'
        else
            let l:cmd = s:fw_rg ? ':Rg'    : 'Grepper -noprompt -tool rg -query'
            let s:fw.strings = []
        endif
        return l:cmd
    endfunction
    " }}}
    " FUNCTION: s:parseVimgrep() closure {{{
    function! s:parseVimgrep() closure
        if a:keys !~# 'v'
            return 0
        endif

        " get pattern and set options
        let s:fw.pattern = s:parsePattern()
        if empty(s:fw.pattern) | return 0 | endif
        let l:pat = (a:keys =~? 's') ? ('\<' . s:fw.pattern . '\>') : (s:fw.pattern)
        let l:pat .= (a:keys =~# '[iws]') ? '\c' : '\C'

        " set loaction
        let l:loc = '%'
        if a:keys =~# 'p'
            let l:loc = GetInput(' Where to find: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
            if empty(l:loc) | return 0 | endif
        endif

        " execute vimgrep
        execute 'vimgrep /' . l:pat . '/j ' . l:loc
        echo 'Finding...'
        if empty(getqflist())
            echo 'No match: ' . l:pat
        else
            botright copen
            call FindWorkingHighlight(s:fw.pattern)
        endif
        return 1
    endfunction
    " }}}

    " try use vimgrep first
    if s:parseVimgrep() | return | endif

    " find pattern
    let s:fw.pattern = s:parsePattern()
    if empty(s:fw.pattern) | return | endif

    " find location
    let s:fw.location = s:parseLocation()
    if empty(s:fw.location) | return | endif

    " find options
    let s:fw.options = s:parseOptions()

    " find command
    let s:fw.command = s:parseCommand()

    " Find Working
    call s:fw.exec()
endfunction
" }}}

" FUNCTION: FindWorkingFile(r) {{{ 查找文件
" @param r: 是否设置查找目录s:fw.root
function! FindWorkingFile(r)
    if !a:r && empty(s:fw.root)
        call FindWorkingRoot()
    endif
    if a:r || empty(s:fw.root)
        let l:root = GetInput(' Where (Root) to find: ', '', 'dir', expand('%:p:h'))
        if empty(l:root)
            return 0
        endif
        let s:fw.root = fnamemodify(l:root, ':p')
    endif

    if empty(s:fw.root)
        return 0
    endif
    execute ':LeaderfFile ' . s:fw.root
endfunction
" }}}

" FUNCTION: FindWorkingRoot() {{{ 查找root路径
function! FindWorkingRoot()
    if empty(s:fw.markers)
        return
    endif

    let l:dir = fnamemodify(expand('%'), ':p:h')
    let l:dir_last = ''
    while l:dir !=# l:dir_last
        let l:dir_last = l:dir
        for m in s:fw.markers
            let l:root = l:dir . '/' . m
            if filereadable(l:root) || isdirectory(l:root)
                let s:fw.root = fnameescape(l:dir)
                return
            endif
        endfor
        let l:dir = fnamemodify(l:dir, ':p:h:h')
    endwhile
endfunction
" }}}

" FUNCTION: FindWorkingSet() {{{ 设置root和filters
function! FindWorkingSet()
    let l:root = GetInput(' Where (Root) to find: ', '', 'dir', expand('%:p:h'))
    if empty(l:root)
        return 0
    endif
    let s:fw.root = fnamemodify(l:root, ':p')
    let s:fw.filters = GetInput(' Which (Filter) to find: ')
    return 1
endfunction
" }}}

" FUNCTION: FindWorkingGet() {{{ 获取root和filters
function! FindWorkingGet()
    if empty(s:fw.root)
        return []
    endif
    return [s:fw.root, s:fw.filters]
endfunction
" }}}

" FUNCTION: FindWorkingHighlight([string]) {{{ 高亮字符串
" @param string: 若有字符串，则先添加到s:fw.strings，再高亮
function! FindWorkingHighlight(...)
    if &filetype ==# 'leaderf'
        " use leaderf's highlight
    elseif &filetype ==# 'qf'
        if a:0 >= 1
            call add(s:fw.strings, escape(a:1, '/*'))
        endif
        for str in s:fw.strings
            execute 'syntax match IncSearch /' . str . '/'
        endfor
    endif
endfunction
" }}}

" FUNCTION: QuickfixGet() {{{ 类型与编号
function! QuickfixGet()
    " location-list : 每个窗口对应一个位置列表
    " quickfix      : 整个vim对应一个quickfix
    let l:type = ''
    let l:line = 0
    if &filetype ==# 'qf'
        let l:dict = getwininfo(win_getid())
        if l:dict[0].quickfix && !l:dict[0].loclist
            let l:type = 'q'
        elseif l:dict[0].quickfix && l:dict[0].loclist
            let l:type = 'l'
        endif
        let l:line = line('.')
    endif
    return [l:type, l:line]
endfunction
" }}}

" FUNCTION: QuickfixTabEdit() {{{ 新建Tab打开窗口
function! QuickfixTabEdit()
    let [l:type, l:line] = QuickfixGet()
    if empty(l:type)
        return
    endif

    execute 'tabedit'
    if l:type ==# 'q'
        execute 'crewind ' . l:line
        silent! normal! zO
        silent! normal! zz
        execute 'botright copen'
    elseif l:type ==# 'l'
        execute 'lrewind ' . l:line
        silent! normal! zO
        silent! normal! zz
        execute 'botright lopen'
    endif
    call FindWorkingHighlight()
endfunction
" }}}

" FUNCTION: QuickfixPreview() {{{ 预览
function! QuickfixPreview()
    let [l:type, l:line] = QuickfixGet()
    if empty(l:type)
        return
    endif

    let l:last_winnr = winnr()
    if l:type ==# 'q'
        execute 'crewind ' . l:line
    elseif l:type ==# 'l'
        execute 'lrewind ' . l:line
    endif
    silent! normal! zO
    silent! normal! zz
    execute l:last_winnr . 'wincmd w'
endfunction
" }}}
" }}}

" Misc {{{
" 切换显示隐藏字符 {{{
function! InvConceallevel()
    if &conceallevel == 0
        set conceallevel=2
    else
        set conceallevel=0              " 显示markdown等格式中的隐藏字符
    endif
    echo 'conceallevel = ' . &conceallevel
endfunction
" }}}

" 切换虚拟编辑 {{{
function! InvVirtualedit()
    if &virtualedit == ''
        set virtualedit=all
    else
        set virtualedit=""
    endif
    echo 'virtualedit = ' . &virtualedit
endfunction
" }}}

" 切换显示行号 {{{
let s:misc_number_type = 1
function! InvNumberType()
    if s:misc_number_type == 1
        let s:misc_number_type = 2
        set nonumber
        set norelativenumber
    elseif s:misc_number_type == 2
        let s:misc_number_type = 3
        set number
        set norelativenumber
    elseif s:misc_number_type == 3
        let s:misc_number_type = 1
        set number
        set relativenumber
    endif
endfunction
" }}}

" 切换显示折叠列 {{{
function! InvFoldColumeShow()
    if &foldcolumn == 0
        set foldcolumn=1
    else
        set foldcolumn=0
    endif
    echo 'foldcolumn = ' . &foldcolumn
endfunction
" }}}

" 切换显示标志列 {{{
function! InvSigncolumn()
    if &signcolumn == 'auto'
        set signcolumn=no
    else
        set signcolumn=auto
    endif
    echo 'signcolumn = ' . &signcolumn
endfunction
" }}}

" 切换高亮 {{{
function! InvHighLight()
    if exists('g:syntax_on')
        syntax off
        echo 'syntax off'
    else
        syntax on
        echo 'syntax on'
    endif
endfunction
" }}}

" 切换滚屏bind {{{
function! InvScrollBind()
    if &scrollbind == 1
        set noscrollbind
    else
        set scrollbind
    endif
    echo 'scrollbind = ' . &scrollbind
endfunction
" }}}

" 切换Fcitx输入法 {{{
if IsLinux()
function! LinuxFcitx2En()
    if 2 == system('fcitx-remote')
        let l:t = system('fcitx-remote -c')
    endif
endfunction
function! LinuxFcitx2Zh()
    if 1 == system('fcitx-remote')
        let l:t = system('fcitx-remote -o')
    endif
endfunction
endif
" }}}

" 查找Vim关键字 {{{
function! GotoKeyword(mode)
    let l:exec = 'help '
    if a:mode ==# 'n'
        let l:word = expand('<cword>')
    elseif a:mode ==# 'v'
        let l:word = GetSelected()
    endif

    " 添加关键字
    let l:exec .= l:word
    if IsNVim()
        " nvim用自己的帮助文件，只有英文的
        let l:exec .= '@en'
    endif

    execute l:exec
endfunction
" }}}

" 去除尾部空白 {{{
function! RemoveTrailingSpace()
    let l:save = winsaveview()
    %s/\s\+$//e
    call winrestview(l:save)
endfunction
" }}}

" {{{ 冻结顶行
function! HoldTopLine()
    let l:line = line('.')
    split %
    resize 1
    call cursor(l:line, 1)
    wincmd p
endfunction
" }}}
" }}}
" }}}

"===============================================================================
" User Settings
"===============================================================================
" {{{
" Term {{{
    syntax on                           " 语法高亮
    filetype plugin indent on           " 打开文件类型检测
    set number                          " 显示行号
    set relativenumber                  " 显示相对行号
    set cursorline                      " 高亮当前行
    set cursorcolumn                    " 高亮当前列
    set hlsearch                        " 设置高亮显示查找到的文本
    set termguicolors                   " 在终端中使用24位彩色
if IsVim()
    set renderoptions=                  " 设置正常显示unicode字符
endif
    set expandtab                       " 将Tab用Space代替，方便显示缩进标识indentLine
    set tabstop=4                       " 设置Tab键宽4个空格
    set softtabstop=4                   " 设置按<Tab>或<BS>移动的空格数
    set shiftwidth=4                    " 设置>和<命令移动宽度为4
    set nowrap                          " 默认关闭折行
    set textwidth=0                     " 关闭自动换行
    set listchars=eol:$,tab:>-,trail:~,space:.
                                        " 不可见字符显示
    set autoindent                      " 使用autoindent缩进
    set nobreakindent                   " 折行时不缩进
    set conceallevel=0                  " 显示markdown等格式中的隐藏字符
    set foldenable                      " 充许折叠
    set foldcolumn=0                    " 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    set foldmethod=indent               " 设置折叠，默认为缩进折叠
                                        " manual : 手工定义折叠
                                        " indent : 更多的缩进表示更高级别的折叠
                                        " expr   : 用表达式来定义折叠
                                        " syntax : 用语法高亮来定义折叠
                                        " diff   : 对没有更改的文本进行折叠
                                        " marker : 对文中的标记折叠，默认使用{{{,}}}标记
    set scrolloff=3                     " 光标上下保留的行数
    set laststatus=2                    " 一直显示状态栏
    set noshowmode                      " 命令行栏不显示VISUAL等字样
    set completeopt=menuone,preview     " 补全显示设置
    set backspace=2                     " Insert模式下使用BackSpace删除
    set title                           " 允许设置titlestring
    set hidden                          " 允许在未保存文件时切换buffer
    set bufhidden=                      " 跟随hidden设置
    set nobackup                        " 不生成备份文件
    set nowritebackup                   " 覆盖文件前，不生成备份文件
    set autochdir                       " 自动切换当前目录为当前文件所在的目录
    set noautowrite                     " 禁止自动保存文件
    set noautowriteall                  " 禁止自动保存文件
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
                                        " 尝试解码序列
    set fileformat=unix                 " 以unix格式保存文本文件，即CR作为换行符
    set magic                           " 默认使用magic匹配
    set ignorecase                      " 不区别大小写搜索
    set smartcase                       " 有大写字母时才区别大小写搜索
    set notildeop                       " 使切换大小写的~，类似于c,y,d等操作符
    set nrformats=bin,octal,hex,alpha   " CTRL-A-X支持数字和字母
    set noimdisable                     " 切换Normal模式时，自动换成英文输入法
    set noerrorbells                    " 关闭错误信息响铃
    set visualbell t_vb=                " 关闭响铃(vb, visualbell)和可视闪铃(t_vb，即闪屏)，即normal模式时按esc会有响铃
    set belloff=all                     " 关闭所有事件的响铃
    set helplang=cn,en                  " 优先查找中文帮助

    " 终端光标设置
if IsVim()
    if IsTermType('xterm') || IsTermType('xterm-256color')
        " 适用于urxvt,st,xterm,gnome-termial
        " 5,6: 竖线，  3,4: 横线，  1,2: 方块
        let &t_SI = "\<Esc>[6 q"        " 进入Insert模式
        let &t_EI = "\<Esc>[2 q"        " 退出Insert模式
    endif
endif
" }}}

" Gui {{{
if IsGVim()
    set guioptions-=m                   " 隐藏菜单栏
    set guioptions-=T                   " 隐藏工具栏
    set guioptions-=L                   " 隐藏左侧滚动条
    set guioptions-=r                   " 隐藏右侧滚动条
    set guioptions-=b                   " 隐藏底部滚动条
    set guioptions-=e                   " 不使用GUI标签

    if IsLinux()
        set lines=20
        set columns=100
        "set guifont=DejaVu\ Sans\ Mono\ 13
        set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 12
        set linespace=0                 " required by Powerline Font
        set guifontwide=WenQuanYi\ Micro\ Hei\ Mono\ 12
    elseif IsWin()
        set lines=25
        set columns=90
        "set guifont=Consolas:h13:cANSI
        set guifont=Consolas_For_Powerline:h12:cANSI
        set linespace=0                 " required by Powerline Font
        set guifontwide=Microsoft_YaHei_Mono:h11:cGB2312
        nnoremap <leader>tf <Esc>:call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<CR>
                                        " gvim全屏
    elseif IsMac()
        set lines=30
        set columns=100
        set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h15
    endif
endif

if IsNVim()
augroup UserSettingsGui
    autocmd!
    autocmd VimEnter * call s:setGuifontNVimQt()
augroup END

" FUNCTION: s:setGuifontNVimQt() {{{ neovim-qt设置
function! s:setGuifontNVimQt()
if IsNVimQt()
    if IsLinux()
        Guifont! WenQuanYi Micro Hei Mono:h12
        Guifont! DejaVu Sans Mono for Powerline:h12
    elseif IsWin()
        " 先设置一次中文（缺省）字体，再设置英文字体(BUG:有时有问题)
        "Guifont! YaHei Mono For Powerline:h12
        Guifont! Microsoft YaHei Mono:h12
        Guifont! Consolas For Powerline:h12
    endif
    GuiLinespace 0
    GuiTabline 0
    nnoremap <leader>tf :call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>
                                        " neovim-qt全屏
endif
endfunction
" }}}
endif
" }}}

" Auto Command {{{
augroup UserSettingsCmd
    "autocmd[!]  [group]  {event}     {pattern}  {nested}  {cmd}
    "autocmd              BufNewFile  *                    set fileformat=unix
    autocmd!

    autocmd BufNewFile *    set fileformat=unix
    autocmd GuiEnter *      set t_vb=   " 关闭可视闪铃(即闪屏)
    autocmd BufRead,BufNewFile *.jl     set filetype=julia
    autocmd BufRead,BufNewFile *.dart   set filetype=dart
    autocmd BufRead,BufNewFile *.tikz   set filetype=tex
    autocmd BufRead,BufNewFile *.gv     set filetype=dot

    autocmd Filetype vim    setlocal foldmethod=marker
    autocmd Filetype c      setlocal foldmethod=syntax
    autocmd Filetype cpp    setlocal foldmethod=syntax
    autocmd Filetype python setlocal foldmethod=indent
    autocmd FileType go     setlocal expandtab
    autocmd FileType javascript setlocal foldmethod=syntax

    " Help keys
    autocmd Filetype vim,help nnoremap <buffer> <S-k> :call GotoKeyword('n')<CR>
    autocmd Filetype vim,help vnoremap <buffer> <S-k> :call GotoKeyword('v')<CR>
    " 预览Quickfix和Location-list
    autocmd Filetype qf       nnoremap <buffer> <M-Space> :call QuickfixPreview()<CR>
augroup END
" }}}
" }}}

"===============================================================================
" User Mappings
"===============================================================================
" {{{
" Basic {{{
    " 回退操作
    nnoremap <S-u> <C-r>
    " 大小写转换
    nnoremap <leader>u ~
    vnoremap <leader>u ~
    nnoremap <leader>gu g~
    " 行移动
    nnoremap > >>
    nnoremap < <<
    " 加减序号
    nnoremap <leader>aj <C-x>
    nnoremap <leader>ak <C-a>
    vnoremap <leader>aj <C-x>
    vnoremap <leader>ak <C-a>
    vnoremap <leader>agj g<C-x>
    vnoremap <leader>agk g<C-a>
    " 嵌套映射匹配符(%)
if IsVim()
    packadd matchit
endif
    nmap <S-s> %
    vmap <S-s> %
    " 行首和行尾
    nnoremap <S-l> $
    nnoremap <S-h> ^
    vnoremap <S-l> $
    vnoremap <S-h> ^
    " 复制到行首行尾
    nnoremap yL y$
    nnoremap yH y^
    " j, k 移行
    nnoremap j gj
    vnoremap j gj
    nnoremap k gk
    vnoremap k gk
    " 折叠
    nnoremap <leader>za zA
    nnoremap <leader>zc zC
    nnoremap <leader>zo zO
    nnoremap <leader>zm zM
    nnoremap <leader>zn zN
    nnoremap <leader>zr zR
    nnoremap <leader>zx zX
    " 滚屏
    nnoremap <C-j> <C-e>
    nnoremap <C-k> <C-y>
    nnoremap zh zt
    nnoremap zl zb
    nnoremap <C-h> 2zh
    nnoremap <C-l> 2zl
    nnoremap <M-h> 16zh
    nnoremap <M-l> 16zl
    " 命令行移动
    cnoremap <M-h> <Left>
    cnoremap <M-l> <Right>
    cnoremap <M-k> <C-Right>
    cnoremap <M-j> <C-Left>
    cnoremap <M-i> <C-B>
    cnoremap <M-o> <C-E>
    " HEX编辑
    nnoremap <leader>xx :%!xxd<CR>
    nnoremap <leader>xr :%!xxd -r<CR>
    " Misc
    nnoremap <leader>iw :set invwrap<CR>
    nnoremap <leader>il :set invlist<CR>
    nnoremap <leader>iv :call InvVirtualedit()<CR>
    nnoremap <leader>ic :call InvConceallevel()<CR>
    nnoremap <leader>in :call InvNumberType()<CR>
    nnoremap <leader>if :call InvFoldColumeShow()<CR>
    nnoremap <leader>is :call InvSigncolumn()<CR>
    nnoremap <leader>ih :call InvHighLight()<CR>
    nnoremap <leader>ib :call InvScrollBind()<CR>
    nnoremap <leader>tc :call TogglePath('env')<CR>
    nnoremap <leader>tb :call TogglePath('browser')<CR>
    if IsLinux()
        inoremap <Esc> <Esc>:call LinuxFcitx2En()<CR>
    endif
    nnoremap <leader>rt :call RemoveTrailingSpace()<CR>
    nnoremap <leader>hl :call HoldTopLine()<CR>
" }}}

" Copy and paste{{{
    vnoremap <leader>y ygv
    nnoremap ya :<C-U>execute 'let @0.=join(getline(line("."), line(".")+v:count), "\n")'<CR>
    nnoremap yd dd<Bar>:execute 'let @0.=@"'<CR>
    vnoremap <leader>c "+y
    vnoremap <C-c> "+y
    nnoremap <C-v> "+p
    inoremap <C-v> <Esc>"+pi
    " 粘贴通过y复制的内容
    nnoremap <leader>p "0p
    nnoremap <leader>P "0P
    " 矩形选择
    nnoremap vv <C-v>
    vnoremap vv <C-v>

    for t in split('q w e r t y u i o p a s d f g h j k l z x c v b n m', ' ')
        " 寄存器快速复制与粘贴
        execute "vnoremap <leader>'" . t            .   ' "' . t . 'y'
        execute "nnoremap <leader>'" . t            .   ' "' . t . 'p'
        execute "nnoremap <leader>'" . toupper(t)   .   ' "' . t . 'P'
        " 快速执行宏
        execute "nnoremap <leader>2" . t            .   ' @' . t
    endfor
    for t in split('1 2 3 4 5 6 7 8 9 0', ' ')
        execute "vnoremap <leader>'" . t            .   ' "' . t . 'y'
        execute "nnoremap <leader>'" . t            .   ' "' . t . 'p'
    endfor
" }}}

" Tab, Buffer, Quickfix, Windows {{{
    " Tab切换
    nnoremap <M-u> gT
    nnoremap <M-p> gt
    " Buffer切换
    nnoremap <leader>bn :bnext<CR>
    nnoremap <leader>bp :bprevious<CR>
    nnoremap <leader>bl :b#<Bar>execute 'set buflisted'<CR>
    " 打开/关闭Quickfix
    nnoremap <leader>qo :botright copen<Bar>call FindWorkingHighlight()<CR>
    nnoremap <leader>qc :cclose<Bar>wincmd p<CR>
    nnoremap <leader>qj :cnext<Bar>execute'silent! normal! zO'<Bar>execute'normal! zz'<CR>
    nnoremap <leader>qk :cprevious<Bar>execute'silent! normal! zO'<Bar>execute'normal! zz'<CR>
    " 打开/关闭Location-list
    nnoremap <leader>lo :botright lopen<Bar>call FindWorkingHighlight()<CR>
    nnoremap <leader>lc :lclose<Bar>wincmd p<CR>
    nnoremap <leader>lj :lnext<Bar>execute'silent! normal! zO'<Bar>execute'normal! zz'<CR>
    nnoremap <leader>lk :lprevious<Bar>execute'silent! normal! zO'<Bar>execute'normal! zz'<CR>
    " 在新Tab中打开列表项
    nnoremap <leader>qt :call QuickfixTabEdit()<CR>
    nnoremap <leader>lt :call QuickfixTabEdit()<CR>
    " 将Quickfix中的内容放到Location-list中打开
    nnoremap <leader>ql :call setloclist(0, getqflist())<Bar>vertical botright lopen 35<CR>
    " 分割窗口
    nnoremap <leader>ws <C-w>s
    nnoremap <leader>wv <C-W>v
    " 移动焦点
    nnoremap <leader>wc <C-w>c
    nnoremap <leader>wh <C-w>h
    nnoremap <leader>wj <C-w>j
    nnoremap <leader>wk <C-w>k
    nnoremap <leader>wl <C-w>l
    nnoremap <leader>wp <C-w>p
    nnoremap <leader>wP <C-w>P
    nnoremap <leader>ww <C-w>w
    " 移动窗口
    nnoremap <leader>wH <C-w>H
    nnoremap <leader>wJ <C-w>J
    nnoremap <leader>wK <C-w>K
    nnoremap <leader>wL <C-w>L
    nnoremap <leader>wT <C-w>T
    " 修改尺寸
    nnoremap <leader>w= <C-w>=
    inoremap <C-Up> <Esc>:resize+1<CR>i
    inoremap <C-Down> <Esc>:resize-1<CR>i
    inoremap <C-Left> <Esc>:vertical resize-1<CR>i
    inoremap <C-Right> <Esc>:vertical resize+1<CR>i
    nnoremap <C-Up> :resize+1<CR>
    nnoremap <C-Down> :resize-1<CR>
    nnoremap <C-Left> :vertical resize-1<CR>
    nnoremap <C-Right> :vertical resize+1<CR>
    nnoremap <M-Up> :resize+5<CR>
    nnoremap <M-Down> :resize-5<CR>
    nnoremap <M-Left> :vertical resize-5<CR>
    nnoremap <M-Right> :vertical resize+5<CR>
" }}}

" File diff {{{
    " 文件比较，自动补全文件和目录
    nnoremap <leader>ds :call ExecFuncInput(['File: ', '', 'file', expand('%:p:h')], 'FuncDiffFile', 's')<CR>
    nnoremap <leader>dv :call ExecFuncInput(['File: ', '', 'file', expand('%:p:h')], 'FuncDiffFile', 'v')<CR>
    " 比较当前文件（已经分屏）
    nnoremap <leader>dt :diffthis<CR>
    " 关闭文件比较，与diffthis互为逆命令
    nnoremap <leader>do :diffoff<CR>
    " 更新比较结果
    nnoremap <leader>du :diffupdate<CR>
    " 应用差异到别一文件，[range]<leader>dp，range默认为1行
    nnoremap <leader>dp :<C-U>execute '.,+' . string(v:count1-1) . 'diffput'<CR>
    " 拉取差异到当前文件，[range]<leader>dg，range默认为1行
    nnoremap <leader>dg :<C-U>execute '.,+' . string(v:count1-1) . 'diffget'<CR>
    " 下一个diff
    nnoremap <leader>dj ]c
    " 前一个diff
    nnoremap <leader>dk [c
" }}}

" Terminal {{{
    nnoremap <leader>tz :terminal zsh<CR>
if IsVim()
    set termwinkey=<C-l>
    tnoremap <Esc> <C-l>N
else
    tnoremap <Esc> <C-\><C-n>
endif
" }}}

" Coding {{{
    " 创建临时文件
    nnoremap <leader>ei :call ExecFuncInput(['TempFile Suffix: '], 'FuncEditTempFile', 0)<CR>
    nnoremap <leader>eti :call ExecFuncInput(['TempFile Suffix: '], 'FuncEditTempFile', 1)<CR>
    for [key, val] in items({
            \ 'n' : '',
            \ 'c' : 'c',
            \ 'a' : 'cpp',
            \ 'p' : 'py',
            \ 'g' : 'go',
            \})
        execute 'nnoremap <leader>e'  . key . ' :call FuncEditTempFile("' . val . '", 0)<CR>'
        execute 'nnoremap <leader>et' . key . ' :call FuncEditTempFile("' . val . '", 1)<CR>'
    endfor
    nnoremap <leader>so :call FuncSort()<CR>
    nnoremap <leader>dh :call FuncDivideSpaceH()<CR>
    nnoremap <leader>dc :call FuncDivideSpaceC()<CR>
    nnoremap <leader>dl :call FuncDivideSpaceL()<CR>
    nnoremap <leader>dd :call FuncDivideSpaceD()<CR>
    nnoremap <leader>ae :call FuncAppendExecResult()<CR>
    nnoremap <leader>af :call FuncAppendCallResult()<CR>
    " 编译运行当前文件
    nnoremap <leader>rf :call CompileFile('')<CR>
    nnoremap <leader>ri :call ExecFuncInput(['Compile/Run args: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h')], 'CompileFile')<CR>
    nnoremap <leader>ra :call RC_Args()<CR>
    nnoremap <leader>rq :call RC_Qt()<CR>
    nnoremap <leader>rv :call RC_Vs()<CR>
    nnoremap <leader>rm :call RC_Make()<CR>
    nnoremap <leader>rcq :call RC_QtClean()<CR>
    nnoremap <leader>rcv :call RC_VsClean()<CR>
    nnoremap <leader>rcm :call RC_MakeClean()<CR>
    nnoremap <leader>rh :call RC_Html()<CR>
" }}}

" Find and search{{{
    " 查找选择的内容
    vnoremap / "*y<Bar>:execute'let g:__str__=getreg("*")'<Bar>execute'/' . g:__str__<CR>
    " 查找当前光标下的内容
    nnoremap <leader>/ :execute'let g:__str__=expand("<cword>")'<Bar>execute '/' . g:__str__<CR>

    " FindWorking查找
    for key in s:fw_nvmaps
        execute 'nnoremap <leader>' . key ':call FindWorking("' . key . '", "n")<CR>'
    endfor
    for key in s:fw_nvmaps
        execute 'vnoremap <leader>' . key ':call FindWorking("' . key . '", "v")<CR>'
    endfor
    nnoremap <leader>ff :call FindWorkingFile(0)<CR>
    nnoremap <leader>frf :call FindWorkingFile(1)<CR>
    nnoremap <leader>fR :call FindWorkingRoot()<CR>
" }}}
" }}}
