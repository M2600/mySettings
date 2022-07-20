" 文字コードしてい
set fenc=utf-8
" 挿入モードでバックスペースで削除
set backspace=indent,eol,start
" wildmenu
set wildmenu

"-----------------------------------------------------
" 検索設定
"-----------------------------------------------------

" 検索時、大文字小文字を区別しない
set ignorecase
" 検索結果をハイライト
set hlsearch

"------------------------------------------------------
" 表示設定
"------------------------------------------------------
" 対応するカッコやブレースを表示
set showmatch matchtime=1
" ステータス行を常に表示
set laststatus=2
" 行末スペース表示
set listchars=tab:^\ ,trail:~
" コマンドライン履歴を10000件保存
set history=10000
" コメントの色を水色
hi Comment ctermfg=3
" インデント幅
set shiftwidth=4
" yでコピーしたときにクリップボードに入れる
set guioptions+=a
" 改行に入力された行の末尾に合わせて次の行のインデントを増減する
set smartindent
" タイトル表示
set title
" 行番号
set number
" タブ、空白、改行の可視化
set list
" ヤンクでクリップボードのコピー
set clipboard=unnamed,autoselect
" シンタックスハイライト
syntax on
" ○や□文字が重ならないように
set ambiwidth=double

" カーソルを行末の一つ先まで移動可能に
set virtualedit=onemore
" 自動インデント
set autoindent

call plug#begin()
	Plug 'Shougo/ddc.vim'
	Plug 'vim-denops/denops.vim'
	Plug 'Shougo/ddc-around'
	Plug 'shougo/ddc-matcher_head'
	Plug 'shougo/ddc-sorter_rank'
	Plug 'github/copilot.vim'
	Plug 'Shougo/neocomplete.vim'
call plug#end()

" 使いたいsourceを指定する
call ddc#custom#patch_global('sources', ['around'])

" sourceOptionsのmatchersにfilter指定することで、候補の一覧を制御できる
call ddc#custom#patch_global('sourceOptions', {
	    \ '_': {
	    \ 'matchers': ['matcher_head'],
	    \ 'sorters': ['sorter_rank']
	    \ }})

" Change source options
call ddc#custom#patch_global('sourceOptions', {
	    \ 'around': {'mark': 'A'},
	    \ })
call ddc#custom#patch_global('sourceParams', {
	    \ 'around': {'maxSize': 500},
	    \ })

" Customize settings on a filetype
call ddc#custom#patch_filetype(['c', 'cpp'], 'sources', ['around', 'clangd'])
call ddc#custom#patch_filetype(['c', 'cpp'], 'sourceOptions', {
	    \ 'clangd': {'mark': 'C'},
	    \ })
call ddc#custom#patch_filetype('markdown', 'sourceParams', {
	    \ 'around': {'maxSize': 100},
	    \ })

" Mappings

" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ ddc#map#pum_visible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB>  ddc#map#pum_visible() ? '<C-p>' : '<C-h>'


call ddc#enable()
