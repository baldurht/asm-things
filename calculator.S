global _start 

section .data
message: db "what is da numba", 0xA

section .bss
buffer resq 1

section .text

_start:

  mov rax, 1
  mov rdi, 1
  lea rsi, [message]
  mov rdx, 17
  syscall

  mov rax, 0
  mov rdi, 0
  mov rsi, buffer
  mov rdx, 8
  syscall

  mov rax, 0x3c
  xor rdi, rdi
  syscall
