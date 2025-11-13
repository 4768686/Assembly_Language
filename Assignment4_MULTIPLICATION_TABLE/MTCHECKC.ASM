	ifndef	??version
?debug	macro
	endm
	endif
	?debug	S "mtcheckc.c"
_TEXT	segment	byte public 'CODE'
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP,ss:DGROUP
_TEXT	ends
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
	?debug	C E9805A665B0A6D74636865636B632E63
	?debug	C E900501D1115433A5C74635C696E636C7564655C737464696F2E68
	?debug	C E900501D1116433A5C74635C696E636C7564655C7374646172672E+
	?debug	C 68
_BSS	ends
_DATA	segment word public 'DATA'
	dw	7
	dw	2
	dw	3
	dw	4
	dw	5
	dw	6
	dw	7
	dw	8
	dw	9
	dw	2
	dw	4
	dw	7
	dw	8
	dw	10
	dw	12
	dw	14
	dw	16
	dw	18
	dw	3
	dw	6
	dw	9
	dw	12
	dw	15
	dw	18
	dw	21
	dw	24
	dw	27
	dw	4
	dw	8
	dw	12
	dw	16
	dw	7
	dw	24
	dw	28
	dw	32
	dw	36
	dw	5
	dw	10
	dw	15
	dw	20
	dw	25
	dw	30
	dw	35
	dw	40
	dw	45
	dw	6
	dw	12
	dw	18
	dw	24
	dw	30
	dw	7
	dw	42
	dw	48
	dw	54
	dw	7
	dw	14
	dw	21
	dw	28
	dw	35
	dw	42
	dw	49
	dw	56
	dw	63
	dw	8
	dw	16
	dw	24
	dw	32
	dw	40
	dw	48
	dw	56
	dw	7
	dw	72
	dw	9
	dw	18
	dw	27
	dw	36
	dw	45
	dw	54
	dw	63
	dw	72
	dw	81
_DATA	ends
_TEXT	segment	byte public 'CODE'
;	?debug	L 3
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,164
	push	si
	push	di
	push	ss
	lea	ax,word ptr [bp-162]
	push	ax
	push	ds
	mov	ax,offset DGROUP:d@
	push	ax
	mov	cx,162
	call	far ptr SCOPY@
;	?debug	L 17
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
;	?debug	L 19
	xor	si,si
	jmp	short @5
@4:
;	?debug	L 20
	xor	di,di
	jmp	short @9
@8:
;	?debug	L 21
	mov	ax,si
	inc	ax
	mov	dx,di
	inc	dx
	mul	dx
	mov	word ptr [bp-164],ax
;	?debug	L 22
	mov	ax,si
	mov	dx,18
	mul	dx
	mov	bx,ax
	mov	ax,di
	shl	ax,1
	add	bx,ax
	lea	ax,word ptr [bp-162]
	add	bx,ax
	mov	ax,word ptr [bx]
	cmp	ax,word ptr [bp-164]
	je	@10
;	?debug	L 23
	mov	ax,di
	inc	ax
	push	ax
	mov	ax,si
	inc	ax
	push	ax
	mov	ax,offset DGROUP:s@+5
	push	ax
	call	near ptr _printf
	add	sp,6
@10:
@7:
	inc	di
@9:
	cmp	di,9
	jl	@8
@6:
@3:
	inc	si
@5:
	cmp	si,9
	jl	@4
@2:
;	?debug	L 27
	xor	ax,ax
	jmp	short @1
@1:
;	?debug	L 28
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_main	endp
_TEXT	ends
	?debug	C E9
_DATA	segment word public 'DATA'
s@	label	byte
	db	88
	db	32
	db	89
	db	10
	db	0
	db	37
	db	100
	db	32
	db	37
	db	100
	db	32
	db	101
	db	114
	db	114
	db	111
	db	114
	db	10
	db	0
_DATA	ends
	extrn	SCOPY@:far
_TEXT	segment	byte public 'CODE'
	extrn	_printf:near
_TEXT	ends
	public	_main
	end
