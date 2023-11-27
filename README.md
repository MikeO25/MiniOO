# Compile
To Compile MiniOO type <br>
`make`
To delete all the compiled output  files <br>
`make delete`

# Testing
test.mini | xargs echo | ./minioo

# Status
Current - fix ambiguous grammar for field with addition <br>
Next -  Write pprint AST / report <br>

# TODO
- fix y = x.@f + 1 being read as x.(@f + 1) 
- add AST pprint
- clean stack feature
- parallelism + atom 

# Progress log
- nov 27 - wrote code for field/malloc - 2 hr
- nov 26 - got recursive procedure working - 1 hr 30 min
- nov 24 - Added while loops and PLUS
- nov 16 - got if working, added printing for stack and heap - 1 hr 30 min
- nov 15 - got assign, sequence in eval_cmd working and minus, ident in eval_expr working  - 1 hr 40 min
- nov 14 - worked on assignments and declarations - 10 min


