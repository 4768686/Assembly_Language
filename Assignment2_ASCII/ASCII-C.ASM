	ifndef	??version
?debug	macro
	endm
	endif
	?debug	S "ascii-c.c"
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
	?debug	C E9CC52555B0961736369692D632E63
	?debug	C E900501D1115433A5C74635C696E636C7564655C737464696F2E68
	?debug	C E900501D1116433A5C74635C696E636C7564655C7374646172672E+
	?debug	C 68
_BSS	ends
_TEXT	segment	byte public 'CODE'
;	?debug	L 3
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
;	?debug	L 4
	xor	si,si
;	?debug	L 6
	mov	byte ptr [bp-1],97
	jmp	short @5
@4:
;	?debug	L 7
	mov	al,byte ptr [bp-1]
	cbw	
	push	ax
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
	pop	cx
;	?debug	L 8
	inc	si
;	?debug	L 10
	cmp	si,13
	jne	@6
;	?debug	L 11
	mov	ax,offset DGROUP:s@+3
	push	ax
	call	near ptr _printf
	pop	cx
;	?debug	L 12
	xor	si,si
@6:
@3:
	inc	byte ptr [bp-1]
@5:
	cmp	byte ptr [bp-1],122
	jle	@4
@2:
;	?debug	L 15
	xor	ax,ax
	jmp	short @1
@1:
;	?debug	L 16
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_main	endp
_TEXT	ends
	?debug	C E9
_DATA	segment word public 'DATA'
s@	label	byte
	db	37
	db	99
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