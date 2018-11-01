global _start
section .bss ;uninitialized data
inp_buf resb 30 ;reserves 2 bytes
out_buf resb 30 ;reserves 2 bytes
section .data ;initialized data
msg1 db "You entered: "
len1 equ $ - msg1
msg2 db "Please enter x,y",0xa
len2 equ $ - msg2
integer_counter db 5



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
mov eax,1 ;sys_exit system calls
mov ebx,0 ;exit status is 0
int 0x80

read:
push ebp ;function Prologue
mov ebp,esp
mov ecx,[ebp+8]
mov edx,[ebp+12]
pushad
lea edi,[ecx] ;edi is the start of the buffer.
mov ecx,edx ;putting count in ecx for rep
xor eax,eax ;fill the buffer with zeros.    
rep stosb ;store string with ecx dwords = 4*ecx bytes.
popad
mov eax, 3 ;sys_read system calls
mov ebx, 0 ;stdin file descriptor
int 0x80
dec eax ;actual length of chars read is in eax
lea edi,[ecx+eax] ;edi is the start of the buffer.
xor eax,eax ;fill the buffer with zeros.    
stosb 
mov esp,ebp
pop ebp
ret

write:
push ebp
mov ebp,esp ;function prologue
mov ecx,[esp+8] ;the arg1 is in esp+8
mov edx,[esp+12] ;the arg2 is in esp+12
; mov ecx, eax ;the pointer to the first element
mov eax, 4 ;sys_write system calls
mov ebx, 1 ;stdout file descriptor
int 0x80
mov esp,ebp ;function epilogue
pop ebp
ret

atoi:
push ebp
mov ebp,esp ;function prologue
mov ecx,[esp+12] ;count of characters
mov edx,[esp+8] ;the address is in the esp+8
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
mov ebx,eax
mov esp,ebp ;function epilogue
pop ebp
ret


itoa:
push ebp
mov ebp,esp ;function prologue
mov ecx,[esp+12] ;integer to be converted
mov edx,[esp+8] ;the address is in the esp+8
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
cmp byte al,0
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
mov esp,ebp ;function epilogue
pop ebp
ret 
