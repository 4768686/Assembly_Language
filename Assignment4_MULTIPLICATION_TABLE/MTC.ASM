	ifndef	??version
?debug	macro
	endm
	endif
	?debug	S "mtc.c"
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
	?debug	C E929A3655B056D74632E63
	?debug	C E900501D1115433A5C74635C696E636C7564655C737464696F2E68
	?debug	C E900501D1116433A5C74635C696E636C7564655C7374646172672E+
	?debug	C 68
_BSS	ends
_TEXT	segment	byte public 'CODE'
;	?debug	L 3
_main	proc	near
	push	si
	push	di
;	?debug	L 7
	mov	si,9
	jmp	short @5
@4:
;	?debug	L 9
	mov	di,1
	jmp	short @9
@8:
;	?debug	L 10
	mov	ax,si
	mul	di
	push	ax
	push	di
	push	si
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	add	sp,8
@7:
	inc	di
@9:
	cmp	di,si
	jle	@8
@6:
;	?debug	L 13
	mov	ax,offset DGROUP:s@+12
	push	ax
	call	near ptr _printf
	pop	cx
@3:
	dec	si
@5:
	cmp	si,1
	jge	@4
@2:
;	?debug	L 16
	xor	ax,ax
	jmp	short @1
@1:
;	?debug	L 17
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
	db	42
	db	37
	db	100
	db	61
	db	37
	db	45
	db	50
	db	100
	db	9
	db	0
	db	10
	db	0
_DATA	ends
_TEXT	segment	byte public 'CODE'
	extrn	_printf:near
_TEXT	ends
	public	_main
	end
