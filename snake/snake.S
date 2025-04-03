global _start 
section .data
  pipe: db "|"
  dash: db "-"
  newline: db 0xA
  space: db "."
  
section .bss

; TODO sikkert gjøre loopsa til functions
; TODO gjøre koden mer lett lest?
; TODO finne ut hvordan jeg kan time loopsene.
;      liksom ha x antal loops i sekundet 
;  

section .text
_start:

  mov r14, 0x20
  mov rax, 1
  mov rdi, 1
  mov rdx, 1
  lea rsi, [dash]
roof_loop:
  syscall
  dec r14
  test r14, r14
  jnz roof_loop

lea rsi, [newline]
syscall

mov r13, 0x16
wall_loop:
  lea rsi, [pipe]
  syscall
  lea rsi, [space]
  mov r15, 0x1e
  space_loop:
    ; TODO her må jeg sjekke hvor slangen er og ha en cmp
    syscall
    dec r15
    cmp r15, 0
    jg space_loop
  lea rsi, [pipe]
  syscall
  lea rsi, [newline]
  syscall
  dec r13
  test r13, r13
  jnz wall_loop


mov r10, 0x20
lea rsi, [dash]
floor_loop:
  syscall
  dec r10
  test r10, r10
  jnz floor_loop

lea rsi, [newline]
syscall

  ; exit program
  mov rax, 60
  xor rdi, rdi
  syscall
