ASSUME CS:CODE, DS:DATA, SS:AStack
;---------------------------------
AStack SEGMENT STACK
	DW 64 DUP(0)
AStack ENDS
;---------------------------------
DATA SEGMENT
ENVIRONMENT_ADRESS dw 0

CMD_ADDRESS dw 0
CMD_OFFSET dw 0

FSB1_ADDRESS dw 0
FSB1_OFFSET dw 0

FSB2_ADDRESS dw 0
FSB2_OFFSET dw 0

DYNAMIC_STRUCT db 'This is module with dynamic struct!', 0dh, 0ah, '$'
SUB_MODULE_PATH db '                                   ', 0dh, 0ah, '$', 00h

SUB_MODULE_START db'Sub module was executed!', 0dh, 0ah, '$'
EOL db '   ',0dh, 0ah,'$'

KEEP_SS dw 0
KEEP_SP dw 0

DATA ENDS
;---------------------------------
CODE SEGMENT
;---------------------------------
MAIN_PROC PROC FAR
	mov ax, DATA
	mov ds, ax
	mov dx, offset DYNAMIC_STRUCT
	call PRINT_STRING
	
	mov dx, offset EOL
	call PRINT_STRING
	
	;clear mem
	mov cl, 04h
	mov ah, 4ah
	
	mov bx, offset NEED_MEM_AREA
	shr bx, cl
	add bx, 30h
	
	int 21h
	
	;fill parameters
	mov ax, es
	
	mov ENVIRONMENT_ADRESS, 00h
	
	mov word ptr CMD_ADDRESS, ax
	mov word ptr CMD_OFFSET, 0080h
	
	mov word ptr FSB1_ADDRESS, ax
	mov word ptr FSB1_OFFSET, 005Ch
	
	mov word ptr FSB2_ADDRESS, ax
	mov word ptr FSB2_OFFSET, 006Ch
	
	;get sub module path
	push es
		push dx
			push bx
				mov es, es:[2Ch]
				mov bx, 00h 
START_C1:	
				mov dl, es:[bx]
				cmp dl, 00h
				je END_C1
				
				inc bx
				jmp START_C1
END_C1:
				inc bx
				mov dl, es:[bx]
				
				cmp dl, 00h
				jne START_C1
				push di
					mov di, offset SUB_MODULE_PATH 
					add bx, 03h
PATH_START:	
					mov dl, es:[bx]
					cmp dl,00h
					je PATH_END
					mov [di], dl
					
					inc di
					inc bx
					jmp PATH_START
PATH_END:
					sub di, 5h
					mov [di + 0], byte ptr '2'
					mov [di + 2], byte ptr 'C'
					mov [di + 3], byte ptr 'O'
					mov [di + 4], byte ptr 'M'
					mov [di + 5], byte ptr 0h

				pop di
			pop bx
		pop dx
	pop es
	
	
	;start sub module
	mov KEEP_SP, sp
	mov KEEP_SS, ss
	push ds
		mov ax, DATA
		mov es, ax
		mov bx, offset ENVIRONMENT_ADRESS
		mov ds, ax
		mov dx, offset SUB_MODULE_PATH
		mov ax, 4B00h
		int 21h
	pop ds
	mov ss, KEEP_SS
	mov sp, KEEP_SP
	
	mov dx, offset EOL
	call PRINT_STRING
	
	jnc COMPLETED
	call ERROR_PROCESSING
	jmp M_EXIT
	
COMPLETED:
	call COMPL_PROCESSING
M_EXIT:	
	mov ah, 4Ch
	int 21h	
MAIN_PROC ENDP
;---------------------------------
PRINT_STRING PROC NEAR
	push ax
	mov ah, 09h
	int	21h
	pop ax
	ret
PRINT_STRING ENDP
;---------------------------------
CLEAR_MEMORY PROC NEAR
	mov cl, 04h
	mov ah, 4ah
	
	mov bx, offset NEED_MEM_AREA
	shr bx, cl
	add bx, 33h
	
	int 21h
	
	ret
CLEAR_MEMORY ENDP
;---------------------------------
FILL_PARAMETERS PROC NEAR
	mov ax, es
	
	mov word ptr CMD_ADDRESS, ax
	mov word ptr CMD_OFFSET, 0080h
	
	mov word ptr FSB1_ADDRESS, ax
	mov word ptr FSB2_OFFSET, 005Ch
	
	mov word ptr FSB2_ADDRESS, ax
	mov word ptr FSB2_OFFSET, 006Ch
	
	ret
FILL_PARAMETERS ENDP
;---------------------------------
COMPL_PROCESSING PROC near
	jmp completed_begin

	pfn db 'Programm finished normally with code !',13,10,'$'
	pfwcb db 'Programm finished with Ctrl+Break!',13,10,'$'
	pfweod db 'Programm finished with error of device!',13,10,'$'
	pfw31h db 'Programm finished with 31h!',13,10,'$' 
	pfwc db 'Programm finished with code     !',13,10,'$' 
completed_begin:
	push ds
    push ax
	push dx
	push bx

	mov ah,4Dh
	int 21h
	
	push ax
	mov ax,SEG pfn
	mov ds,ax
	pop ax

	cmp ah,0h
	jne not_com_0
	mov dx,offset pfn
not_com_0:

	cmp ah,1h
	jne not_com_1
	mov dx,offset pfwcb
not_com_1:

	cmp ah,2h
	jne not_com_2
	mov dx,offset pfweod
not_com_2:

	cmp ah,3h
	jne not_com_3
	mov dx,offset pfw31h
not_com_3:
	mov ah,9h
	push ax
	int 21h
	pop ax
	mov dx,offset pfwc
	mov bx,dx
	add bx,1Ch
	mov byte ptr [bx],al
	int 21h
	
	pop bx
	pop dx
	pop ax
	pop ds
	
	ret
COMPL_PROCESSING ENDP

ERROR_PROCESSING PROC near
	jmp errors_begin

	wnof db 'Wrong number of function!',13,10,'$'
	fnf db 'File not found!',13,10,'$'
	de db 'Disc error!',13,10,'$'
	nem db 'Not enough memory!',13,10,'$'
	wsoe db 'Wrong string of enviroment!',13,10,'$'
	wf db 'Wrong format!',13,10,'$'
errors_begin:
	push ds
    push ax
	push dx
	push ax
	mov ax,SEG wnof
	mov ds,ax
	pop ax
	
	cmp ax,1h
	jne not_err_1
	mov dx,offset wnof
not_err_1:
	cmp ax,2h
	jne not_err_2
	mov dx,offset fnf
not_err_2:
	cmp ax,5h
	jne not_err_5
	mov dx,offset de
not_err_5:
	cmp ax,8h
	jne not_err_8
	mov dx,offset nem
not_err_8:
	cmp ax,10h
	jne not_err_10
	mov dx,offset wsoe
not_err_10:
	cmp ax,11h
	jne not_err_11
	mov dx,offset wf
not_err_11:
	mov ah,9h
	int 21h
	pop dx
	pop ax
	pop ds
	ret
ERROR_PROCESSING ENDP
;##############
NEED_MEM_AREA:
;##############
CODE ENDS
;---------------------------------
END MAIN_PROC

