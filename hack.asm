;------------------------------------------------------------------------------------------------------------------
;This program read port 60h in cycle
;------------------------------------------------------------------------------------------------------------------
;                                        program

.model tiny   ;64 kilobytes in RAM, address == 16 bit == 2 bytes (because: sizeof (register) == 2 bytes)

;--------------------------------------------------------------------------------------------------------------
;										main program
;--------------------------------------------------------------------------------------------------------------

.code         ;begin program
org 100h      ;start == 256:   jmp start == jmp 256 != jmp 0 (because address [0;255] in program segment in DOS for PSP)
start:
	;-----------------------------------------------------------------------------------------------------------
	;                                 open file

	mov ah, 3dh              ;open file
	mov al, 00h         	 ;access mode: 0 - read, 1 - write, 2 - both
	mov dx, offset name_of_file_with_text      ;ds:dx = address on name of file with text  
	int 21h                                    

	jnc skip_massage_about_error_in_file     ;if CF is set to CY => ax = error code   (cannot find file)
							                 ;else               => ax = file handle  (can    find file)

	mov ah, 09h
	mov dx, offset massage_about_error_in_file
	int 21h                                       ;int 21h:09h = print string massage_about_error_in_file
	jmp end_work_of_program

	skip_massage_about_error_in_file:

	;-----------------------------------------------------------------------------------------------------------
	;                               read from file to buffer

	mov bx, ax        					 ;bx = file handle
	mov ah, 3fh       					 ;read file
	mov cx, 0ffffh     					 ;cx = max quantity of reading symbols from file to buffer
	mov dx, offset buffer_for_password   ;ds:dx = address on buffer
	int 21h

	jnc skip_massage_about_error_reading_file     ;if CF is set to CY => ax = error code                   (cannot read file)
							                      ;else               => ax = quantity of reading symbols  (can    read file)

	mov ah, 09h
	mov dx, offset massage_about_error_reading_file
	int 21h                                       ;int 21h:09h = print string massage_about_error_reading_file
	jmp end_work_of_program

	skip_massage_about_error_reading_file:

	;-----------------------------------------------------------------------------------------------------------
	;                               check canaries

	cmp canary_left, 'a'
	jne write_massage_about_change_of_canary    ;if (canary_left  != 'a') {error ();}

	cmp canary_right, 'a'
	jne write_massage_about_change_of_canary    ;if (canary_right != 'a') {error ();}

	jmp skip_massage_about_change_of_canary

	write_massage_about_change_of_canary:

	mov ah, 09h
	mov dx, offset massage_about_change_of_canary
	int 21h                                       ;int 21h:09h = print string massage_about_change_of_canary
	jmp end_work_of_program

	skip_massage_about_change_of_canary:

	;-----------------------------------------------------------------------------------------------------------
	;                               count and check hash

	mov si, dx

	call count_hash  ;bx = hash of password

	cmp bx, correct_hash
	je skip_massage_about_wrong_password     ;if (bx != correct_hash) {wrong_password ();}

	mov ah, 09h
	mov dx, offset massage_about_wrong_password
	int 21h                                       ;int 21h:09h = print string massage_about_wrong_password
	jmp end_check_hash      ;!!! vulnerability    correct: jmp end_work_of_program 

	skip_massage_about_wrong_password:

	mov flag_of_correct_password, '1'    ;correct hash of password => allow access     ;!!! vulnerability (for stack)

	end_check_hash:

	;-----------------------------------------------------------------------------------------------------------
	;								allow access

	cmp flag_of_correct_password, '1'
	je write_massage_about_allow_access

	mov ah, 09h
	mov dx, offset massage_about_wrong_password
	int 21h                                       ;int 21h:09h = print string massage_about_wrong_password
	jmp end_work_of_program 

	write_massage_about_allow_access:

	mov ah, 09h
	mov dx, offset massage_about_allow_access
	int 21h                                       ;int 21h:09h = print string massage_about_allow_access

	;-----------------------------------------------------------------------------------------------------------
	;                               end_work_of_program

	end_work_of_program:
	mov ax, 4c00h      ;end of program with returned code = 0
	int 21h            
;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
;											 count_hash
;count hash of password 
;
;Entry: ds = our data segment address                                          
;       si = address on buffer
;
;Exit:  bx = hash of password
;
;Destr: bx = count hash of password
;		si = shifting of address on buffer
;       cx = len of password
;		al = for calculating
;--------------------------------------------------------------------------------------------------------------

count_hash proc  

	xor ax, ax   ;ax = 0000h
	xor bx, bx   ;bx = 0000h

	mov cx, 0010d  ;cx = len of password = 0010d

	take_for_hash_next_symbol_in_password:

	lodsb								;mov al, ds:[si]
										;inc si

	add bx, ax

	loop take_for_hash_next_symbol_in_password      ;while (cx--) {ax += ds:[dx++];}

	ret     
	endp    
;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
;                                      variables
.data 

name_of_file_with_text db 'S:\PROGRAMS\HACKING\text.txt', 0      ;way to file with text (password)
massage_about_error_in_file db 'program do not find file with text, you do not have access', 0dh, 0ah, '$'        
massage_about_error_reading_file db 'error in reading of file, you do not have access', 0dh, 0ah, '$'
massage_about_change_of_canary db 'detected buffer overflow, you do not have access', 0dh, 0ah, '$'
massage_about_wrong_password db 'wrong password, you do not have access', 0dh, 0ah, '$'
massage_about_allow_access db 'correct password, you have access', 0dh, 0ah, '$'
correct_hash dw 01efh    ;correct hash of password

;-------------------------------------------------
;danger place
buffer_for_password db 0010d dup (0)               ;buffer for password from file

canary_left db 'a'    ;guard flag

flag_of_correct_password db '0'  ; = '0'  => incorrect password
								 ; = '1'  =>   correct password

canary_right db 'a'  ;guard flag

;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
end_of_program:
end start              ;end of asm and address of program's beginning

