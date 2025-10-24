	ifndef	??version
?debug	macro
	endm
	endif
	?debug	S "sum2.c"
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
	?debug	C E9749C585B0673756D322E63
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
	push	di
;	?debug	L 6
	xor	di,di
;	?debug	L 8
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
;	?debug	L 9
	lea	ax,word ptr [bp-2]
	push	ax
	mov	ax,offset DGROUP:s@+41
	push	ax
	call	near ptr _scanf
	pop	cx
	pop	cx
;	?debug	L 11
	mov	si,1
	jmp	short @5
@4:
;	?debug	L 12
	mov	ax,di
	add	ax,si
	mov	di,ax
@3:
	inc	si
@5:
	cmp	si,word ptr [bp-2]
	jle	@4
@2:
;	?debug	L 15
	push	di
	mov	ax,offset DGROUP:s@+44
	push	ax
	call	near ptr _printf
	pop	cx
	pop	cx
@1:
;	?debug	L 16
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
	db	80
	db	108
	db	101
	db	97
	db	115
	db	101
	db	32
	db	69
	db	110
	db	116
	db	101
	db	114
	db	32
	db	65
	db	32
	db	78
	db	117
	db	109
	db	98
	db	101
	db	114
	db	32
	db	66
	db	101
	db	116
	db	119
	db	101
	db	101
	db	110
	db	32
	db	49
	db	32
	db	65
	db	110
	db	100
	db	32
	db	49
	db	48
	db	48
	db	32
	db	0
	db	37
	db	100
	db	0
	db	84
	db	104
	db	101
	db	32
	db	83
	db	117
	db	109
	db	32
	db	105
	db	115
	db	58
	db	32
	db	37
	db	100
	db	10
	db	0
_DATA	ends
_TEXT	segment	byte public 'CODE'
	extrn	_printf:near
	extrn	_scanf:near
_TEXT	ends
	public	_main
	end
