global _start
section .data ;uninitialized data
inp_buf resb 5 ;reserves 5 bytes
msg1 db "You entered: "
len1 equ $ - msg1
msg2 db "Please enter x,y",0xa
len2 equ $ - msg2



_start:
mov ebp,esp ;initializing the stack
push len2
push msg2 ;passing arg to the stack
call write
mov eax,1 ;sys_exit system calls
mov ebx,0 ;exit status is 0
int 0x80

read:
push ebp ;function Prologue
mov ebp,esp
mov eax, 3 ;sys_read system calls
mov ebx, 0 ;stdout file descriptor
mov ecx, inp_buf ;pointer to the first element
mov edx, 5;get a five byte num
pop ebp
push inp_buf
int 0x80

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
