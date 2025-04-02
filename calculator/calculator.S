global _start 
section .data
  message1: db "what is da first numba", 0xA
  len1: equ $ - message1
  
  message2: db "what is da second numba", 0xA
  len2: equ $ - message2

  message3: db "what operator do you want?", 0xA, "+  -  *  /", 0xA
  len3: equ $ - message3

  result_msg: db "result: "
  result_len: equ $ - result_msg

  newline: db 0xA

section .bss
  num1 resb 32
  num2 resb 32
  sum_buffer resb 32
  operator resb 2

section .text
_start:
  ; write first message
  mov rax, 1
  mov rdi, 1
  lea rsi, [message1]
  mov rdx, len1
  syscall
  
  ; read first number
  mov rax, 0
  mov rdi, 0
  lea rsi, [num1]
  mov rdx, 32
  syscall
  
  ; save input length
  mov r12, rax
  
  ; convert first input to integer
  lea rsi, [num1]
  mov rdx, r12
  call ascii_to_int
  mov r14, rax

  ; write third message
  mov rax, 1
  mov rdi, 1
  lea rsi, [message3]
  mov rdx, len3
  syscall

  ; read operator input
  mov rax, 0
  mov rdi, 0
  lea rsi, [operator]
  mov rdx, 2
  syscall


  ; write second message
  mov rax, 1
  mov rdi, 1
  lea rsi, [message2]
  mov rdx, len2
  syscall
  
  ; read second number
  mov rax, 0
  mov rdi, 0
  lea rsi, [num2]
  mov rdx, 32
  syscall
  
  ; save input length
  mov r12, rax
  
  ; convert second input to integer
  lea rsi, [num2]
  mov rdx, r12
  call ascii_to_int
  mov r15, rax
  
  ; display result message
  mov rax, 1
  mov rdi, 1
  lea rsi, [result_msg]
  mov rdx, result_len
  syscall

  ; TODO
  call decide_operator
  
  ; convert sum to ascii
  lea rdi, [sum_buffer]
  call int_to_ascii
  
  ; display the sum
  mov rax, 1
  mov rdi, 1
  lea rsi, [sum_buffer]
  mov rdx, rcx
  syscall
  
  ; display newline
  mov rax, 1
  mov rdi, 1
  lea rsi, [newline]
  mov rdx, 1
  syscall
  
  ; exit program
  mov rax, 60
  xor rdi, rdi
  syscall



; OPERATORS
decide_operator:

  mov al, byte [operator]

  cmp al, "+"
  je .plus
  cmp al, "-"
  je .minus
  cmp al, "*"
  je .multi
  cmp al, "/"
  je .divide
  mov rax, 0 

  ret

  .plus:
    mov rax, r14
    add rax, r15
    ret

  .minus:
    mov rax, r14
    sub rax, r15
    ret

  .multi:
    mov rax, r14
    imul rax, r15
    ret

  .divide:
    mov rax, r14
    xor rdx, rdx
    div r15
    ret
  



; convert ASCII string to integer
ascii_to_int:
  xor rax, rax
  xor rcx, rcx
  
.next_digit:
  cmp rcx, rdx
  jge .done
  
  movzx rbx, byte [rsi + rcx]
  cmp rbx, 0xA
  je .done
  cmp rbx, 0
  je .done
  
  sub rbx, '0'
  imul rax, 10
  add rax, rbx
  inc rcx
  jmp .next_digit
  
.done:
  ret

; convert integer to ASCII
int_to_ascii:
  push rdi
  mov rcx, 0
  mov r8, 10

  test rax, rax
  jnz .convert_loop
  mov byte [rdi], '0'
  mov rcx, 1
  jmp .done

.convert_loop:
  test rax, rax
  jz .reverse
  
  xor rdx, rdx
  div r8
  
  add dl, '0'
  mov [rdi + rcx], dl
  inc rcx
  jmp .convert_loop

.reverse:
  pop rdi
  push rcx
  dec rcx
  mov rsi, 0

.reverse_loop:
  cmp rsi, rcx
  jge .end_reverse
  
  mov al, [rdi + rsi]
  mov ah, [rdi + rcx]
  mov [rdi + rcx], al
  mov [rdi + rsi], ah
  
  inc rsi
  dec rcx
  jmp .reverse_loop

.end_reverse:
  pop rcx

.done:
  mov byte [rdi + rcx], 0
  ret
