global _start
extern ExitProcess, GetStdHandle, WriteConsoleA , ReadConsoleA


section .bss ;uninitialized data
inp_buf resb 30 ;reserves 2 bytes
out_buf resb 30 ;reserves 2 bytes
buffer resb 2
section .data ;initialized data
out_buf_len equ 30 ;reserves 2 bytes
got_len dd 0 ;reserves 2 bytes
msg1 db "You entered: "
len1 equ $ - msg1
msg2 db "Please enter x,y",0xa
len2 equ $ - msg2
integer_counter db 11
consoleInHandle     dd 0
lpNumberOfEventsRead dd 1
; STD_OUTPUT_HANDLE   equ -11
maxlen equ 9

section .code
_start:
mov ebp,esp ;initializing the stack
push len2
push msg2 ;passing arg to the stack
call write
push 30 ;length
push inp_buf ;buffer
call read
push 30
push inp_buf
call atoi ;stores res in eax
push eax
push out_buf
call itoa
push 30
push out_buf
call write
push 0
call ExitProcess

read:
push ebp ;function Prologue
mov ebp,esp
pushad
mov ecx,[ebp+8]
mov edx,[ebp+12]
pushad
lea edi,[ecx] ;edi is the start of the buffer.
mov ecx,edx ;putting count in ecx for rep
xor eax,eax ;fill the buffer with zeros.    
rep stosb ;store string with ecx dwords = 4*ecx bytes.
popad
;

push -10
call GetStdHandle
push ecx
mov [consoleInHandle],eax
push 0;pInputControl
push got_len;pInputControl
push edx;nNumberOfCharsToRead
push ecx
push dword[consoleInHandle]
call ReadConsoleA
pop ecx
;
mov edx,[got_len]
dec edx ;actual length of chars read is in eax
dec edx ;actual length of chars read is in eax
lea edi,[ecx+edx] ;edi is the start of the buffer.
mov ecx,2
xor eax,eax ;fill the buffer with zeros.    
rep stosb
popad 
mov esp,ebp
pop ebp
ret 8

write:
push ebp
mov ebp,esp ;function prologue
pushad
mov ecx,[ebp+8] ;msg
mov edx,[ebp+12] ;len
; mov ecx, eax ;the pointer to the first element
push -11
call GetStdHandle

push 0
push buffer
push edx
push ecx
push eax
call WriteConsoleA
popad
mov esp,ebp ;function epilogue
pop ebp
ret 8

atoi:
push ebp
mov ebp,esp ;function prologue
pushad
mov ecx,[ebp+12] ;count of characters
mov edx,[ebp+8] ;the address is in the esp+8
xor eax, eax ;stores result
xor ebx, ebx ;stores character
push edx
cmp byte[edx],"-"
je neg_manipulation
atoi_start:
mov bl, [edx] ;get character
cmp bl, 0 ;till null terminator
je end_atoi
imul eax,10 ;multiplu by 10
sub bl, 30h ;ascii to int
add eax, ebx ;and add the new digit
inc edx ;;next char
jmp atoi_start
neg_manipulation:
inc edx
jmp atoi_start
end_atoi:
pop edx
cmp byte[edx],"-"
je twos_com
jne finish_atoi
twos_com:
neg eax
finish_atoi:
push eax ;*
add esp,4 ;*
popad
mov eax,[esp-36] ;*
mov esp,ebp ;function epilogue
pop ebp
ret 8


itoa:
push ebp
mov ebp,esp ;function prologue
pushad
mov ecx,[ebp+12] ;integer to be converted
mov edx,[ebp+8] ;the address is in the esp+8
pushad
lea edi,[edx] ;edi is the start of the buffer.
mov ecx,out_buf_len ;putting count in ecx for rep
xor eax,eax ;fill the buffer with zeros.    
rep stosb ;store string with ecx dwords = 4*ecx bytes.
popad
;
pushad
mov eax,ecx
cdq ;abs
xor eax,edx
sub eax,edx
mov ebx,1
cmp eax,0
je _lngth_end
xor edx,-2
and edx,1
dec edx
_lngth_start:
cmp ebx,eax
jg _lngth_end
cmp edx,maxlen
jge _lngth_end
inc edx
push eax
mov eax,ebx
shl ebx,3
shl eax,1
add ebx,eax
pop eax
jmp _lngth_start
_lngth_end:
mov [integer_counter],edx
popad
cmp ecx,-2000000000
jle _lngth_special
_lngth_special_con:
;
push ecx
cmp ecx,0
jl neg_itoa_mani
_itoa_start:
xor eax,eax
mov al,[integer_counter]
cbw
cwde
mov byte [edx+eax+1],0
push edx ;stroring the output buffer addr.
_loop:
push eax ; store the cursor position
xor eax,eax
mov eax,ecx
cdq
mov ebx,10
idiv ebx
mov ecx,eax
cmp eax,0
je endloop
add edx,48
pop eax ; get back the cursor
pop ebx
mov [ebx+eax],dl
dec eax
push ebx
jmp _loop
endloop:
add edx,48
pop eax ; get back the cursor
pop ebx
mov [ebx+eax],dl
jmp itoa_end
neg_itoa_mani:
neg ecx
jmp _itoa_start
itoa_end:
pop ecx
cmp ecx,0
jnl itoa_finish
mov byte[ebx+eax-1],"-"
itoa_finish:
popad
mov esp,ebp ;function epilogue
pop ebp
ret 8
_lngth_special:
inc byte[integer_counter]
jmp _lngth_special_con
