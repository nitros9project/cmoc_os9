	SECTION code

MUL168	EXPORT * export this symbol


* Multiply B by X, unsigned; return result in D; preserve X.
MUL168	PSHS	X,B,A		acc A pushed to create temp byte at ,S
	LDA	2,S		high byte of X
	MUL			multiply by B
	STB	,S		keep intermediate result
	LDB	1,S		original B
	LDA	3,S		low byte of X
	MUL * multiply A by B and leave the product in D
	ADDA	,S * add memory pointed to by S into A
	LEAS	4,S * adjust S using 4,S
	RTS * return to caller



	ENDSECTION * end current section
