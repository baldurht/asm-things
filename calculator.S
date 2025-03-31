global _start 

section .data
message1: db "what is da first numba", 0xA
len1: equ $ - message1

message2: db "what is da second numba", 0xA
len2: equ $ - message2

result: db "result: "
result_len: equ $ - result

section .bss
num1 resb 32
num2 resb 32
sum resb 32

section .text

_start:

  ; write first message
  mov rax, 1
  mov rdi, 1
  lea rsi, [message1]
  mov rdx, len1
  syscall

  ; read first input 
  mov rax, 0
  mov rdi, 0
  mov rsi, num1
  mov rdx, 32
  syscall
  mov r8, rax


  ; write second message 
  mov rax, 1
  mov rdi, 1
  lea rsi, [message2]
  mov rdx, len2
  syscall

  ; read second input
  mov rax, 0
  mov rdi, 0
  mov rsi, num2
  mov rdx, 32
  syscall
  mov r8, rax



jmp exit

ascii_to_int:
  xor rax, rax
  xor rcx, rcx


.next_digit:
  mov bl, byte [rsi + rcx]
  cmp bl, 0xA
  je .done
  sub bl, '0'
  imul rax, rax, 10
  add rax, rbx
  inc rcx
  jmp .next_digit

.done:
  ret

; exit
exit:
  mov rax, 0x3c
  xor rdi, rdi
  syscall
