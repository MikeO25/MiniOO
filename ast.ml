type nodeType =  Boolean | Command | Expression;;

type node = {
	label: nodeType
}

type ast = Empty | Node of node * ast list;;


let a = {label=Command};;
let b = {label=Boolean};;
let c = {label=Expression};;

let t = Node(a, [Node(b, [Empty]); Node(c, [Empty])]);


