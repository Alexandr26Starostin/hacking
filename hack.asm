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
	mov ah, 3dh              ;open file
	mov al, 00h         	 ;access mode: 0 - read, 1 - write, 2 - both
	mov dx, offset name_of_file_with_text      ;ds:dx = address on name of file with text  
	int 21h                                    

	jc error_end_work_of_program     ;if CF is set to CY => ax = error code   (cannot find file)
							         ;else               => ax = file handle  (can    find file)

	jmp end_work_of_program          ;skip massage about error

	error_end_work_of_program:
	mov ah, 09h
	mov dx, offset error_massage
	int 21h                          ;int 21h:09h = print string error_massage: massage about error

	end_work_of_program:
	mov ax, 4c00h      ;end of program with returned code = 0
	int 21h            
;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
;											 check
; 
;
;Entry: None                                         
;
;Exit:  None
;
;Destr: None
;--------------------------------------------------------------------------------------------------------------

check proc     

	
	ret     
	endp    
;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
;                                      variables
.data 

name_of_file_with_text db 'S:\PROGRAMS\HACKING\text.txt', 0      ;way to file with text (password)

error_massage db 'error in work of program!!!$'        ;error_massage          

buffer_for_password db 0010d dup (0)               ;buffer for password from file

;--------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------
end_of_program:
end start              ;end of asm and address of program's beginning

