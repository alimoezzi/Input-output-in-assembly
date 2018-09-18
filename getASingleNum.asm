global _start
section .data ; uninitialized data
inp_buf: resb 5;reserves 5 bytes

_start:
mov eax, 3 ;sys_read system calls
mov ebx, 0 ;stdout file descriptor
mov ecx, inp_buf ; pointer to the first element
mov edx, 5; get a five byte num
int 0x80

mov eax, 4 ;sys_write system calls
mov ebx, 1 ;stdout file descriptor
mov ecx, inp_buf ;the pointer to the first element
mov edx, 5; the length
int 0x80

mov eax,1 ;sys_exit system calls
mov ebx,0 ;exit status is 0
int 0x80