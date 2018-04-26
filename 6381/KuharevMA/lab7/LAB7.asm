L7_CODE SEGMENT
        ASSUME CS: L7_CODE, DS: L7_DATA, ES: NOTHING, SS: L7_STACK

START:  jmp l7_start

L7_DATA SEGMENT

        PSP_SIZ = 10h                
        STK_SIZ = 10h                

	
        ERR_48H db '�訡�� �㭪樨 48H ���뢠��� 21H, ��� �訡��:     H.',     0Dh, 0Ah, '$'
        ERR_49H db '�訡�� �㭪樨 49H ���뢠��� 21H, ��� �訡��:     H.',     0Dh, 0Ah, '$'
        ERR_4AH db '�訡�� �㭪樨 4AH ���뢠��� 21H, ��� �訡��:     H.',     0Dh, 0Ah, '$'

        ERR_SIZ db '�訡��: ������ ���૥� �ॢ�蠥� 1048560 (FFFF0H) ����!',   0Dh, 0Ah, '$'
        OVL_END db '�஢�ઠ ���૥�� �����襭�. ������ ENTER ��� ��室�.',    0Dh, 0Ah, '$'

        FND_E02 db '�訡�� ���᪠, ��� 0002H: �������� ���� �� �������.',   0Dh, 0Ah, '$'
        FND_E12 db '�訡�� ���᪠, ��� 0012H: �������� 䠩� �� ������.',       0Dh, 0Ah, '$'
        FND_EUN db '�訡�� ���᪠, ���     H: < ��������� ��� �訡�� >',      0Dh, 0Ah, '$'

        EXE_E01 db '�訡�� ����㧪�, ��� 0001H: ������ ����� ����㭪樨.',    0Dh, 0Ah, '$'
        EXE_E02 db '�訡�� ����㧪�, ��� 0002H: �������� 䠩� �� ������.',     0Dh, 0Ah, '$'
        EXE_E03 db '�訡�� ����㧪�, ��� 0003H: �������� ���� �� �������.', 0Dh, 0Ah, '$'
        EXE_E04 db '�訡�� ����㧪�, ��� 0004H: ����� ᫨誮� ����� 䠩���.', 0Dh, 0Ah, '$'
        EXE_E05 db '�訡�� ����㧪�, ��� 0005H: �訡�� ����㯠 � 䠩��.',       0Dh, 0Ah, '$'
        EXE_E08 db '�訡�� ����㧪�, ��� 0008H: �� 墠⠥� ᢮������ �����.',  0Dh, 0Ah, '$'
        EXE_E0A db '�訡�� ����㧪�, ��� 000AH: ���� �।� �ॢ�蠥� 32 ��.',   0Dh, 0Ah, '$'
        EXE_E0B db '�訡�� ����㧪�, ��� 000BH: �����४�� �ଠ� 䠩��.',    0Dh, 0Ah, '$'
        EXE_EUN db '�訡�� ����㧪�, ���     H: < ��������� ��� �訡�� >',    0Dh, 0Ah, '$'

        ABS_NM1 db 100h dup (?)         
        OVL_NM1 db 'LAB7_OV1.OVL', 00h  
        ABS_NM2 db 100h dup (?)         
        OVL_NM2 db 'LAB7_OV2.OVL', 00h  
        ABS_NM3 db 100h dup (?)         
        OVL_NM3 db 'LAB7_OV3.OVL', 00h  
        ABS_NM4 db 100h dup (?)         
        OVL_NM4 db 'LAB7_OV4.OVL', 00h  

        DTA_BUF db 2Bh dup (?)          

        OVLN_IP dw 00h                  
        OVLN_CS dw 00h                  

        EPB_DW1 dw 00h                  
        EPB_DW2 dw 00h                  


        CHR_EOT = '$'
        MSG_CLR = 07h
        HLP_CLR = 09h
        INF_CLR = 0Eh
        ERR_CLR = 0Ch
        OVL_CLR = 0Ah

L7_DATA ENDS


L7_STACK SEGMENT STACK
        db STK_SIZ * 10h dup (?)
L7_STACK ENDS

;__________________________________________________________________

; ��楤���

TETR_TO_HEX PROC NEAR
                and     AL, 0Fh
                cmp     AL, 09h
                jbe     NEXT
                add     AL, 07h
NEXT:           add     AL, 30h
                ret
TETR_TO_HEX ENDP

; ��ॢ�� ���� �� AL � ��� ᨬ���� HEX �᫠ � AX 

BYTE_TO_HEX PROC NEAR
                push    CX
                mov     AH, AL
                call    TETR_TO_HEX
                xchg    AL, AH
                mov     CL, 04h                                                     
                shr     AL, CL
                call    TETR_TO_HEX     
                pop     CX              
                ret
BYTE_TO_HEX ENDP

; ��ॢ�� � HEX ᫮�� �� AX

WRD_TO_HEX PROC NEAR
                push    AX
                push    BX
                push    DI
                mov     BH, AH
                call    BYTE_TO_HEX
                mov     DS:[DI], AH
                dec     DI
                mov     DS:[DI], AL
                dec     DI
                mov     AL, BH
                call    BYTE_TO_HEX
                mov     DS:[DI], AH
                dec     DI
                mov     DS:[DI], AL
                pop     DI
                pop     BX
                pop     AX
                ret
WRD_TO_HEX ENDP

; �뢮� ⥪��

PR_STR_BIOS PROC NEAR
                push    AX
                push    BX
                push    CX
                push    DX
                push    DI
                push    ES
                mov     AX, DS
                mov     ES, AX
                mov     AH, 0Fh         
                int     10h             
                mov     AH, 03h         
                int     10h             
                mov     DI, 00h         
dsbp_nxt:       cmp     byte ptr DS:[BP+DI], CHR_EOT    
                je      dsbp_out        
                inc     DI              
                jmp     dsbp_nxt
dsbp_out:       mov     CX, DI          
                mov     AH, 13h         
                mov     AL, 01h         
                int     10h
                pop     ES
                pop     DI
                pop     DX
                pop     CX
                pop     BX
                pop     AX
                ret
PR_STR_BIOS ENDP

;__________________________________________________________________

; ��� �ணࠬ��
 
; �᢮�������� ���ᯮ��㥬�� ����� 

l7_start:       mov     BX, L7_DATA     
                mov     DS, BX          
                mov     BX, L7_STACK    
                add     BX, STK_SIZ     
                sub     BX, L7_CODE     
                add     BX, PSP_SIZ     
                mov     AH, 4Ah         
                int     21h             
                jc      error_4A        
                jmp     prep_all

; �뢮� ���ଠ樨 �� �訡�� 

error_4A:       lea     DI, ERR_4AH     
                add     DI, 50          
                call    WRD_TO_HEX
                mov     BL, ERR_CLR     
                lea     BP, ERR_4AH
                call    PR_STR_BIOS
                jmp     dos_quit

; ��⠭���� ���� ����� 

prep_all:       mov     AH, 1Ah         
                lea     DX, DTA_BUF     
                int     21h
                mov     SI, 00h         
                jmp     next_ovl

; �롮� ����� ��।���� 䠩�� ���૥�

next_ovl:       inc     SI
                jmp     name_ov1
name_ov1:       cmp     SI, 01h         
                jne     name_ov2        
                lea     CX, OVL_NM1
                lea     DX, ABS_NM1
                jmp     prep_nam
name_ov2:       cmp     SI, 02h         
                jne     name_ov3        
                lea     CX, OVL_NM2
                lea     DX, ABS_NM2
                jmp     prep_nam
name_ov3:       cmp     SI, 03h        
                jne     name_ov4       
                lea     CX, OVL_NM3
                lea     DX, ABS_NM3
                jmp     prep_nam
name_ov4:       cmp     SI, 04h        
                jne     name_eol       
                lea     CX, OVL_NM4
                lea     DX, ABS_NM4
                jmp     prep_nam
name_eol:       mov     BL, OVL_CLR    
                lea     BP, OVL_END
                call    PR_STR_BIOS
                jmp     dos_quit

; �����⮢�� ��᮫�⭮�� ����� 䠩�� 

prep_nam:       push    SI              
                push    ES              
                mov     ES, ES:[2Ch]    
                xor     SI, SI          
prep_eel:       cmp     word ptr ES:[SI], 0000h 
                je      prep_lsi        
                inc     SI              
                jmp     prep_eel        
prep_lsi:       add     SI, 04h         
                mov     DI, SI          
                xor     AX, AX          
prep_lsl:       cmp     byte ptr ES:[DI], 00h   
                je      prep_cpi        
                cmp     byte ptr ES:[DI], "/"  
                je      prep_sls        
                cmp     byte ptr ES:[DI], "\"   
                je      prep_sls        
                jmp     prep_lsn        
prep_sls:       mov     AX, DI          
prep_lsn:       inc     DI              
                jmp     prep_lsl
prep_cpi:       mov     DI, DX          
prep_cpl:       cmp     SI, AX          
                ja      prep_cni        
                mov     BL, ES:[SI]     
                mov     DS:[DI], BL     
                inc     SI              
                inc     DI              
                jmp     prep_cpl
prep_cni:       pop     ES              
                mov     SI, CX          
prep_cnl:       cmp     byte ptr DS:[SI], 00h   
                je      find_ovl        
prep_cns:       mov     BL, DS:[SI]     
                mov     DS:[DI], BL     
                inc     SI              
                inc     DI              
                jmp     prep_cnl

; ���� ��ࢮ�� ���室�饣� 䠩�� 

find_ovl:       pop     SI              
                mov     AH, 4Eh         
                mov     CX, 00h         
                int     21h
                jc      find_e02
                jmp     get_size
find_e02:       cmp     AX, 02h
                jne     find_e12
                mov     BL, ERR_CLR     
                lea     BP, FND_E02
                call    PR_STR_BIOS
                jmp     dos_quit
find_e12:       cmp     AX, 12h
                jne     find_eun
                mov     BL, ERR_CLR     
                lea     BP, FND_E12
                call    PR_STR_BIOS
                jmp     dos_quit
find_eun:       lea     DI, FND_EUN     
                add     DI, 22          
                call    WRD_TO_HEX
                mov     BL, ERR_CLR     
                lea     BP, FND_EUN
                call    PR_STR_BIOS
                jmp     dos_quit

; ����祭�� ࠧ��� 䠩�� 

get_size:       lea     BP, DTA_BUF
                mov     AX, DS:[BP+1Ah] 
                mov     BX, DS:[BP+1Ch] 
                xchg    DX, BP          
                mov     DX, BX
                and     DX, 0000000000001111b   
                cmp     DX, BX          
                jne     size_err        
                mov     CL, 0Ch         
                shl     DX, CL          
                mov     DL, AL
                and     DL, 00001111b   
                cmp     DL, 00000000b   
                je      get_para	
                mov     DL, 01h         
                jmp     get_para        
get_para:       mov     CL, 04h
                shr     AX, CL          
                add     AX, DX          
                jc      size_err        
                xchg    DX, BP          
                jmp     get_fmem


size_err:       mov     BL, ERR_CLR     
                lea     BP, ERR_SIZ
                call    PR_STR_BIOS
                jmp     dos_quit

; �뤥����� ����� ����� ��� ���૥� 

get_fmem:       mov     BX, AX          
                mov     AH, 48h         
                int     21h
                jc      error_48        
                mov     OVLN_CS, AX     
                jmp     make_par

; �뢮� ���ଠ樨 �� �訡�� 

error_48:       lea     DI, ERR_48H     
                add     DI, 50          
                call    WRD_TO_HEX
                mov     BL, ERR_CLR     
                lea     BP, ERR_48H
                call    PR_STR_BIOS
                jmp     dos_quit


make_par:       mov     BX, seg EPB_DW1
                push    ES              
                mov     ES, BX          
                lea     BX, EPB_DW1    
                mov     EPB_DW1, AX    
                mov     EPB_DW2, AX    
                jmp     load_ovl

; ����㧪� ���૥����� ᥣ���� 

load_ovl:       mov     CH, 01h         
                mov     AH, 4Bh         
                mov     AL, 03h         
                int     21h
                pop     ES              
                jc      load_e01        
                mov     CH, 00h         
                jmp     exec_ovl
load_e01:       cmp     AX, 01h
                jne     load_e02
                mov     BL, ERR_CLR     
                lea     BP, EXE_E01
                call    PR_STR_BIOS
                jmp     exe_fmem
load_e02:       cmp     AX, 02h
                jne     load_e03
                mov     BL, ERR_CLR     
                lea     BP, EXE_E02
                call    PR_STR_BIOS
                jmp     exe_fmem
load_e03:       cmp     AX, 03h
                jne     load_e04
                mov     BL, ERR_CLR     
                lea     BP, EXE_E03
                call    PR_STR_BIOS
                jmp     exe_fmem
load_e04:       cmp     AX, 04h
                jne     load_e05
                mov     BL, ERR_CLR     
                lea     BP, EXE_E04
                call    PR_STR_BIOS
                jmp     exe_fmem
load_e05:       cmp     AX, 05h
                jne     load_e08
                mov     BL, ERR_CLR     
                lea     BP, EXE_E05
                call    PR_STR_BIOS
                jmp     exe_fmem
load_e08:       cmp     AX, 08h
                jne     load_e0A
                mov     BL, ERR_CLR     
                lea     BP, EXE_E08
                call    PR_STR_BIOS
                jmp     exe_fmem
load_e0A:       cmp     AX, 0Ah
                jne     load_e0B
                mov     BL, ERR_CLR     
                lea     BP, EXE_E0A
                call    PR_STR_BIOS
                jmp     exe_fmem
load_e0B:       cmp     AX, 0Bh
                jne     load_eun
                mov     BL, ERR_CLR     
                lea     BP, EXE_E0B
                call    PR_STR_BIOS
                jmp     exe_fmem
load_eun:       lea     DI, EXE_EUN     
                add     DI, 24          
                call    WRD_TO_HEX
                mov     BL, ERR_CLR     
                lea     BP, EXE_EUN
                call    PR_STR_BIOS
                jmp     exe_fmem

; �믮������ ���� ���૥����� ᥣ���� 

exec_ovl:       call    dword ptr DS:[OVLN_IP]
                jmp     exe_fmem

; �᢮�������� �뤥������� ����� �����

exe_fmem:       mov     AX, OVLN_CS     
                push    ES              
                mov     ES, AX          
                mov     AH, 49h         
                int     21h
                pop     ES              
                jc      error_49        
                cmp     CH, 00h         
                jne     dos_quit
                jmp     next_ovl

; �뢮� ���ଠ樨 �� �訡��

error_49:       lea     DI, ERR_49H     
                add     DI, 50          
                call    WRD_TO_HEX
                mov     BL, ERR_CLR     
                lea     BP, ERR_49H
                call    PR_STR_BIOS
                jmp     dos_quit

; ��室
dos_quit:       mov     AH, 01h
                int     21h
                mov     AH, 4Ch
                int     21h

L7_CODE ENDS
END START
                                                                                 
