global _start
section .data ;uninitialized data
inp_buf resb 30 ;reserves 2 bytes
out_buf resb 30 ;reserves 2 bytes
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
mov eax, 3 ;sys_read system calls
mov ebx, 0 ;stdin file descriptor
int 0x80
dec eax ;actual length of chars read is in eaxs
mov byte [eax+ecx],0
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
atoi_start:
mov bl, [edx] ;get character
cmp bl, 0 ;till null terminator
je end_atoi
imul eax,10 ;multiplu by 10
sub bl, 30h ;ascii to int
add eax, ebx ;and add the new digit
inc edx ;;next char
jmp atoi_start
end_atoi:
mov ebx,eax
mov esp,ebp ;function epilogue
pop ebp
ret


itoa:
push ebp
mov ebp,esp ;function prologue
mov cx,[esp+12] ;integer to be converted
mov edx,[esp+8] ;the address is in the esp+8
xor eax,eax
mov al,[integer_counter]
cbw
cwde
mov byte [edx+eax+1],0
push edx ;stroring the output buffer addr.
_loop:
push eax ; store the cursor position
xor eax,eax
mov ax,cx
cdq
mov ebx,10
idiv ebx
mov cx,ax
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
mov esp,ebp ;function epilogue
pop ebp
ret 
