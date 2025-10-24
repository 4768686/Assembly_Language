	ifndef	??version
?debug	macro
	endm
	endif
	?debug	S "sum1.c"
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
	?debug	C E9459A585B0673756D312E63
	?debug	C E900501D1115433A5C74635C696E636C7564655C737464696F2E68
	?debug	C E900501D1116433A5C74635C696E636C7564655C7374646172672E+
	?debug	C 68
_BSS	ends
_TEXT	segment	byte public 'CODE'
;	?debug	L 3
_main	proc	near
	push	si
	push	di
;	?debug	L 5
	xor	di,di
;	?debug	L 7
	mov	si,1
	jmp	short @5
@4:
;	?debug	L 8
	mov	ax,di
	add	ax,si
	mov	di,ax
@3:
	inc	si
@5:
	cmp	si,100
	jle	@4
@2:
;	?debug	L 11
	push	di
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
	pop	cx
@1:
;	?debug	L 12
	pop	di
	pop	si
	ret	
_main	endp
_TEXT	ends
	?debug	C E9
_DATA	segment word public 'DATA'
s@	label	byte
	db	37
	db	100
	db	10
	db	0
_DATA	ends
_TEXT	segment	byte public 'CODE'
	extrn	_printf:near
_TEXT	ends
	public	_main
	end
