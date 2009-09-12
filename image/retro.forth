#! ------------------------------------------------------------
#! Retro, a dialect of Forth
#! ------------------------------------------------------------
   3072 is-data SCRATCH-START
   4096 is-data TIB
   5120 is-data HEAP-START

begin retroImage
#! ------------------------------------------------------------
mark-dictionary    ( Pointer to the most recent dictionary )
variable last      ( header )
HEAP-START
variable: heap     ( Starting address of the data/code heap )
#! ------------------------------------------------------------
variable which     ( Pointer to dictionary header of the most )
                   ( recently looked up word )
variable compiler  ( Is the compiler on or off? )
#! ------------------------------------------------------------
variable flag      ( Shared variable used by some primitives )
                   ( It's used as a flag, a counter, etc.    )
#! ------------------------------------------------------------
label: copytag   " RETRO 10" $,
label: nomatch   " Word Not Found" $,
label: okmsg     " ok " $,
#! ------------------------------------------------------------
: dup  ( n-nn )  dup, ;       : 1+   ( n-n   )  1+, ;
: 1-   ( n-n  )  1-, ;        : swap ( xy-yx )  swap, ;
: drop ( n-   )  drop, ;      : and  ( xy-n  )  and, ;
: or   ( xy-n )  or, ;        : xor  ( xy-n  )  xor, ;
: @    ( a-n  )  @, ;         : !    ( na-   )  !, ;
: +    ( xy-n )  +, ;         : -    ( xy-n  )  -, ;
: *    ( xy-n )  *, ;         : /mod ( xy-qr )  /mod, ;
: <<   ( xy-n )  <<, ;        : >>   ( xy-n  )  >>, ;
: out  ( np-  )  out, ;       : in   ( p-n   )  in, ;

: wait ( - )  0 # 0 # out, wait, ;

: nip   ( xy-y   )  swap, drop, ;
: over  ( xy-xyx )  push, dup, pop, swap, ;
: 2drop ( nn-    )  drop, drop, ;
: not   ( x-y    )  -1 # xor, ;
: rot   ( xyz-yzx ) push, swap, pop, swap, ;
: -rot  ( xyz-xzy ) swap, push, swap, pop, ;
: tuck  ( xy-yxy )  dup, -rot ;
: 2dup  ( x-xx   )  over over ;
: on    ( a-     )  -1 # swap, !, ;
: off   ( a-     )  0 # swap, !, ;
: /     ( xy-q   )  /mod, nip ;
: mod   ( xy-r   )  /mod, drop, ;
: neg   ( x-y    )  -1 # *, ;
: execute ( a-   )  1-, push, ;

: @+ ( a-an )  dup, 1+, swap, @, ;
: !+ ( na-a )  dup, 1+, push, !, pop, ;
: +! ( na-  )  dup, push, @, +, pop, !, ;
: -! ( na-  )  dup, push, @, swap, -, pop, !, ;
#! ------------------------------------------------------------
: t-here   ( -a  )  heap # @, ;
: t-,      ( n-  )  t-here !, t-here 1+, heap # !, ;
: t-]      ( -   )  -1 # compiler # !, ;
: t-[      ( -   )  0 # compiler # !, ;
: t-;;     ( -   )  9 # t-, ;
: t-;      ( -   )  t-;; t-[ ;
: ($,)     ( a-a )  repeat dup, @, 0; t-, 1+, again ;
: $        ( a-  )  ($,) drop, 0 # t-, ;
: t-push   ( n-  )  5 # t-, ;
: t-pop    ( -n  )  6 # t-, ;
: compile  ( a-  )  7 # t-, t-, ;
: literal, ( n-  )  1 # t-, t-, ;
: t-for    ( R: n-   C: -a )
  t-here 5 # t-, ;
: t-next   ( R: -    C: a- )
  6 # t-, 27 # t-, 2 # t-, 1 # t-, 0 # t-, 12 # t-, t-, 3 # t-, ;
: (if)     ( -a )
  t-here 0 # t-, ;
: t-=if    ( R: xy-  C: -a )
  12 # t-, (if) ;
: t->if    ( R: xy-  C: -a )
  11 # t-, (if) ;
: t-<if    ( R: xy-  C: -a )
  10 # t-, (if) ;
: t-!if    ( R: xy-  C: -a )
  13 # t-, (if) ;
: t-then   ( R: -    C: a- )
  t-here swap, !, 0 # t-, ;
: t-repeat ( R: -    C: -a )
  t-here ;
: t-again  ( R: -    C: a- )
  8 # t-, t-, ;
: t-0;     ( n-n || n -  )  25 # t-, ;

: .word   ( a- )
  compiler # @, -1 # =if 7 # t-, t-, ; then execute ;
: .primitive ( a- )
  dup, @, 0 # !if .word ; then
  compiler # @, -1 # =if 1+, 1+, @, t-, ; then execute ;
: .macro  ( a- )
   execute ;
: .data   ( a- )
   compiler # @, -1 # =if 1 # t-, t-, then ;
: .compiler ( a- )
   compiler # @, 0 # =if drop ; then execute ;

' .word     to 'WORD      ' .macro  to 'MACRO
' .data     to 'DATA      ' .primitive to 'PRIMITIVE
' .compiler to 'COMPILER
#! ------------------------------------------------------------
-1 variable: update
: redraw  ( - )  update # @, 0; drop, 0 # 3 # out, ;

: emit ( c- )  1 # 2 # out, wait redraw ;
: cr   ( -  )  10 # emit ;
: clear    ( -   )  -1 # emit ;

: (type) ( a-a ) repeat @+ 0; emit again ;
: type   ( a-  ) update # off (type) drop, update # on redraw ;
#! ------------------------------------------------------------
variable >in             ( Offset into the TIB )
variable break-char      ( Holds the delimiter for 'accept' )
-1 variable: whitespace  ( Allow extended whitespace )

: (remap-keys) ( c-c ) ;
: crlf ( c-c ) dup, 13 # =if drop, 10 # then ;
: ws ( c-c )
  whitespace # @, 0; drop,
  dup,  9 # =if drop, 32 # ; then
  dup, 10 # =if drop, 32 # ; then
;

: key ( -c )
  repeat
    1 # 1 # out,
    wait 1 # in,
    dup, 0 # !if (remap-keys) crlf ws ; then drop,
  again
;

: >tib ( c- )  TIB # >in # @, +, !, ;
: ++   ( -  )  1 # >in # +! ;

: eat-leading ( "- )
  repeat
    key dup, emit dup,
    break-char # @, !if >tib ++ ; then drop,
  again ;

: (accept) ( -c )
  repeat
    key dup, emit dup,
    break-char # @, =if drop, ; then
    dup, 8 # =if 1 # >in # -! drop, 8 , ' (accept) , then
    >tib ++
  again ;

: accept ( c- )
  break-char # !, 0 # >in # !, eat-leading (accept) 0 # >tib ;
#! ------------------------------------------------------------
: d->class ( a-a )  1+, ;
: d->xt    ( a-a )  1+, 1+, ;
: d->name  ( a-a )  1+, 1+, 1+, ;

: create   ( "-  )   t-here              ( Entry Start )
                     last # @, t-,       ( Link to previous )
                     last # !,           ( Set as newest )
                     'DATA # t-,         ( Class = .data )
                     t-here 0 # t-,      ( XT )
                     32 # accept TIB # $ ( Name )
                     t-here swap, !, ;   ( Patch XT to HERE )
: (:)        ( -   )  last # @, d->class !, t-] 0 # t-, 0 # t-, ;
: t-:        ( "-  )  create 'WORD  # (:) ;
: t-macro:   ( "-  )  create 'MACRO # (:) ;
: t-compiler: ( "- )  create 'COMPILER # (:) ;
: t-(        ( "-  )  char: ) # accept ;
#! ------------------------------------------------------------
: n=n      ( xy-   )  !if 0 # flag # !, then ;
: get-set  ( ab-xy )  @, swap, @, ;
: next-set ( ab-cd )  1+, swap, 1+, swap, ;

: (skim)
  repeat
    2dup @, swap, @, +, 0; drop,
    2dup get-set n=n next-set
    flag # @, 0; drop,
  again
;

: compare   ( $$-f )
  -1 # flag # !,
  (skim) 2drop flag # @, ;

: (strlen)  ( a-na )
  repeat dup, @, 0; drop, next-set again ;

: getLength ( $-n )
  0 # swap, (strlen) drop, ;

variable SAFE

: (reset-$)  SCRATCH-START # SAFE # !, ;
: (next)     1 # SAFE # +! ;
: (save)     repeat @+ 0; SAFE # @, !, (next) again ;

: tempString  ( a-a )
  (reset-$) (save) drop, 0 # SAFE # @, !, SCRATCH-START # ;

: (save) dup, getLength repeat 0; push, @+ t-, pop, 1-, again ;

: keepString  ( a-a )
  dup, getLength 1+, 1+, 1+, t-here +,
  8 # t-, t-,
  t-here push,
  (save) drop, 0 # t-,
  pop,
;

: t-"  ( "-a )
  char: " # accept TIB # tempString ;
: t-s" ( R: -a  C: "- )
  t-" keepString 1 # t-, t-, ;
#! ------------------------------------------------------------
variable #value        variable num
variable #ok           variable negate?

label: nums " 0123456789ABCDEF" $,
label: base 10 ,

: digits
  repeat dup, push, nums # +, @, over =if -1 # num # !, then pop, 0; 1-, again ;
: (hex) 16 # digits ;
: (dec) 10 # digits ;
: (oct)  8 # digits ;
: (bin)  2 # digits ;
: (digit)
  base # @, 10 # =if (dec) ; then
  base # @, 16 # =if (hex) ; then
  base # @,  8 # =if (oct) ; then
  base # @,  2 # =if (bin) ; then
;
: digit?
  0 # num # !, (digit) drop, num # @, ;

: char>digit ( c-n )
  char: 0 # -,
  base # @, 16 # =if dup, 16 # >if 7 # -, then then ;

: isNegative?
  ( a-a+1 )
  dup, @, char: - # =if -1 # negate? # !, 1+, ; then
  1 # negate? # !, ;

: (convert)
  repeat
    dup, @, 0; char>digit #value # @, base # @, *, +,
    #value # !, 1+,
  again ;

: >number ( $-n )
  isNegative? 0 # #value # !, (convert) drop,
  #value # @, negate? # @, *, ;

: (isnumber)
  repeat
    dup, @, 0; digit? flag # @, and, flag # !, 1+,
  again ;

: isnumber?
  isNegative? -1 # flag # !, (isnumber) drop,
  flag # @, ;

: <#> repeat base # @, /mod, swap, nums # +, @, swap, 0; again ;
: neg? dup, 0 # >if ; then 45 # emit -1 # *, ;
: display repeat 0; emit again ;
: . neg? 0 # swap <#> display 32 # emit ;
#! ------------------------------------------------------------
variable found

: (search)
  repeat
    dup, d->name TIB # compare
    -1 # =if which # !, found # on ; then
    @, 0;
  again
;

: search
  found # off last # @, (search) ;

: t-'    ( "-a )
  32 # accept search
  found # @, -1 # =if which # @, d->xt @, ; then 0 #
  found # on ;
: t-[']  ( R: -a   C: "- )
  1 # t-, t-' t-, ;
#! ------------------------------------------------------------
: :devector ( a-  )  dup, 0 # swap, !, 1+, 0 # swap, !, ;
: :is       ( aa- )  dup, 8 # swap, !, 1+, !, ;
: devector  ( "-  )  t-' :devector ;
: is        ( a"- )  t-' :is ;
#! ------------------------------------------------------------
: save   ( - )  1 # 4 # out, wait ;
: bye    ( - )  jump, MAX-IMAGE , ;
: words  ( - )
  last # @, repeat dup, d->name type 32 # emit @, 0; again ;
: depth  ( -n )
  -5 # 5 # out, wait, 5 # in, ;
: reset  ( ...- )
  depth : (reset) 0; push, drop, pop, 1-, (reset) ;
#! ------------------------------------------------------------
variable #mem   ( Amount of memory provided )
variable fb     ( canvas present?    )
variable fw     ( framebuffer width  )
variable fh     ( framebuffer height )

: boot ( - )
  copytag # type cr ;
: run-on-boot ( - )
  -1 # 5 # out, wait 5 # in, #mem # !,  ( Memory Size )
  -2 # 5 # out, wait 5 # in, fb # !,    ( Canvas Present? )
  -3 # 5 # out, wait 5 # in, fw # !,    ( Canvas Width )
  -4 # 5 # out, wait 5 # in, fh # !,    ( Canvas Height )
  boot ;
#! ------------------------------------------------------------
: with-class   ( ac- ) execute ;
: notfound     ( -   ) cr nomatch # type cr ;
: the->xt      ( a-n ) which # @, d->xt @, ;
: the->class   ( a-n ) which # @, d->class @, ;
: tib->number? ( -f  ) TIB # isnumber? ;
: tib->number  ( -n  ) TIB # >number .data ;

: word?   ( - )
  found # @, -1 # =if the->xt the->class with-class then ;
: number? ( - )
  found # @, 0 # =if tib->number? -1 # =if tib->number ; then
  notfound then ;
: ok      ( - )
  compiler # @, 0 # =if cr okmsg # type then ;
: listen  ( - )
  repeat ok 32 # accept search word? number? again ;
#! ----------------------------------------------------------
main:
  run-on-boot listen
#! ----------------------------------------------------------
( Primitives )
' 1+           primitive: 1+       ' 1-           primitive: 1-
' swap         primitive: swap     ' drop         primitive: drop
' and          primitive: and      ' or           primitive: or
' xor          primitive: xor      ' @            primitive: @
' !            primitive: !        ' +            primitive: +
' -            primitive: -        ' *            primitive: *
' /mod         primitive: /mod     ' <<           primitive: <<
' >>           primitive: >>       ' nip          primitive: nip
' dup          primitive: dup      ' in           primitive: in
' out          primitive: out

( Words )
' t-here       word: here          ' t-,          word: ,
' t-]          word: ]             ' create       word: create
' t-:          word: :             ' t-macro:     word: macro:
' t-compiler:  word: compiler:     ' accept       word: accept
' cr           word: cr            ' emit         word: emit
' type         word: type          ' clear        word: clear
' words        word: words         ' key          word: key
' over         word: over          ' 2drop        word: 2drop
' not          word: not           ' rot          word: rot
' -rot         word: -rot          ' tuck         word: tuck
' 2dup         word: 2dup          ' on           word: on
' off          word: off           ' /            word: /
' mod          word: mod           ' neg          word: neg
' execute      word: execute       ' .            word: .
' t-"          word: "             ' compare      word: compare
' wait         word: wait          ' t-'          word: '
' @+           word: @+            ' !+           word: !+
' +!           word: +!            ' -!           word: -!
' :is          word: :is           ' :devector    word: :devector
' is           word: is            ' devector     word: devector
' compile      word: compile       ' literal,     word: literal,
' tempString   word: tempString    ' redraw       word: redraw
' keepString   word: keepString    ' getLength    word: getLength
' bye          word: bye           ' (remap-keys) word: (remap-keys)
' with-class   word: with-class    ' .word        word: .word
' .macro       word: .macro        ' .data        word: .data
' .primitive   word: .primitive    ' .compiler    word: .compiler
' d->class     word: d->class      ' d->xt        word: d->xt
' d->name      word: d->name       ' boot         word: boot
' depth        word: depth         ' reset        word: reset
' notfound     word: notfound      ' save         word: save
' >number      word: >number       ' ok           word: ok
' listen       word: listen

( Compiler )
' t-s"         compiler: s"        ' t-[          compiler: [
' t-;          compiler: ;         ' t-;;         compiler: ;;
' t-=if        compiler: =if       ' t->if        compiler: >if
' t-<if        compiler: <if       ' t-!if        compiler: !if
' t-then       compiler: then      ' t-repeat     compiler: repeat
' t-again      compiler: again     ' t-0;         compiler: 0;
' t-push       compiler: push      ' t-pop        compiler: pop
' t-[']        compiler: [']       ' t-for        compiler: for
' t-next       compiler: next

( Macros )
' t-(          macro: (

( Data )
  last         data: last          compiler     data: compiler
  TIB          data: tib           update       data: update
  fb           data: fb            fw           data: fw
  fh           data: fh            #mem         data: #mem
  heap         data: heap          which        data: which
  whitespace   data: whitespace    base         data: base

patch-dictionary
#! ----------------------------------------------------------
cross-summary
end
